// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../games/data/game_session_repository.dart';
import '../../games/presentation/game_telemetry_provider.dart';

class GameProgressionService {
  final GameSessionRepository _repo;

  GameProgressionService(this._repo);

  /// Returns the maximum unlocked level for a specific game (1.0 to 5.0)
  Future<double> getUnlockedLevel(String userId, String gameType) async {
    try {
      final history = await _repo.getSessionHistory(userId, limit: 100);
      final gameHistory = history.where((h) => h.gameType == gameType).toList();

      if (gameHistory.isEmpty) return 1.0;

      double maxUnlocked = 1.0;

      for (int level = 1; level <= 4; level++) {
        // Find sessions at the current level that were successfully completed
        final sessionsAtLevel = gameHistory.where((h) => h.difficultyLevel.floor() == level && h.errorRate < 1.0).toList();
        
        // If they completed at least one session at this level, unlock next level
        if (sessionsAtLevel.isNotEmpty) {
          maxUnlocked = (level + 1).toDouble();
        } else {
          break; // Stop unlocking if criteria not met for current level
        }
      }

      return maxUnlocked.clamp(1.0, 5.0);
    } catch (_) {
      return 1.0;
    }
  }

  /// Returns the actively recommended level based on very recent performance
  Future<double> getRecommendedLevel(String userId, String gameType) async {
    try {
      final maxUnlocked = await getUnlockedLevel(userId, gameType);
      final history = await _repo.getSessionHistory(userId, limit: 10);
      final recentGames = history.where((h) => h.gameType == gameType).toList();

      if (recentGames.isEmpty) return 1.0;

      // Look at last 2 sessions
      final last2 = recentGames.take(2).toList();
      if (last2.length == 2) {
        bool bothStruggled = last2.every((s) => s.errorRate > 0.4);
        if (bothStruggled) {
          double currentLvl = last2.first.difficultyLevel;
          return (currentLvl - 1.0).clamp(1.0, maxUnlocked);
        }
      }

      // Otherwise recommend their max unlocked level
      return maxUnlocked;
    } catch (_) {
      return 1.0;
    }
  }
}

final gameProgressionProvider = Provider<GameProgressionService>((ref) {
  return GameProgressionService(ref.watch(gameSessionRepositoryProvider));
});
