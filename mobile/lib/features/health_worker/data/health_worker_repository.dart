// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:shared_preferences/shared_preferences.dart';
import '../../auth_profile/data/user_repository.dart';
import '../../auth_profile/domain/user_model.dart';
import '../../games/data/game_session_repository.dart';
import '../../games/core/game_progression_service.dart';
import '../../games/domain/game_session_model.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../domain/health_worker_model.dart';

class HealthWorkerRepository {
  final UserRepository _userRepo;
  final GameSessionRepository _gameSessionRepo;
  final ReminderRepository _reminderRepo;
  final WellbeingRepository _wellbeingRepo;
  final GameProgressionService _progressionService;

  HealthWorkerRepository({
    required UserRepository userRepo,
    required GameSessionRepository gameSessionRepo,
    required ReminderRepository reminderRepo,
    required WellbeingRepository wellbeingRepo,
    required GameProgressionService progressionService,
  })  : _userRepo = userRepo,
        _gameSessionRepo = gameSessionRepo,
        _reminderRepo = reminderRepo,
        _wellbeingRepo = wellbeingRepo,
        _progressionService = progressionService;

  static const String _prefKeyWorkerPin = 'health_worker_pin';
  static const String _prefKeyWorkerProfile = 'health_worker_profile_data';
  static const String _defaultPin = '1234';

