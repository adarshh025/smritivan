// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../games/data/game_session_repository.dart';
import '../../games/domain/game_session.dart';
import '../../personalization/domain/personalization_models.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../data/caregiver_alert_repository.dart';
import '../domain/caregiver_alert.dart';

class AlertConfig {
  static const int minSessionsForBaseline = 5;
  static const int recentWindowSize = 3;
  static const double performanceDropThreshold = 15.0; // 15% drop compared to baseline
  static const int inactivityDaysThreshold = 3;
  static const double reminderMissRateThreshold = 0.3; // 30% miss rate
}

final caregiverAlertServiceProvider = Provider<CaregiverAlertService>((ref) {
  final alertRepo = ref.watch(caregiverAlertRepositoryProvider);
  final gameRepo = ref.watch(gameSessionRepositoryProvider);
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final wellbeingRepo = ref.watch(wellbeingRepositoryProvider);

  return CaregiverAlertService(alertRepo, gameRepo, reminderRepo, wellbeingRepo);
});

class CaregiverAlertService {
  final CaregiverAlertRepository _alertRepo;
  final GameSessionRepository _gameRepo;
  final ReminderRepository _reminderRepo;
  final WellbeingRepository _wellbeingRepo;

  CaregiverAlertService(
    this._alertRepo,
    this._gameRepo,
    this._reminderRepo,
    this._wellbeingRepo,
  );

  /// Analyzes telemetry data and emits rule-based caregiver insights. 
  /// Does NOT diagnose or claim medical conclusions.
  Future<void> generateInsights(String userId) async {
    await _analyzeGamePerformanceAndInactivity(userId);
    await _analyzeReminderAdherence(userId);
    await _analyzeWellbeing(userId);
  }

  Future<void> _analyzeGamePerformanceAndInactivity(String userId) async {
    final allSessions = await _gameRepo.getSessionHistory(userId, limit: 100);
    
    // Inactivity Check
    if (allSessions.isNotEmpty) {
      final lastSessionDate = DateTime.parse(allSessions.first.timestamp);
      final daysSince = DateTime.now().difference(lastSessionDate).inDays;
      
      if (daysSince >= AlertConfig.inactivityDaysThreshold) {
        await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.engagement,
          urgency: AlertUrgency.attention,
          title: "Decreased Activity",
          description: "No cognitive activities have been completed in the last $daysSince days.",
          suggestedAction: "Consider encouraging a short activity.",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      } else if (daysSince == 0 && allSessions.length >= 2) {
        // Positive insight for recent play
        await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.engagement,
          urgency: AlertUrgency.info,
          title: "Consistent Activity",
          description: "Patient has completed cognitive activities recently.",
          suggestedAction: "Great engagement!",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      }
    }

    // Per-game Performance Check
    final Map<String, List<GameSession>> sessionsByType = {};
    for (var s in allSessions) {
      sessionsByType.putIfAbsent(s.gameType, () => []).add(s);
    }

    for (var entry in sessionsByType.entries) {
      final type = entry.key;
      final sessions = entry.value;

      if (sessions.length < AlertConfig.minSessionsForBaseline + AlertConfig.recentWindowSize) {
        continue; // Not enough data for personal baseline
      }

      final recent = sessions.take(AlertConfig.recentWindowSize).toList();
      final baseline = sessions.skip(AlertConfig.recentWindowSize).take(AlertConfig.minSessionsForBaseline).toList();

      double recentAvg = recent.fold(0.0, (sum, s) => sum + s.cvsScore) / recent.length;
      double baselineAvg = baseline.fold(0.0, (sum, s) => sum + s.cvsScore) / baseline.length;

      final gameName = CognitiveDomains.getGameName(type);

      if (recentAvg < (baselineAvg - AlertConfig.performanceDropThreshold)) {
        await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.cognitive,
          urgency: AlertUrgency.attention,
          title: "Performance Pattern",
          description: "$gameName performance has been lower than the patient's recent baseline across several sessions.",
          suggestedAction: "Check if the patient was tired or distracted.",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      } else if (recentAvg > (baselineAvg + 10)) {
        await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.cognitive,
          urgency: AlertUrgency.info,
          title: "Performance Improving",
          description: "$gameName performance has improved compared to recent sessions.",
          suggestedAction: "Praise the patient for their progress.",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _analyzeReminderAdherence(String userId) async {
    final reminders = await _reminderRepo.getRemindersForUser(userId);
    // In a real app we'd look at past history instances, but here our MVP reminders act as stateful items.
    // We'll evaluate how many are overdue.
    int missedCount = 0;
    int completedCount = 0;

    for (var r in reminders) {
      if (r.status == 'done') completedCount++;
      else if (r.status == 'pending') {
        // Check if overdue by parsing time string - simple heuristic for MVP
        final timeParts = r.time.split(':');
        DateTime dt = DateTime.now();
        if (timeParts.length == 2) {
          int hour = int.tryParse(timeParts[0]) ?? 9;
          if (r.time.toLowerCase().contains('pm') && hour < 12) hour += 12;
          if (r.time.toLowerCase().contains('am') && hour == 12) hour = 0;
          dt = DateTime(dt.year, dt.month, dt.day, hour, 0);
          
          if (dt.isBefore(DateTime.now())) {
            missedCount++;
          }
        }
      }
    }

    final totalDue = completedCount + missedCount;
    if (totalDue > 0) {
      final missRate = missedCount / totalDue;
      if (missRate > AlertConfig.reminderMissRateThreshold) {
        await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.reminder,
          urgency: AlertUrgency.attention,
          title: "Reminder Adherence",
          description: "Several reminders have been missed recently ($missedCount missed).",
          suggestedAction: "Review reminders to ensure the schedule works for the patient.",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      } else if (missRate == 0 && totalDue >= 2) {
         await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.reminder,
          urgency: AlertUrgency.info,
          title: "Good Adherence",
          description: "Patient has completed all recent reminders.",
          suggestedAction: "Great routine maintenance.",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _analyzeWellbeing(String userId) async {
    final checkins = await _wellbeingRepo.getRecentCheckIns(userId, limit: 3);
    if (checkins.length == 3) {
      final allNegative = checkins.every((c) => c.status == 'tired_not_great' || c.status == 'confused_lost');
      if (allNegative) {
        await _alertRepo.emitAlert(CaregiverAlert(
          alertId: '',
          userId: userId,
          category: AlertCategory.wellbeing,
          urgency: AlertUrgency.attention,
          title: "Well-being Pattern",
          description: "Recent well-being check-ins have consistently indicated tiredness or confusion.",
          suggestedAction: "Consider reaching out or scheduling rest time.",
          firstDetected: DateTime.now(),
          lastUpdated: DateTime.now(),
        ));
      }
    }
  }
}
