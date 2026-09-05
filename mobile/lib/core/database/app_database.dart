// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../security/encryption_service.dart';
import 'crdt_hlc.dart';
import 'database_tables.dart';

/// Offline-First AES-256 Encrypted Database Engine for SMRITIVAN
class AppDatabase {
  static const String _dbFileName = 'smritivan_encrypted.db';
  static const int _dbVersion = 5;

  final EncryptionService _encryptionService;
  final String _nodeId;
  Database? _dbInstance;
  Completer<Database>? _dbInitCompleter;
  HLC? _lastHlc;

  AppDatabase({
    EncryptionService? encryptionService,
    String? nodeId,
  })  : _encryptionService = encryptionService ?? EncryptionService(),
        _nodeId = nodeId ?? const Uuid().v4().substring(0, 8);

  String get nodeId => _nodeId;

  /// Returns active open encrypted Database instance
  Future<Database> get database async {
    if (_dbInstance != null && _dbInstance!.isOpen) {
      return _dbInstance!;
    }
    if (_dbInitCompleter != null) {
      return _dbInitCompleter!.future;
    }
    _dbInitCompleter = Completer<Database>();
    try {
      _dbInstance = await _initDatabase();
      _dbInitCompleter!.complete(_dbInstance);
      return _dbInstance!;
    } catch (e, st) {
      _dbInitCompleter!.completeError(e, st);
      _dbInitCompleter = null;
      rethrow;
    }
  }

