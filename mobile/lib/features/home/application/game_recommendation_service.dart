// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameRecommendationService {
  
  /// Determines the best next game based on simple heuristics.
  /// If the user struggled with visual memory recently, recommend auditory focus.
  String recommendNextGame(List<Map<String, dynamic>> recentSessions) {
    if (recentSessions.isEmpty) {
      return 'visual_memory'; // Default starting point
    }

    final lastSession = recentSessions.last;
    final lastGameType = lastSession['gameType'] as String;
    final lastSuccessRate = lastSession['successRate'] as double;
    final lastCvs = lastSession['cvs'] as double;

    // If fatigue or frustration is detected (low success/cvs), switch domains
    if (lastSuccessRate < 0.4 || lastCvs < 40.0) {
      return _switchDomain(lastGameType);
    }

    // Otherwise, continue or rotate naturally
    return lastGameType;
  }

  String _switchDomain(String currentGame) {
    switch (currentGame) {
      case 'visual_memory':
        return 'auditory_focus';
      case 'auditory_focus':
        return 'routine_recall';
      default:
        return 'visual_memory';
    }
  }
}

final gameRecommendationProvider = Provider((ref) => GameRecommendationService());

