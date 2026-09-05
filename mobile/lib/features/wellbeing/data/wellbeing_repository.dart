// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/wellbeing_model.dart';
import '../../reminders/application/reminder_service.dart';

final wellbeingRepositoryProvider = Provider<WellbeingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WellbeingRepository(db);
});

class WellbeingRepository {
  final AppDatabase _appDb;
  final _uuid = const Uuid();

  WellbeingRepository(this._appDb);

  Future<void> saveCheckIn(String userId, String status, {String? notes}) async {
    final record = WellbeingModel(
      id: _uuid.v4(),
      userId: userId,
      status: status,
      notes: notes,
      timestamp: DateTime.now().toIso8601String(),
      hlcTimestamp: '', // DB handles this
    );
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.wellbeingCheckins,
      primaryKeyCol: 'id',
      rowId: record.id,
      data: record.toMap(),
    );
  }

  Future<List<WellbeingModel>> getRecentCheckIns(String userId, {int limit = 7}) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.wellbeingCheckins,
      where: 'user_id = ? AND ${DbTables.colIsDeleted} = 0',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return results.map((row) => WellbeingModel.fromMap(row)).toList();
  }
}
