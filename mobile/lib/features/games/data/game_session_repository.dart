// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/game_session_model.dart';

/// Repository for logging, persisting, and querying cognitive game telemetry
class GameSessionRepository {
  final AppDatabase _appDb;

  GameSessionRepository(this._appDb);

  /// Saves a newly completed game session with CRDT delta logging
  Future<void> saveGameSession(GameSessionModel session) async {
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.gameSessions,
      primaryKeyCol: 'session_id',
      rowId: session.sessionId,
      data: session.toMap(),
    );
  }

  /// Retrieves the latest session for a given game type to seed difficulty
  Future<GameSessionModel?> getLatestSession(String userId, String gameType) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.gameSessions,
      where: 'user_id = ? AND game_type = ? AND ${DbTables.colIsDeleted} = 0',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return GameSessionModel.fromMap(results.first);
  }

  /// Retrieves the history of sessions for longitudinal analysis & charts (most recent first)
  Future<List<GameSessionModel>> getSessionHistory(String userId, {int limit = 30}) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.gameSessions,
      where: 'user_id = ? AND ${DbTables.colIsDeleted} = 0',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((row) => GameSessionModel.fromMap(row)).toList();
  }

  /// Computes longitudinal statistics across all completed sessions
  Future<Map<String, dynamic>> getAggregateStats(String userId) async {
    final db = await _appDb.database;
    final results = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sessions,
        AVG(cvs_score) as avg_cvs,
        AVG(reaction_time_ms) as avg_latency,
        AVG(error_rate) as avg_error_rate,
        MAX(difficulty_level) as max_difficulty,
        SUM(duration_seconds) as total_duration_seconds
      FROM ${DbTables.gameSessions}
      WHERE user_id = ? AND ${DbTables.colIsDeleted} = 0
    ''', [userId]);

    if (results.isEmpty) {
      return {
        'total_sessions': 0,
        'avg_cvs': 0.0,
        'avg_latency': 0,
        'avg_error_rate': 0.0,
        'max_difficulty': 1.0,
        'total_duration_seconds': 0,
      };
    }

    final row = results.first;
    return {
      'total_sessions': row['total_sessions'] as int? ?? 0,
      'avg_cvs': (row['avg_cvs'] as num?)?.toDouble() ?? 0.0,
      'avg_latency': (row['avg_latency'] as num?)?.toInt() ?? 0,
      'avg_error_rate': (row['avg_error_rate'] as num?)?.toDouble() ?? 0.0,
      'max_difficulty': (row['max_difficulty'] as num?)?.toDouble() ?? 1.0,
      'total_duration_seconds': (row['total_duration_seconds'] as num?)?.toInt() ?? 0,
    };
  }
}

