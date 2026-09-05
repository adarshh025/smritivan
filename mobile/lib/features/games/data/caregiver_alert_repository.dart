// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';

/// Caregiver Alert Domain Entity
class CaregiverAlertModel {
  final String alertId;
  final String triggerReason;
  final String urgency; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final String timestamp;
  final String syncStatus;
  final String hlcTimestamp;
  final bool isDeleted;

  const CaregiverAlertModel({
    required this.alertId,
    required this.triggerReason,
    required this.urgency,
    required this.timestamp,
    this.syncStatus = 'pending',
    required this.hlcTimestamp,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'alert_id': alertId,
      'trigger_reason': triggerReason,
      'urgency': urgency,
      'timestamp': timestamp,
      'sync_status': syncStatus,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory CaregiverAlertModel.fromMap(Map<String, dynamic> map) {
    return CaregiverAlertModel(
      alertId: map['alert_id'] as String,
      triggerReason: map['trigger_reason'] as String,
      urgency: map['urgency'] as String,
      timestamp: map['timestamp'] as String,
      syncStatus: map['sync_status'] as String? ?? 'pending',
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }
}

/// Repository for managing urgent caregiver notifications and anomaly events
class CaregiverAlertRepository {
  final AppDatabase _appDb;

  CaregiverAlertRepository(this._appDb);

  Future<void> createAlert(CaregiverAlertModel alert) async {
    await _appDb.upsertCRDTRecord(
      tableName: DbTables.caregiverAlerts,
      primaryKeyCol: 'alert_id',
      rowId: alert.alertId,
      data: alert.toMap(),
    );
  }

  Future<List<CaregiverAlertModel>> getRecentAlerts({int limit = 20}) async {
    final db = await _appDb.database;
    final results = await db.query(
      DbTables.caregiverAlerts,
      where: '${DbTables.colIsDeleted} = 0',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((row) => CaregiverAlertModel.fromMap(row)).toList();
  }

  Future<int> getUnresolvedHighUrgencyCount() async {
    final db = await _appDb.database;
    final results = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DbTables.caregiverAlerts}
      WHERE urgency IN ('HIGH', 'CRITICAL') AND ${DbTables.colIsDeleted} = 0
    ''');
    return results.first['count'] as int? ?? 0;
  }
}