  /// Verifies entered Health Worker PIN
  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_prefKeyWorkerPin) ?? _defaultPin;
    return pin == savedPin;
  }

  /// Sets or updates the Health Worker authorization PIN
  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyWorkerPin, newPin);
  }

  /// Retrieves active Health Worker profile metadata
  Future<HealthWorkerProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('${_prefKeyWorkerProfile}_name');
    if (name == null || name.isEmpty) {
      return HealthWorkerProfile.defaultWorker();
    }
    return HealthWorkerProfile(
      id: prefs.getString('${_prefKeyWorkerProfile}_id') ?? 'hw_ner_01',
      workerId: prefs.getString('${_prefKeyWorkerProfile}_workerId') ?? 'NHM-NER-2026',
      name: name,
      designation: prefs.getString('${_prefKeyWorkerProfile}_designation') ?? 'Cognitive Care Coordinator',
      facilityName: prefs.getString('${_prefKeyWorkerProfile}_facility') ?? 'Community Health Centre (NER)',
      state: prefs.getString('${_prefKeyWorkerProfile}_state') ?? 'Assam',
      phone: prefs.getString('${_prefKeyWorkerProfile}_phone'),
      email: prefs.getString('${_prefKeyWorkerProfile}_email'),
      registeredAt: prefs.getString('${_prefKeyWorkerProfile}_registeredAt') ?? DateTime.now().toIso8601String(),
    );
  }

  /// Persists updated Health Worker profile
  Future<void> saveProfile(HealthWorkerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefKeyWorkerProfile}_id', profile.id);
    await prefs.setString('${_prefKeyWorkerProfile}_workerId', profile.workerId);
    await prefs.setString('${_prefKeyWorkerProfile}_name', profile.name);
    await prefs.setString('${_prefKeyWorkerProfile}_designation', profile.designation);
    await prefs.setString('${_prefKeyWorkerProfile}_facility', profile.facilityName);
    await prefs.setString('${_prefKeyWorkerProfile}_state', profile.state);
    if (profile.phone != null) await prefs.setString('${_prefKeyWorkerProfile}_phone', profile.phone!);
    if (profile.email != null) await prefs.setString('${_prefKeyWorkerProfile}_email', profile.email!);
    await prefs.setString('${_prefKeyWorkerProfile}_registeredAt', profile.registeredAt);
  }

  /// Retrieves all authorized registered patients in the SQLite database
  Future<List<UserModel>> getAllPatients() async {
    final list = await _userRepo.getAllPatients();
    if (list.isEmpty) {
      // Fallback to active patient if query was empty
      final active = await _userRepo.getActivePatient();
      if (active != null) return [active];
    }
    return list;
  }

  /// Queries comprehensive clinical & longitudinal telemetry for a specific patient
  Future<PatientClinicalSummary> getPatientClinicalSummary(String patientId) async {
    UserModel? patient = await _userRepo.getPatientById(patientId);
    patient ??= await _userRepo.getActivePatient();
    patient ??= UserModel(
      id: patientId,
      name: 'Unknown Patient',
      nativeLanguage: 'as',
      state: 'Assam',
      dementiaStage: 'Early-Stage MCI',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      hlcTimestamp: '',
    );

    // 1. Fetch real session history & aggregate stats
    final allSessions = await _gameSessionRepo.getSessionHistory(patientId, limit: 200);
    final aggregateStats = await _gameSessionRepo.getAggregateStats(patientId);

    final totalSessions = aggregateStats['total_sessions'] as int? ?? allSessions.length;
    final avgAccuracy = allSessions.isEmpty
        ? 0.0
        : (allSessions.map((s) => (1.0 - s.errorRate) * 100.0).reduce((a, b) => a + b) / allSessions.length).clamp(0.0, 100.0);
    final avgLatency = aggregateStats['avg_latency'] as int? ?? 0;
    final avgErrorRate = aggregateStats['avg_error_rate'] as double? ?? 0.0;
    final totalPlaytime = aggregateStats['total_duration_seconds'] as int? ?? 0;
    final lastActiveDate = allSessions.isNotEmpty ? allSessions.first.timestamp : null;

    // 2. Compute Level Progression for all 6 Games
    final gameConfigs = [
      {'type': 'memory_match', 'title': 'Memory Match', 'icon': '🎴'},
      {'type': 'picture_recall', 'title': 'Picture Recall', 'icon': '🖼️'},
      {'type': 'pattern_builder', 'title': 'Pattern Builder', 'icon': '🧩'},
      {'type': 'word_garden', 'title': 'Word Garden', 'icon': '🔤'},
      {'type': 'card_recall', 'title': 'Card Recall', 'icon': '🃏'},
      {'type': 'daily_helper', 'title': 'Daily Helper', 'icon': '🛒'},
    ];

    final Map<String, double> levelProgressions = {};
    final List<GamePerformanceMetric> gameMetrics = [];

    for (final cfg in gameConfigs) {
      final gType = cfg['type']!;
      final gTitle = cfg['title']!;
      final gIcon = cfg['icon']!;

      final unlockedLevel = await _progressionService.getUnlockedLevel(patientId, gType);
      levelProgressions[gType] = unlockedLevel;

      final gSessions = allSessions.where((s) => s.gameType == gType).toList();
      if (gSessions.isEmpty) {
        gameMetrics.add(GamePerformanceMetric(
          gameType: gType,
          title: gTitle,
          icon: gIcon,
          totalSessions: 0,
          maxLevelUnlocked: unlockedLevel,
          avgAccuracy: 0.0,
          avgErrorRate: 0.0,
          avgLatencyMs: 0,
          bestAccuracy: 0.0,
          recentAccuracy: 0.0,
          totalPlaytimeSeconds: 0,
        ));
      } else {
        final accuracies = gSessions.map((s) => (1.0 - s.errorRate) * 100.0).toList();
        final gAvgAcc = accuracies.reduce((a, b) => a + b) / accuracies.length;
        final bestAcc = accuracies.reduce((a, b) => a > b ? a : b);
        final recentAcc = accuracies.first;
        final gAvgErr = gSessions.map((s) => s.errorRate).reduce((a, b) => a + b) / gSessions.length;
        final gAvgLat = (gSessions.map((s) => s.reactionTimeMs).reduce((a, b) => a + b) / gSessions.length).round();
        final gPlaytime = gSessions.map((s) => s.durationSeconds).reduce((a, b) => a + b);

        gameMetrics.add(GamePerformanceMetric(
          gameType: gType,
          title: gTitle,
          icon: gIcon,
          totalSessions: gSessions.length,
          maxLevelUnlocked: unlockedLevel,
          avgAccuracy: gAvgAcc,
          avgErrorRate: gAvgErr,
          avgLatencyMs: gAvgLat,
          bestAccuracy: bestAcc,
          recentAccuracy: recentAcc,
          totalPlaytimeSeconds: gPlaytime,
        ));
      }
    }

    // 3. Reminder Adherence
    final reminders = await _reminderRepo.getRemindersForUser(patientId);
    final completedReminders = reminders.where((r) => r.status == 'done' || r.status == 'acknowledged').length;
    final totalReminders = reminders.length;
    final adherenceRate = totalReminders == 0
        ? 100.0
        : (completedReminders / totalReminders * 100.0).clamp(0.0, 100.0);

    final adherenceStats = PatientAdherenceStats(
      totalReminders: totalReminders,
      completedReminders: completedReminders,
      pendingReminders: totalReminders - completedReminders,
      adherenceRate: adherenceRate,
    );

    // 4. Wellbeing History
    final wellbeingList = await _wellbeingRepo.getRecentCheckIns(patientId, limit: 30);

    // 5. Generate Rule-Based Non-Diagnostic Clinical Observations
    final observations = _generateObservations(
      patientId: patientId,
      totalSessions: totalSessions,
      allSessions: allSessions,
      avgAccuracy: avgAccuracy,
      avgErrorRate: avgErrorRate,
      adherenceRate: adherenceRate,
      wellbeingList: wellbeingList,
      gameMetrics: gameMetrics,
    );

    return PatientClinicalSummary(
      patient: patient,
      totalSessions: totalSessions,
      avgAccuracy: avgAccuracy,
      avgLatencyMs: avgLatency,
      avgErrorRate: avgErrorRate,
      totalPlaytimeSeconds: totalPlaytime,
      lastActiveDate: lastActiveDate,
      gameMetrics: gameMetrics,
      levelProgressions: levelProgressions,
      adherence: adherenceStats,
      observations: observations,
      wellbeingHistory: wellbeingList,
      allSessions: allSessions,
    );
  }

  List<ClinicalObservation> _generateObservations({
    required String patientId,
    required int totalSessions,
    required List<GameSessionModel> allSessions,
    required double avgAccuracy,
    required double avgErrorRate,
    required double adherenceRate,
    required List<dynamic> wellbeingList,
    required List<GamePerformanceMetric> gameMetrics,
  }) {
    final List<ClinicalObservation> list = [];
    final nowStr = DateTime.now().toIso8601String();

    if (totalSessions == 0) {
      list.add(ClinicalObservation(
        id: 'obs_init_0',
        patientId: patientId,
        title: 'Initial Assessment Phase',
        message: 'No cognitive game sessions recorded yet. Encourage the patient to complete their first introductory activity.',
        severity: ObservationSeverity.neutral,
        category: 'Engagement',
        timestamp: nowStr,
        recommendation: 'Introduce Picture Recall or Memory Match at Level 1 during morning hours.',
      ));
      return list;
    }

    // 1. Engagement consistency
    final recent7d = allSessions.where((s) {
      final dt = DateTime.tryParse(s.timestamp);
      if (dt == null) return false;
      return DateTime.now().difference(dt).inDays <= 7;
    }).length;

    if (recent7d >= 5) {
      list.add(ClinicalObservation(
        id: 'obs_eng_high',
        patientId: patientId,
        title: 'High Engagement Consistency',
        message: 'Patient has completed $recent7d activities in the past 7 days, maintaining steady routine adherence.',
        severity: ObservationSeverity.positive,
        category: 'Engagement',
        timestamp: nowStr,
        recommendation: 'Maintain current routine schedule and celebrate consistency with gentle audio cues.',
      ));
    } else if (recent7d <= 1 && totalSessions > 3) {
      list.add(ClinicalObservation(
        id: 'obs_eng_low',
        patientId: patientId,
        title: 'Reduced Activity Frequency',
        message: 'Activity count decreased ($recent7d sessions in past week). May indicate fatigue or schedule disruption.',
        severity: ObservationSeverity.attention,
        category: 'Engagement',
        timestamp: nowStr,
        recommendation: 'Coordinate with family caregiver to ensure activities are scheduled during peak alert hours.',
      ));
    }

    // 2. Cognitive Accuracy & Precision
    if (avgAccuracy >= 80.0) {
      list.add(ClinicalObservation(
        id: 'obs_acc_high',
        patientId: patientId,
        title: 'Strong Task Precision',
        message: 'Average accuracy is ${avgAccuracy.toStringAsFixed(1)}% across cognitive activities, indicating high comprehension of current levels.',
        severity: ObservationSeverity.positive,
        category: 'Executive Function',
        timestamp: nowStr,
        recommendation: 'Allow adaptive progression to unlock higher challenge tiers gradually.',
      ));
    } else if (avgErrorRate > 0.40) {
      list.add(ClinicalObservation(
        id: 'obs_err_elevated',
        patientId: patientId,
        title: 'Elevated Error Rate in Complex Activities',
        message: 'Higher error rate (${(avgErrorRate * 100).toStringAsFixed(1)}%) observed in multi-step visual pattern tasks.',
        severity: ObservationSeverity.attention,
        category: 'Visual Memory',
        timestamp: nowStr,
        recommendation: 'Keep game difficulty locked at Level 1 or 2 with voice prompts enabled to reduce cognitive strain.',
      ));
    }

    // 3. Adherence Observation
    if (adherenceRate < 70.0 && adherenceRate > 0.0) {
      list.add(ClinicalObservation(
        id: 'obs_adh_low',
        patientId: patientId,
        title: 'Pending Daily Reminders Observed',
        message: 'Reminder completion rate is ${adherenceRate.toStringAsFixed(0)}%. Several daily wellness or hydration prompts remain unacknowledged.',
        severity: ObservationSeverity.attention,
        category: 'Adherence',
        timestamp: nowStr,
        recommendation: 'Review notification volume and ensure caregiver assists with physical medication verification.',
      ));
    }

    // 4. Wellbeing / Sundowning
    final lowMoods = wellbeingList.where((w) => w.status == 'low').length;
    if (lowMoods >= 2) {
      list.add(ClinicalObservation(
        id: 'obs_mood_low',
        patientId: patientId,
        title: 'Multiple Low Mood Entries Logged',
        message: 'Patient recorded $lowMoods low mood check-ins recently. Consider environmental calming factors.',
        severity: ObservationSeverity.attention,
        category: 'Wellbeing',
        timestamp: nowStr,
        recommendation: 'Encourage soothing regional music, family photo recall, and evening calm lighting.',
      ));
    }

    return list;
  }
}
