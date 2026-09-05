// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:math';

import '../../games/data/game_session_repository.dart';
import '../../games/domain/game_session_model.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../reminders/domain/reminder_model.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../../wellbeing/domain/wellbeing_model.dart';
import '../domain/personalization_models.dart';

/// The engine responsible for deriving activity profiles and game recommendations
/// based strictly on offline historical telemetry (deterministic heuristics).
class PersonalizationService {
  final GameSessionRepository _gameRepo;
  final ReminderRepository _reminderRepo;
  final WellbeingRepository _wellbeingRepo;

  // Thresholds for Level Recommendations
  static const double _strongPerformanceThreshold = 80.0;
  static const double _strugglingPerformanceThreshold = 60.0;
  
  PersonalizationService(this._gameRepo, this._reminderRepo, this._wellbeingRepo);

  /// Analyzes the user's entire local history to build a holistic Activity Profile
  Future<PatientActivityProfile> derivePatientActivityProfile(String userId) async {
    final sessions = await _gameRepo.getSessionHistory(userId, limit: 100);
    final reminders = await _reminderRepo.getRemindersForUser(userId); // Fetches all
    
    if (sessions.isEmpty) {
      return PatientActivityProfile.empty();
    }

    final preferredTime = _calculatePreferredTime(sessions);
    final typicalLength = _calculateTypicalSessionLength(sessions);
    final domainMap = _calculateDomainFrequency(sessions);
    final adherence = _calculateReminderAdherence(reminders);

    // Find most practiced and strongest
    String mostPracticed = 'None';
    int maxSessions = 0;
    
    final Map<String, List<double>> gameScores = {};
    final Map<String, int> gameCounts = {};

    for (final s in sessions) {
      final domain = CognitiveDomains.getDomainForGame(s.gameType);
      if (domainMap[domain] != null && domainMap[domain]! > maxSessions) {
        maxSessions = domainMap[domain]!;
        mostPracticed = domain;
      }
      
      gameScores.putIfAbsent(s.gameType, () => []).add(s.cvsScore);
      gameCounts[s.gameType] = (gameCounts[s.gameType] ?? 0) + 1;
    }

    String strongestActivity = 'None';
    double highestAvgScore = 0;
    String practiceArea = 'None';
    double lowestAvgScore = 100;
    
    double totalDifficulty = 0;

    gameScores.forEach((game, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg >= highestAvgScore) {
        highestAvgScore = avg;
        strongestActivity = CognitiveDomains.getGameName(game);
      }
      if (avg <= lowestAvgScore) {
        lowestAvgScore = avg;
        practiceArea = CognitiveDomains.getGameName(game);
      }
    });

    for (final s in sessions) {
      totalDifficulty += s.difficultyLevel;
    }
    
    final avgDifficulty = totalDifficulty / sessions.length;

    // Trend analysis (compare last 3 sessions to the rest)
    String trend = 'Stable';
    if (sessions.length >= 6) {
      final recent = sessions.sublist(sessions.length - 3);
      final older = sessions.sublist(0, sessions.length - 3);
      final recentAvg = recent.map((e) => e.cvsScore).reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.map((e) => e.cvsScore).reduce((a, b) => a + b) / older.length;
      if (recentAvg > olderAvg + 5) trend = 'Improving';
      else if (recentAvg < olderAvg - 5) trend = 'Needs Encouragement';
    }

    String engagement = 'Low';
    if (sessions.length > 10) engagement = 'Moderate';
    if (sessions.length > 20) engagement = 'High';

