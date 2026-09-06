// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/user_model.dart';
import '../domain/caregiver_model.dart';
import '../domain/relationship_model.dart';

/// Repository for patient profile management with encrypted SQLite & CRDT tracking
class UserRepository {
  final AppDatabase _appDb;

  UserRepository(this._appDb);

  /// Fetches the primary active patient profile
  Future<UserModel?> getActivePatient() async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.users,
      where: '${DbTables.colIsDeleted} = 0',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  /// Updates or saves patient profile with automatic CRDT log
  Future<void> savePatient(UserModel user) async {
    final map = user.toMap();
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.users,
      primaryKeyCol: 'id',
      rowId: user.id,
      data: map,
    );
  }

  /// Updates native regional language preference
  Future<void> updateLanguage(String userId, String languageCode) async {
    final current = await getActivePatient();
    if (current != null) {
      final updated = current.copyWith(
        nativeLanguage: languageCode,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await savePatient(updated);
    }
  }

  // ===========================================================================
  // Caregiver & Relationship Methods
  // ===========================================================================

  Future<void> saveCaregiver(CaregiverModel caregiver) async {
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.caregivers,
      primaryKeyCol: 'id',
      rowId: caregiver.id,
      data: caregiver.toMap(),
    );
  }

  Future<CaregiverModel?> getCaregiver(String caregiverId) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.caregivers,
      where: 'id = ? AND ${DbTables.colIsDeleted} = 0',
      whereArgs: [caregiverId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CaregiverModel.fromMap(results.first);
  }

  Future<void> saveRelationship(CaregiverRelationshipModel rel) async {
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.caregiverPatientRelationships,
      primaryKeyCol: 'rel_id',
      rowId: rel.relId,
      data: rel.toMap(),
    );
  }

  /// Gets all active or pending relationships for a patient
  Future<List<CaregiverRelationshipModel>> getRelationshipsForPatient(String patientId) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.caregiverPatientRelationships,
      where: 'patient_id = ? AND ${DbTables.colIsDeleted} = 0 AND status != ?',
      whereArgs: [patientId, RelationshipStatus.revoked.name],
    );
    return results.map((e) => CaregiverRelationshipModel.fromMap(e)).toList();
  }

  /// Retrieves all active (non-deleted) registered patients for health worker monitoring
  Future<List<UserModel>> getAllPatients() async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.users,
      where: '${DbTables.colIsDeleted} = 0',
      orderBy: 'updated_at DESC',
    );
    return results.map((row) => UserModel.fromMap(row)).toList();
  }

  /// Retrieves a specific patient by ID
  Future<UserModel?> getPatientById(String userId) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.users,
      where: 'id = ? AND ${DbTables.colIsDeleted} = 0',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }
}

