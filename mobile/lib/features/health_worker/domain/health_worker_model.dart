// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import '../../auth_profile/domain/user_model.dart';
import '../../games/domain/game_session_model.dart';
import '../../wellbeing/domain/wellbeing_model.dart';

/// Healthcare Professional & Community Health Worker Profile
class HealthWorkerProfile {
  final String id;
  final String workerId;
  final String name;
  final String designation; // e.g., 'Community Health Officer', 'ASHA Coordinator', 'Clinical Psychologist'
  final String facilityName; // e.g., 'Primary Health Centre - Dispur', 'District Hospital - Kohima'
  final String state; // NER State
  final String? phone;
  final String? email;
  final String registeredAt;

  const HealthWorkerProfile({
    required this.id,
    required this.workerId,
    required this.name,
    this.designation = 'Community Health Worker',
    this.facilityName = 'Community Health Centre (NER)',
    this.state = 'Assam',
    this.phone,
    this.email,
    required this.registeredAt,
  });

  factory HealthWorkerProfile.defaultWorker() {
    return HealthWorkerProfile(
      id: 'hw_ner_default_01',
      workerId: 'NHM-NER-2026',
      name: 'Dr. Ananya Sarma',
      designation: 'Cognitive Care Coordinator',
      facilityName: 'Guwahati Neurological & Community Health Centre',
      state: 'Assam',
      phone: '+91 94350 12345',
      registeredAt: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerId': workerId,
      'name': name,
      'designation': designation,
      'facilityName': facilityName,
      'state': state,
      'phone': phone,
      'email': email,
      'registeredAt': registeredAt,
    };
  }

  factory HealthWorkerProfile.fromMap(Map<String, dynamic> map) {
    return HealthWorkerProfile(
      id: map['id'] as String? ?? 'hw_ner_default_01',
      workerId: map['workerId'] as String? ?? 'NHM-NER-2026',
      name: map['name'] as String? ?? 'Healthcare Professional',
      designation: map['designation'] as String? ?? 'Community Health Worker',
      facilityName: map['facilityName'] as String? ?? 'Community Health Centre (NER)',
      state: map['state'] as String? ?? 'Assam',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      registeredAt: map['registeredAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}

/// Clinical & Behavioral Observation (Rule-based, Non-diagnostic)
enum ObservationSeverity {
  positive, // Green: High engagement, stable or improving trend
  neutral,  // Blue: Stable metrics, consistent baseline
  attention // Amber: Low activity, repeated errors, high latency
}

class ClinicalObservation {
  final String id;
  final String patientId;
  final String title;
  final String message;
  final ObservationSeverity severity;
  final String category; // 'Engagement', 'Visual Memory', 'Executive Function', 'Adherence'
  final String timestamp;
  final String? recommendation;

  const ClinicalObservation({
    required this.id,
    required this.patientId,
    required this.title,
    required this.message,
    required this.severity,
    required this.category,
    required this.timestamp,
    this.recommendation,
  });
}

/// Detailed performance statistics for a specific cognitive game
class GamePerformanceMetric {
  final String gameType;
  final String title;
  final String icon;
  final int totalSessions;
  final double maxLevelUnlocked;
  final double avgAccuracy; // 0.0 to 100.0%
  final double avgErrorRate; // 0.0 to 1.0
  final int avgLatencyMs;
  final double bestAccuracy;
  final double recentAccuracy;
  final int totalPlaytimeSeconds;

  const GamePerformanceMetric({
    required this.gameType,
    required this.title,
    required this.icon,
    required this.totalSessions,
    required this.maxLevelUnlocked,
    required this.avgAccuracy,
    required this.avgErrorRate,
    required this.avgLatencyMs,
    required this.bestAccuracy,
    required this.recentAccuracy,
    required this.totalPlaytimeSeconds,
  });
}

/// Reminder Adherence Metrics for a patient
class PatientAdherenceStats {
  final int totalReminders;
  final int completedReminders;
  final int pendingReminders;
  final double adherenceRate; // 0.0 to 100.0%

  const PatientAdherenceStats({
    required this.totalReminders,
    required this.completedReminders,
    required this.pendingReminders,
    required this.adherenceRate,
  });

  factory PatientAdherenceStats.empty() {
    return const PatientAdherenceStats(
      totalReminders: 0,
      completedReminders: 0,
      pendingReminders: 0,
      adherenceRate: 100.0,
    );
  }
}

/// Comprehensive patient clinical & longitudinal summary for Health Worker monitoring
class PatientClinicalSummary {
  final UserModel patient;
  final int totalSessions;
  final double avgAccuracy;
  final int avgLatencyMs;
  final double avgErrorRate;
  final int totalPlaytimeSeconds;
  final String? lastActiveDate;
  final List<GamePerformanceMetric> gameMetrics;
  final Map<String, double> levelProgressions; // gameType -> maxUnlockedLevel (1.0 - 5.0)
  final PatientAdherenceStats adherence;
  final List<ClinicalObservation> observations;
  final List<WellbeingModel> wellbeingHistory;
  final List<GameSessionModel> allSessions;

  const PatientClinicalSummary({
    required this.patient,
    required this.totalSessions,
    required this.avgAccuracy,
    required this.avgLatencyMs,
    required this.avgErrorRate,
    required this.totalPlaytimeSeconds,
    this.lastActiveDate,
    required this.gameMetrics,
    required this.levelProgressions,
    required this.adherence,
    required this.observations,
    required this.wellbeingHistory,
    required this.allSessions,
  });
}
