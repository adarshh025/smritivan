// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.

class WellbeingModel {
  final String id;
  final String userId;
  final String status; // 'good', 'okay', 'not_great', 'sad', 'tired'
  final String? notes;
  final String timestamp;
  final String hlcTimestamp;
  final bool isDeleted;
  final String syncStatus;

  const WellbeingModel({
    required this.id,
    required this.userId,
    required this.status,
    this.notes,
    required this.timestamp,
    required this.hlcTimestamp,
    this.isDeleted = false,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'notes': notes,
      'timestamp': timestamp,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory WellbeingModel.fromMap(Map<String, dynamic> map) {
    return WellbeingModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      timestamp: map['timestamp'] as String,
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  String get emoji {
    switch (status) {
      case 'good': return '😊';
      case 'okay': return '🙂';
      case 'not_great': return '😐';
      case 'sad': return '😔';
      case 'tired': return '😴';
      default: return '🙂';
    }
  }

  String get displayStatus {
    switch (status) {
      case 'good': return 'Good';
      case 'okay': return 'Okay';
      case 'not_great': return 'Not great';
      case 'sad': return 'Sad';
      case 'tired': return 'Tired';
      default: return 'Unknown';
    }
  }
}
