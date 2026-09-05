// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

/// Domain Model for a Completed or Live Cognitive Game Session
class GameSessionModel {
  final String sessionId;
  final String userId;
  final String gameType; // 'visual_handloom', 'auditory_focus', 'routine_recall'
  final int durationSeconds;
  final double difficultyLevel; // 1.0 (Gentle) -> 5.0 (Challenging)
  final int reactionTimeMs; // Average touch latency in milliseconds
  final double errorRate; // 0.0 -> 1.0 (mistakes / attempts)
  final double cvsScore; // Cognitive Vitality Score (0 - 100)
  final String timestamp; // ISO-8601
  final String syncStatus; // 'pending', 'synced'
  final String hlcTimestamp;
  final bool isDeleted;

  const GameSessionModel({
    required this.sessionId,
    required this.userId,
    required this.gameType,
    required this.durationSeconds,
    required this.difficultyLevel,
    required this.reactionTimeMs,
    required this.errorRate,
    required this.cvsScore,
    required this.timestamp,
    this.syncStatus = 'pending',
    required this.hlcTimestamp,
    this.isDeleted = false,
  });

  GameSessionModel copyWith({
    String? sessionId,
    String? userId,
    String? gameType,
    int? durationSeconds,
    double? difficultyLevel,
    int? reactionTimeMs,
    double? errorRate,
    double? cvsScore,
    String? timestamp,
    String? syncStatus,
    String? hlcTimestamp,
    bool? isDeleted,
  }) {
    return GameSessionModel(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      reactionTimeMs: reactionTimeMs ?? this.reactionTimeMs,
      errorRate: errorRate ?? this.errorRate,
      cvsScore: cvsScore ?? this.cvsScore,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      hlcTimestamp: hlcTimestamp ?? this.hlcTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'game_type': gameType,
      'duration_seconds': durationSeconds,
      'difficulty_level': difficultyLevel,
      'reaction_time_ms': reactionTimeMs,
      'error_rate': errorRate,
      'cvs_score': cvsScore,
      'timestamp': timestamp,
      'sync_status': syncStatus,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory GameSessionModel.fromMap(Map<String, dynamic> map) {
    return GameSessionModel(
      sessionId: map['session_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      gameType: map['game_type'] as String? ?? '',
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      difficultyLevel: (map['difficulty_level'] as num?)?.toDouble() ?? 1.0,
      reactionTimeMs: (map['reaction_time_ms'] as num?)?.toInt() ?? 1500,
      errorRate: (map['error_rate'] as num?)?.toDouble() ?? 0.0,
      cvsScore: (map['cvs_score'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      syncStatus: map['sync_status'] as String? ?? 'pending',
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }
}

