// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

/// Represents derived activity metrics across the platform.
/// This is NOT a medical diagnosis, just behavioral heuristics for UI adaptation.
class PatientActivityProfile {
  final String preferredActivityTime; // "Morning", "Afternoon", "Evening", or "Varied"
  final String mostPracticedDomain; // e.g. "Memory"
  final String strongestActivity; // e.g. "Word Garden"
  final String practiceArea; // the domain/game needing most work
  final double currentAverageDifficulty;
  final String typicalSessionLength; // e.g. "5-7 minutes"
  final String weeklyEngagement; // "High", "Moderate", "Low"
  final double reminderAdherencePercentage;
  final String recentActivityTrend; // "Improving", "Stable", "Needs Encouragement"

  const PatientActivityProfile({
    required this.preferredActivityTime,
    required this.mostPracticedDomain,
    required this.strongestActivity,
    required this.practiceArea,
    required this.currentAverageDifficulty,
    required this.typicalSessionLength,
    required this.weeklyEngagement,
    required this.reminderAdherencePercentage,
    required this.recentActivityTrend,
  });

  PatientActivityProfile copyWith({
    String? preferredActivityTime,
    String? mostPracticedDomain,
    String? strongestActivity,
    String? practiceArea,
    double? currentAverageDifficulty,
    String? typicalSessionLength,
    String? weeklyEngagement,
    double? reminderAdherencePercentage,
    String? recentActivityTrend,
  }) {
    return PatientActivityProfile(
      preferredActivityTime: preferredActivityTime ?? this.preferredActivityTime,
      mostPracticedDomain: mostPracticedDomain ?? this.mostPracticedDomain,
      strongestActivity: strongestActivity ?? this.strongestActivity,
      practiceArea: practiceArea ?? this.practiceArea,
      currentAverageDifficulty: currentAverageDifficulty ?? this.currentAverageDifficulty,
      typicalSessionLength: typicalSessionLength ?? this.typicalSessionLength,
      weeklyEngagement: weeklyEngagement ?? this.weeklyEngagement,
      reminderAdherencePercentage: reminderAdherencePercentage ?? this.reminderAdherencePercentage,
      recentActivityTrend: recentActivityTrend ?? this.recentActivityTrend,
    );
  }

  factory PatientActivityProfile.empty() {
    return const PatientActivityProfile(
      preferredActivityTime: 'Varied',
      mostPracticedDomain: 'None',
      strongestActivity: 'None',
      practiceArea: 'None',
      currentAverageDifficulty: 1.0,
      typicalSessionLength: 'Unknown',
      weeklyEngagement: 'Low',
      reminderAdherencePercentage: 0.0,
      recentActivityTrend: 'Stable',
    );
  }
}

class GamePerformanceProfile {
  final String gameType;
  final double currentLevel;
  final double highestLevel;
  final double recentAverageScore; // using cvsScore as accuracy metric (0-100)
  final double historicalAverage;
  final String consistency; // "High", "Moderate", "Low"
  final String trend; // "Improving", "Stable", "Struggling"
  final double recommendedLevel;

  const GamePerformanceProfile({
    required this.gameType,
    required this.currentLevel,
    required this.highestLevel,
    required this.recentAverageScore,
    required this.historicalAverage,
    required this.consistency,
    required this.trend,
    required this.recommendedLevel,
  });
}

class PersonalizationRecommendation {
  final String recommendedGameType;
  final double recommendedLevel;
  final String reason;
  final int estimatedMinutes;
  final bool isColdStart;

  const PersonalizationRecommendation({
    required this.recommendedGameType,
    required this.recommendedLevel,
    required this.reason,
    required this.estimatedMinutes,
    this.isColdStart = false,
  });
}

/// Constants defining cognitive domains mapped to our specific games
class CognitiveDomains {
  static const String memory = 'Memory';
  static const String attention = 'Attention';
  static const String reasoning = 'Reasoning';
  static const String language = 'Language';
  static const String everydayThinking = 'Everyday Thinking';

  static String getDomainForGame(String gameType) {
    switch (gameType) {
      case 'memory_match':
        return memory;
      case 'picture_recall':
        return memory;
      case 'card_recall':
        return attention;
      case 'pattern_builder':
        return reasoning;
      case 'word_garden':
        return language;
      case 'daily_helper':
        return everydayThinking;
      default:
        return 'General';
    }
  }

  static String getGameName(String gameType) {
    switch (gameType) {
      case 'memory_match':
        return 'Memory Match';
      case 'picture_recall':
        return 'Picture Recall';
      case 'card_recall':
        return 'Card Recall';
      case 'pattern_builder':
        return 'Pattern Builder';
      case 'word_garden':
        return 'Word Garden';
      case 'daily_helper':
        return 'Daily Helper';
      default:
        return 'Activity';
    }
  }

  static List<String> get allGameTypes => [
        'memory_match',
        'picture_recall',
        'pattern_builder',
        'word_garden',
        'card_recall',
        'daily_helper',
      ];
}
