// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

class CaregiverModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? profilePhotoPath;
  final String hlcTimestamp;
  final bool isDeleted;
  final String syncStatus;

  const CaregiverModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.profilePhotoPath,
    required this.hlcTimestamp,
    this.isDeleted = false,
    this.syncStatus = 'pending',
  });

  CaregiverModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profilePhotoPath,
    String? hlcTimestamp,
    bool? isDeleted,
    String? syncStatus,
  }) {
    return CaregiverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      hlcTimestamp: hlcTimestamp ?? this.hlcTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profile_photo_path': profilePhotoPath,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory CaregiverModel.fromMap(Map<String, dynamic> map) {
    return CaregiverModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      profilePhotoPath: map['profile_photo_path'] as String?,
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }
}
