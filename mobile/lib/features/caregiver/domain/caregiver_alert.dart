// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

enum AlertCategory {
  cognitive,
  reminder,
  wellbeing,
  routine,
  engagement,
}

enum AlertUrgency {
  info,
  attention,
  important,
}

enum AlertStatus {
  new_alert, // 'new' is a reserved keyword in dart, mapped to 'new' in DB
  seen,
  resolved,
  dismissed,
}

class CaregiverAlert {
  final String alertId;
  final String userId;
  final AlertCategory category;
  final AlertUrgency urgency;
  final String title;
  final String description;
  final String? suggestedAction;
  final AlertStatus status;
  final int occurrences;
  final DateTime firstDetected;
  final DateTime lastUpdated;
  
  // Sync fields
  final String? hlcTimestamp;
  final String? syncStatus;
  final bool isDeleted;

  const CaregiverAlert({
    required this.alertId,
    required this.userId,
    required this.category,
    required this.urgency,
    required this.title,
    required this.description,
    this.suggestedAction,
    this.status = AlertStatus.new_alert,
    this.occurrences = 1,
    required this.firstDetected,
    required this.lastUpdated,
    this.hlcTimestamp,
    this.syncStatus,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'alert_id': alertId,
      'user_id': userId,
      'category': category.name,
      'urgency': urgency.name,
      'title': title,
      'description': description,
      'suggested_action': suggestedAction,
      'status': status == AlertStatus.new_alert ? 'new' : status.name,
      'occurrences': occurrences,
      'first_detected': firstDetected.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory CaregiverAlert.fromMap(Map<String, dynamic> map) {
    return CaregiverAlert(
      alertId: map['alert_id'] as String,
      userId: map['user_id'] as String,
      category: AlertCategory.values.firstWhere((e) => e.name == map['category']),
      urgency: AlertUrgency.values.firstWhere((e) => e.name == map['urgency']),
      title: map['title'] as String,
      description: map['description'] as String,
      suggestedAction: map['suggested_action'] as String?,
      status: _parseStatus(map['status'] as String),
      occurrences: map['occurrences'] as int,
      firstDetected: DateTime.parse(map['first_detected'] as String),
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      hlcTimestamp: map['hlc_timestamp'] as String?,
      syncStatus: map['sync_status'] as String?,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }

  static AlertStatus _parseStatus(String statusStr) {
    if (statusStr == 'new') return AlertStatus.new_alert;
    return AlertStatus.values.firstWhere((e) => e.name == statusStr, orElse: () => AlertStatus.new_alert);
  }

  CaregiverAlert copyWith({
    String? alertId,
    String? userId,
    AlertCategory? category,
    AlertUrgency? urgency,
    String? title,
    String? description,
    String? suggestedAction,
    AlertStatus? status,
    int? occurrences,
    DateTime? firstDetected,
    DateTime? lastUpdated,
    String? hlcTimestamp,
    String? syncStatus,
    bool? isDeleted,
  }) {
    return CaregiverAlert(
      alertId: alertId ?? this.alertId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      title: title ?? this.title,
      description: description ?? this.description,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      status: status ?? this.status,
      occurrences: occurrences ?? this.occurrences,
      firstDetected: firstDetected ?? this.firstDetected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hlcTimestamp: hlcTimestamp ?? this.hlcTimestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
