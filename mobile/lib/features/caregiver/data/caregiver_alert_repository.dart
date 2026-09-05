// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/database_tables.dart';
import '../domain/caregiver_alert.dart';

final caregiverAlertRepositoryProvider = Provider<CaregiverAlertRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CaregiverAlertRepository(db);
});

class CaregiverAlertRepository {
  final AppDatabase _db;

  CaregiverAlertRepository(this._db);

  /// Retrieves alerts for a user, sorted by most recently updated
  Future<List<CaregiverAlert>> getAlerts(String userId, {int limit = 20, bool excludeDismissed = true}) async {
    final db = await _db.database;
    
    String whereClause = 'user_id = ? AND is_deleted = 0';
    if (excludeDismissed) {
      whereClause += ' AND status != "dismissed"';
    }

    final maps = await db.query(
      DbTables.caregiverAlerts,
      where: whereClause,
      whereArgs: [userId],
      orderBy: 'last_updated DESC',
      limit: limit,
    );

    return maps.map((m) => CaregiverAlert.fromMap(m)).toList();
  }

  /// Evaluates and upserts an alert with deduplication strategy
  Future<void> emitAlert(CaregiverAlert newAlert) async {
    final db = await _db.database;
    
    // Check for existing active alert of exact same category and title for this user
    final existing = await db.query(
      DbTables.caregiverAlerts,
      where: 'user_id = ? AND category = ? AND title = ? AND is_deleted = 0 AND status != "dismissed"',
      whereArgs: [newAlert.userId, newAlert.category.name, newAlert.title],
      limit: 1,
    );

    CaregiverAlert finalAlert;

    if (existing.isNotEmpty) {
      final oldAlert = CaregiverAlert.fromMap(existing.first);
      finalAlert = oldAlert.copyWith(
        occurrences: oldAlert.occurrences + 1,
        lastUpdated: DateTime.now(),
        status: AlertStatus.new_alert, // Bubble back up
      );
    } else {
      finalAlert = newAlert.copyWith(
        alertId: const Uuid().v4(),
        firstDetected: DateTime.now(),
        lastUpdated: DateTime.now(),
        occurrences: 1,
        status: AlertStatus.new_alert,
      );
    }

    await _db.upsertCRDTRecord(
      tableName: DbTables.caregiverAlerts,
      primaryKeyCol: 'alert_id',
      rowId: finalAlert.alertId,
      data: finalAlert.toMap(),
    );
  }

  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    final db = await _db.database;
    final existing = await db.query(
      DbTables.caregiverAlerts,
      where: 'alert_id = ? AND is_deleted = 0',
      whereArgs: [alertId],
    );

    if (existing.isNotEmpty) {
      final alert = CaregiverAlert.fromMap(existing.first);
      final updated = alert.copyWith(
        status: status,
        lastUpdated: DateTime.now(),
      );
      
      await _db.upsertCRDTRecord(
        tableName: DbTables.caregiverAlerts,
        primaryKeyCol: 'alert_id',
        rowId: updated.alertId,
        data: updated.toMap(),
      );
    }
  }
}