  /// Performs a development-time health check on the database connection
  Future<bool> healthCheck() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT count(*) as count FROM ${DbTables.users}');
      final count = Sqflite.firstIntValue(result) ?? 0;
      debugPrint('[AppDatabase] Health Check SUCCESS: Database open, $count user(s) present.');
      return true;
    } catch (e) {
      debugPrint('[AppDatabase] Health Check FAILED: $e');
      return false;
    }
  }

  /// Initializes SQLCipher encrypted SQLite database with resilient multi-passphrase fallback and recovery
  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(docsDir.path);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final dbPath = p.join(docsDir.path, _dbFileName);

    // Retrieve AES-256 key from hardware-backed keystore
    final primaryPassphrase = await _encryptionService.getOrCreateDatabasePassphrase();

    try {
      return await _openDatabaseWithPassphrase(dbPath, primaryPassphrase);
    } catch (primaryErr) {
      debugPrint('[AppDatabase] Primary key open failed: $primaryErr. Attempting resilient recovery...');

      final dbFile = File(dbPath);
      if (dbFile.existsSync()) {
        // Attempt 1: Try fallback static passphrase
        try {
          final db = await _openDatabaseWithPassphrase(dbPath, EncryptionService.fallbackPassphrase);
          // Seamlessly rekey to the primary passphrase
          await db.execute("PRAGMA rekey = '$primaryPassphrase'");
          debugPrint('[AppDatabase] Recovered database with fallback key and rekeyed to primary.');
          return db;
        } catch (_) {}

        // Attempt 2: Try unencrypted open
        try {
          final db = await _openDatabaseWithPassphrase(dbPath, null);
          // Seamlessly encrypt with the primary passphrase
          await db.execute("PRAGMA rekey = '$primaryPassphrase'");
          debugPrint('[AppDatabase] Encrypted existing unencrypted database with primary key.');
          return db;
        } catch (_) {}

        // If file exists but is genuinely corrupted and unreadable by all keys:
        // Safely preserve the corrupt database as a backup file before creating fresh seed
        final backupPath = p.join(docsDir.path, 'smritivan_corrupt_${DateTime.now().millisecondsSinceEpoch}.db.bak');
        try {
          await dbFile.copy(backupPath);
          await dbFile.delete();
          debugPrint('[AppDatabase] Preserved corrupted DB to $backupPath and recreated fresh encrypted DB.');
        } catch (copyErr) {
          debugPrint('[AppDatabase] Could not backup corrupt file: $copyErr');
        }
      }

      // Re-create clean encrypted database with default seed
      return await _openDatabaseWithPassphrase(dbPath, primaryPassphrase);
    }
  }

  Future<Database> _openDatabaseWithPassphrase(String dbPath, String? password) async {
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      password: password,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS ${DbTables.caregiverAlerts}');
          await db.execute(DbTables.createCaregiverAlertsTable);
        }
        if (oldVersion < 3) {
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN age INTEGER'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN phone TEXT'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN preferred_activity_time TEXT'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN notifications_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN profile_photo_path TEXT'); } catch (_) {}

          try { await db.execute(DbTables.createCaregiversTable); } catch (_) {}
          try { await db.execute(DbTables.createRelationshipsTable); } catch (_) {}
        }
        if (oldVersion < 4) {
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN sound_effects_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN voice_guidance_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN haptic_feedback_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
        }
        if (oldVersion < 5) {
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN age INTEGER'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN phone TEXT'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN preferred_activity_time TEXT'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN notifications_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN profile_photo_path TEXT'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN sound_effects_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN voice_guidance_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}
          try { await db.execute('ALTER TABLE ${DbTables.users} ADD COLUMN haptic_feedback_enabled INTEGER NOT NULL DEFAULT 1'); } catch (_) {}

          try { await db.execute(DbTables.createCaregiversTable); } catch (_) {}
          try { await db.execute(DbTables.createRelationshipsTable); } catch (_) {}
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute(DbTables.createUsersTable);
    await db.execute(DbTables.createGameSessionsTable);
    await db.execute(DbTables.createRemindersTable);
    await db.execute(DbTables.createCaregiverAlertsTable);
    await db.execute(DbTables.createWellbeingTable);
    await db.execute(DbTables.createCrdtSyncLogTable);
    await db.execute(DbTables.createCaregiversTable);
    await db.execute(DbTables.createRelationshipsTable);

    for (final indexQuery in DbTables.createIndexes) {
      await db.execute(indexQuery);
    }
  }

  /// Generates the next monotonically increasing Hybrid Logical Clock timestamp
  HLC generateNextHlc() {
    _lastHlc = HLC.now(_nodeId, _lastHlc);
    return _lastHlc!;
  }

  /// Seeds default clinical user & initial NER reminders
  Future<void> _seedInitialData(Database db) async {
    final initialHlc = generateNextHlc().toCanonicalString();
    final nowIso = DateTime.now().toIso8601String();
    const defaultUserId = 'patient_ner_001';

    // 1. Initial User Profile (Grandmother Bhaben Bora, Jorhat, Assam)
    await db.insert(DbTables.users, {
      'id': defaultUserId,
      'name': 'Bhaben Bora (ভবেন বৰা)',
      'native_language': 'as',
      'dementia_stage': 'Early-Stage (Mild Cognitive Impairment)',
      'caregiver_id': 'caregiver_paratha_01',
      'age': 68,
      'phone': '+91 98765 43210',
      'preferred_activity_time': 'Morning',
      'notifications_enabled': 1,
      'sound_effects_enabled': 1,
      'voice_guidance_enabled': 1,
      'haptic_feedback_enabled': 1,
      'created_at': nowIso,
      'updated_at': nowIso,
      DbTables.colHlcTimestamp: initialHlc,
      DbTables.colIsDeleted: 0,
      DbTables.colSyncStatus: 'synced',
    });

    // 2. Initial Dementia Reminders with NER voice context
    final initialReminders = [
      {
        'id': 'rem_001',
        'user_id': defaultUserId,
        'title': 'Morning Medication',
        'description': 'Take your morning pills with food',
        'type': 'medication',
        'category': 'health',
        'priority': 'high',
        'time': '08:30 AM',
        'asset_url': 'assets/audio/ner_sounds/as_morning_meds.mp3',
        'status': 'pending',
        'created_at': nowIso,
        'updated_at': nowIso,
        DbTables.colHlcTimestamp: initialHlc,
        DbTables.colIsDeleted: 0,
        DbTables.colSyncStatus: 'synced',
      },
      {
        'id': 'rem_002',
        'user_id': defaultUserId,
        'title': 'Hydration Check',
        'description': 'Drink a glass of water',
        'type': 'water',
        'category': 'health',
        'priority': 'normal',
        'time': '11:00 AM',
        'asset_url': 'assets/audio/ner_sounds/as_drink_water.mp3',
        'status': 'pending',
        'created_at': nowIso,
        'updated_at': nowIso,
        DbTables.colHlcTimestamp: initialHlc,
        DbTables.colIsDeleted: 0,
        DbTables.colSyncStatus: 'synced',
      },
      {
        'id': 'rem_003',
        'user_id': defaultUserId,
        'title': 'Evening Walk',
        'description': 'Take a short walk outside',
        'type': 'exercise/walk',
        'category': 'activity',
        'priority': 'normal',
        'time': '04:30 PM',
        'asset_url': 'assets/audio/ner_sounds/as_evening_walk.mp3',
        'status': 'pending',
        'created_at': nowIso,
        'updated_at': nowIso,
        DbTables.colHlcTimestamp: initialHlc,
        DbTables.colIsDeleted: 0,
        DbTables.colSyncStatus: 'synced',
      },
    ];

    for (final rem in initialReminders) {
      await db.insert(DbTables.reminders, rem);
    }
  }

  // ===========================================================================
  // CRDT MUTATION HELPERS
  // ===========================================================================

  /// Inserts or updates a record with automatic CRDT HLC stamping & delta logging
  Future<void> upsertCRDTRecord({
    required String tableName,
    required String primaryKeyCol,
    required String rowId,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final hlc = generateNextHlc().toCanonicalString();
    final updatedData = Map<String, dynamic>.from(data);
    updatedData[DbTables.colHlcTimestamp] = hlc;
    updatedData[DbTables.colSyncStatus] = 'pending';
    if (!updatedData.containsKey(DbTables.colIsDeleted)) {
      updatedData[DbTables.colIsDeleted] = 0;
    }

    await db.transaction((txn) async {
      // Upsert into main table
      await txn.insert(
        tableName,
        updatedData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Write Delta to CRDT sync log
      await txn.insert(
        DbTables.crdtSyncLog,
        {
          'log_id': const Uuid().v4(),
          'table_name': tableName,
          'row_id': rowId,
          'operation': 'UPSERT',
          'payload_json': jsonEncode(updatedData),
          'hlc_timestamp': hlc,
          'synced_at': null,
        },
      );
    });
  }

  /// Soft deletes a record with CRDT tombstone
  Future<void> deleteCRDTRecord({
    required String tableName,
    required String primaryKeyCol,
    required String rowId,
  }) async {
    final db = await database;
    final hlc = generateNextHlc().toCanonicalString();

    await db.transaction((txn) async {
      await txn.update(
        tableName,
        {
          DbTables.colIsDeleted: 1,
          DbTables.colHlcTimestamp: hlc,
          DbTables.colSyncStatus: 'pending',
        },
        where: '$primaryKeyCol = ?',
        whereArgs: [rowId],
      );

      await txn.insert(
        DbTables.crdtSyncLog,
        {
          'log_id': const Uuid().v4(),
          'table_name': tableName,
          'row_id': rowId,
          'operation': 'DELETE',
          'payload_json': jsonEncode({'id': rowId, 'is_deleted': 1}),
          'hlc_timestamp': hlc,
          'synced_at': null,
        },
      );
    });
  }

  /// Applies an incoming remote CRDT delta packet using Last-Write-Wins (LWW)
  Future<bool> applyRemoteCRDTDelta(CRDTDeltaMessage delta) async {
    final db = await database;
    final remoteHlc = HLC.parse(delta.hlcTimestamp);

    // Advance local logical clock
    _lastHlc = HLC.receive(_nodeId, _lastHlc ?? HLC.now(_nodeId), remoteHlc);

    // Query existing record to check local HLC
    final existing = await db.query(
      delta.tableName,
      where: 'id = ? OR session_id = ? OR alert_id = ?',
      whereArgs: [delta.rowId, delta.rowId, delta.rowId],
    );

    if (existing.isNotEmpty) {
      final localHlcStr = existing.first[DbTables.colHlcTimestamp] as String?;
      if (localHlcStr != null) {
        final localHlc = HLC.parse(localHlcStr);
        if (localHlc.isAfter(remoteHlc)) {
          // Local record is newer; reject remote delta under Last-Write-Wins
          return false;
        }
      }
    }

    // Apply remote state
    final mergedPayload = Map<String, dynamic>.from(delta.fields);
    mergedPayload[DbTables.colHlcTimestamp] = delta.hlcTimestamp;
    mergedPayload[DbTables.colIsDeleted] = delta.isDeleted ? 1 : 0;
    mergedPayload[DbTables.colSyncStatus] = 'synced';

    await db.insert(
      delta.tableName,
      mergedPayload,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  /// Retrieves un-synced CRDT logs for cloud backend sync
  Future<List<Map<String, dynamic>>> getPendingSyncLogs() async {
    final db = await database;
    return await db.query(
      DbTables.crdtSyncLog,
      where: 'synced_at IS NULL',
      orderBy: 'hlc_timestamp ASC',
    );
  }

  /// Marks CRDT logs as successfully acknowledged by the FastAPI backend
  Future<void> markLogsAsSynced(List<String> logIds) async {
    final db = await database;
    final nowIso = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final id in logIds) {
      batch.update(
        DbTables.crdtSyncLog,
        {'synced_at': nowIso},
        where: 'log_id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Closes database connection
  Future<void> close() async {
    if (_dbInstance != null && _dbInstance!.isOpen) {
      await _dbInstance!.close();
      _dbInstance = null;
    }
  }
}
