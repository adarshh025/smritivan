// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

enum RelationshipStatus {
  pending,
  active,
  revoked
}

class CaregiverRelationshipModel {
  final String relId;
  final String patientId;
  final String caregiverId;
  final String relationshipType; // e.g., 'Son', 'Daughter', 'Spouse', 'Professional Caregiver'
  final RelationshipStatus status;
  final String createdAt;
  final String updatedAt;
  final String hlcTimestamp;
  final bool isDeleted;
  final String syncStatus;

  const CaregiverRelationshipModel({
    required this.relId,
    required this.patientId,
    required this.caregiverId,
    required this.relationshipType,
    this.status = RelationshipStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    required this.hlcTimestamp,
    this.isDeleted = false,
    this.syncStatus = 'pending',
  });

  CaregiverRelationshipModel copyWith({
    String? relId,
    String? patientId,
    String? caregiverId,
    String? relationshipType,
    RelationshipStatus? status,
    String? createdAt,
    String? updatedAt,
    String? hlcTimestamp,
    bool? isDeleted,
    String? syncStatus,
  }) {
    return CaregiverRelationshipModel(
      relId: relId ?? this.relId,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      relationshipType: relationshipType ?? this.relationshipType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlcTimestamp: hlcTimestamp ?? this.hlcTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rel_id': relId,
      'patient_id': patientId,
      'caregiver_id': caregiverId,
      'relationship_type': relationshipType,
      'status': status.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory CaregiverRelationshipModel.fromMap(Map<String, dynamic> map) {
    return CaregiverRelationshipModel(
      relId: map['rel_id'] as String,
      patientId: map['patient_id'] as String,
      caregiverId: map['caregiver_id'] as String,
      relationshipType: map['relationship_type'] as String,
      status: RelationshipStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RelationshipStatus.pending,
      ),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }
}
