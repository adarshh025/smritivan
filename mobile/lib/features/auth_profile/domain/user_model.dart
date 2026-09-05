// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

/// Dementia Patient Profile Entity
class UserModel {
  final String id;
  final String name;
  final String nativeLanguage; // 'as', 'mni', 'kha', 'brx', 'hi', 'en'
  final String dementiaStage; // 'Early-Stage MCI', 'Moderate', 'Severe'
  final String? caregiverId;
  final int? age;
  final String? phone;
  final String? preferredActivityTime; // e.g. "Morning", "Afternoon", "Evening"
  final bool notificationsEnabled;
  final bool soundEffectsEnabled;
  final bool voiceGuidanceEnabled;
  final bool hapticFeedbackEnabled;
  final String? profilePhotoPath;
  final String createdAt;
  final String updatedAt;
  final String hlcTimestamp;
  final bool isDeleted;
  final String syncStatus;

  const UserModel({
    required this.id,
    required this.name,
    required this.nativeLanguage,
    required this.dementiaStage,
    this.caregiverId,
    this.age,
    this.phone,
    this.preferredActivityTime,
    this.notificationsEnabled = true,
    this.soundEffectsEnabled = true,
    this.voiceGuidanceEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
    required this.hlcTimestamp,
    this.isDeleted = false,
    this.syncStatus = 'pending',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? nativeLanguage,
    String? dementiaStage,
    String? caregiverId,
    int? age,
    String? phone,
    String? preferredActivityTime,
    bool? notificationsEnabled,
    bool? soundEffectsEnabled,
    bool? voiceGuidanceEnabled,
    bool? hapticFeedbackEnabled,
    String? profilePhotoPath,
    String? createdAt,
    String? updatedAt,
    String? hlcTimestamp,
    bool? isDeleted,
    String? syncStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      dementiaStage: dementiaStage ?? this.dementiaStage,
      caregiverId: caregiverId ?? this.caregiverId,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      preferredActivityTime: preferredActivityTime ?? this.preferredActivityTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      voiceGuidanceEnabled: voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlcTimestamp: hlcTimestamp ?? this.hlcTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'native_language': nativeLanguage,
      'dementia_stage': dementiaStage,
      'caregiver_id': caregiverId,
      'age': age,
      'phone': phone,
      'preferred_activity_time': preferredActivityTime,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'sound_effects_enabled': soundEffectsEnabled ? 1 : 0,
      'voice_guidance_enabled': voiceGuidanceEnabled ? 1 : 0,
      'haptic_feedback_enabled': hapticFeedbackEnabled ? 1 : 0,
      'profile_photo_path': profilePhotoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      nativeLanguage: map['native_language'] as String,
      dementiaStage: map['dementia_stage'] as String,
      caregiverId: map['caregiver_id'] as String?,
      age: map['age'] as int?,
      phone: map['phone'] as String?,
      preferredActivityTime: map['preferred_activity_time'] as String?,
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 1) == 1,
      soundEffectsEnabled: (map['sound_effects_enabled'] as int? ?? 1) == 1,
      voiceGuidanceEnabled: (map['voice_guidance_enabled'] as int? ?? 1) == 1,
      hapticFeedbackEnabled: (map['haptic_feedback_enabled'] as int? ?? 1) == 1,
      profilePhotoPath: map['profile_photo_path'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }
}

