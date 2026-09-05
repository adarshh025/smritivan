// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (স্মৃতিवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/reminder_model.dart';

/// Repository for patient routines and medication adherence tracking
class ReminderRepository {
  final AppDatabase _appDb;

  ReminderRepository(this._appDb);

  Future<List<ReminderModel>> getRemindersForUser(String userId) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.reminders,
      where: 'user_id = ? AND ${DbTables.colIsDeleted} = 0',
      whereArgs: [userId],
      orderBy: 'time ASC',
    );

    return results.map((row) => ReminderModel.fromMap(row)).toList();
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.reminders,
      primaryKeyCol: 'id',
      rowId: reminder.id,
      data: reminder.toMap(),
    );
  }

  Future<void> updateStatus(String reminderId, String newStatus) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.reminders,
      where: 'id = ? AND ${DbTables.colIsDeleted} = 0',
      whereArgs: [reminderId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final current = ReminderModel.fromMap(results.first);
      final updated = current.copyWith(
        status: newStatus,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await saveReminder(updated);
    }
  }

  Future<void> toggleStatus(String reminderId) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.reminders,
      where: 'id = ? AND ${DbTables.colIsDeleted} = 0',
      whereArgs: [reminderId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final current = ReminderModel.fromMap(results.first);
      final newStatus = current.status == 'done' ? 'pending' : 'done';
      final updated = current.copyWith(
        status: newStatus,
        completedAt: newStatus == 'done' ? DateTime.now().toIso8601String() : null,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await saveReminder(updated);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    await _appDb.deleteCRDTRecord(
      tableName: DbTables.reminders,
      primaryKeyCol: 'id',
      rowId: reminderId,
    );
  }
}