    return PatientActivityProfile(
      preferredActivityTime: preferredTime,
      mostPracticedDomain: mostPracticed,
      strongestActivity: strongestActivity,
      practiceArea: practiceArea,
      currentAverageDifficulty: double.parse(avgDifficulty.toStringAsFixed(1)),
      typicalSessionLength: typicalLength,
      weeklyEngagement: engagement,
      reminderAdherencePercentage: double.parse(adherence.toStringAsFixed(1)),
      recentActivityTrend: trend,
    );
  }

  /// Evaluates game-specific historical performance
  Future<GamePerformanceProfile?> getGamePerformance(String userId, String gameType) async {
    final sessions = await _gameRepo.getSessionHistory(userId, limit: 50);
    final gameSessions = sessions.where((s) => s.gameType == gameType).toList();
    
    if (gameSessions.isEmpty) return null;

    final highestLevel = gameSessions.map((s) => s.difficultyLevel).reduce(max);
    final currentLevel = gameSessions.last.difficultyLevel;

    final historicalAvg = gameSessions.map((s) => s.cvsScore).reduce((a, b) => a + b) / gameSessions.length;
    
    // Recent performance (last 3)
    final recentSessions = gameSessions.length > 3 ? gameSessions.sublist(gameSessions.length - 3) : gameSessions;
    final recentAvg = recentSessions.map((s) => s.cvsScore).reduce((a, b) => a + b) / recentSessions.length;

    // Standard deviation proxy for consistency
    String consistency = 'Moderate';
    if (recentSessions.length >= 3) {
      final diffs = recentSessions.map((s) => (s.cvsScore - recentAvg).abs()).toList();
      final avgDiff = diffs.reduce((a, b) => a + b) / diffs.length;
      if (avgDiff < 5) consistency = 'High';
      else if (avgDiff > 15) consistency = 'Low';
    }

    String trend = 'Stable';
    if (recentAvg > historicalAvg + 5) trend = 'Improving';
    else if (recentAvg < historicalAvg - 5) trend = 'Struggling';

    double recommendedLevel = currentLevel;
    if (recentSessions.length >= 2) {
      if (recentAvg >= _strongPerformanceThreshold && consistency != 'Low') {
        recommendedLevel = min(5.0, currentLevel + 1.0);
      } else if (recentAvg < _strugglingPerformanceThreshold) {
        recommendedLevel = max(1.0, currentLevel - 1.0);
      }
    }

    return GamePerformanceProfile(
      gameType: gameType,
      currentLevel: currentLevel,
      highestLevel: highestLevel,
      recentAverageScore: recentAvg,
      historicalAverage: historicalAvg,
      consistency: consistency,
      trend: trend,
      recommendedLevel: recommendedLevel,
    );
  }

  /// Calculates the best activity for the user right now based on telemetry
  Future<PersonalizationRecommendation> getRecommendedActivity(String userId) async {
    final sessions = await _gameRepo.getSessionHistory(userId, limit: 20);
    
    // COLD START: Cycle through games if we don't have a solid baseline
    if (sessions.length < 6) {
      final playedTypes = sessions.map((s) => s.gameType).toSet();
      final unplayed = CognitiveDomains.allGameTypes.where((t) => !playedTypes.contains(t)).toList();
      
      String nextGame = unplayed.isNotEmpty ? unplayed.first : CognitiveDomains.allGameTypes[Random().nextInt(CognitiveDomains.allGameTypes.length)];
      
      return PersonalizationRecommendation(
        recommendedGameType: nextGame,
        recommendedLevel: 1.0,
        reason: "We're still learning what activities you prefer.",
        estimatedMinutes: 5,
        isColdStart: true,
      );
    }

    // Determine least recently played domain to balance cognitive load
    final recentGames = sessions.sublist(max(0, sessions.length - 10)).map((s) => s.gameType).toList();
    final domainFreq = <String, int>{};
    for (var game in recentGames) {
      final domain = CognitiveDomains.getDomainForGame(game);
      domainFreq[domain] = (domainFreq[domain] ?? 0) + 1;
    }

    String targetDomain = CognitiveDomains.memory;
    int minPlays = 999;
    
    final allDomains = [
      CognitiveDomains.memory,
      CognitiveDomains.attention,
      CognitiveDomains.reasoning,
      CognitiveDomains.language,
      CognitiveDomains.everydayThinking
    ];

    for (var d in allDomains) {
      final plays = domainFreq[d] ?? 0;
      if (plays < minPlays) {
        minPlays = plays;
        targetDomain = d;
      }
    }

    // Find a game matching the target domain that hasn't been played *immediately* last
    String targetGame = CognitiveDomains.allGameTypes.firstWhere((g) => CognitiveDomains.getDomainForGame(g) == targetDomain, orElse: () => CognitiveDomains.allGameTypes.first);
    if (sessions.last.gameType == targetGame) {
       // Just played it, pick another in same domain or random if none
       final alternatives = CognitiveDomains.allGameTypes.where((g) => CognitiveDomains.getDomainForGame(g) == targetDomain && g != targetGame).toList();
       if (alternatives.isNotEmpty) targetGame = alternatives.first;
    }

    // Get performance profile for this target game
    final profile = await getGamePerformance(userId, targetGame);
    double recommendedLvl = profile?.recommendedLevel ?? 1.0;

    // Check recent wellbeing to gently adjust expectation without medicalizing
    final wellbeing = await _wellbeingRepo.getRecentCheckIns(userId, limit: 1);
    String contextualReason = "$targetDomain activities could use a little more practice today.";
    
    if (wellbeing.isNotEmpty && wellbeing.first.status == 'not_great') {
      recommendedLvl = max(1.0, recommendedLvl - 1.0);
      contextualReason = "A gentle activity to keep the mind engaged.";
    } else if (profile != null && profile.recentAverageScore >= 80) {
      contextualReason = "You've been performing strongly in $targetDomain tasks.";
    }

    int estMinutes = _parseTypicalSessionToMinutes(_calculateTypicalSessionLength(sessions));

    return PersonalizationRecommendation(
      recommendedGameType: targetGame,
      recommendedLevel: recommendedLvl,
      reason: contextualReason,
      estimatedMinutes: estMinutes,
      isColdStart: false,
    );
  }

  // --- Internal Helper Methods ---

  String _calculatePreferredTime(List<GameSessionModel> sessions) {
    if (sessions.length < 5) return 'Varied';
    
    int morning = 0; // 5-12
    int afternoon = 0; // 12-17
    int evening = 0; // 17-23

    for (var s in sessions) {
      final dt = DateTime.tryParse(s.timestamp)?.toLocal();
      if (dt != null) {
        if (dt.hour >= 5 && dt.hour < 12) morning++;
        else if (dt.hour >= 12 && dt.hour < 17) afternoon++;
        else evening++;
      }
    }

    final total = sessions.length;
    if (morning / total > 0.5) return 'Morning';
    if (afternoon / total > 0.5) return 'Afternoon';
    if (evening / total > 0.5) return 'Evening';
    return 'Varied';
  }

  String _calculateTypicalSessionLength(List<GameSessionModel> sessions) {
    if (sessions.isEmpty) return '5 minutes';
    final totalSeconds = sessions.map((s) => s.durationSeconds).reduce((a, b) => a + b);
    final avgMinutes = (totalSeconds / sessions.length) / 60.0;
    
    if (avgMinutes < 3) return '1-3 minutes';
    if (avgMinutes < 7) return '5-7 minutes';
    return '10+ minutes';
  }
  
  int _parseTypicalSessionToMinutes(String typical) {
    if (typical.contains('1-3')) return 3;
    if (typical.contains('10+')) return 10;
    return 5;
  }

  Map<String, int> _calculateDomainFrequency(List<GameSessionModel> sessions) {
    final map = <String, int>{};
    for (var s in sessions) {
      final domain = CognitiveDomains.getDomainForGame(s.gameType);
      map[domain] = (map[domain] ?? 0) + 1;
    }
    return map;
  }

  double _calculateReminderAdherence(List<ReminderModel> reminders) {
    if (reminders.isEmpty) return 100.0;
    
    int done = 0;
    for (var r in reminders) {
      if (r.status == 'done') done++;
    }
    return (done / reminders.length) * 100;
  }
}
