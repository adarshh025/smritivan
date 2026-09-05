// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:math';

class AIDifficultyEngine {
  static const double minDifficulty = 1.0;
  static const double maxDifficulty = 10.0;
  
  // Hyperparameters
  static const double alpha = 2.0; // Success weight
  static const double beta = 0.5;  // Penalty weight

  /// Calculates the next difficulty based on the formula:
  /// D(t+1) = D(t) + α(P_success - P_target) - β(T_latency + E_rate)
  static double calculateNextDifficulty({
    required double currentDifficulty,
    required double successRate,
    required double targetSuccessRate, // usually ~0.7 for optimal engagement
    required double normalizedLatency, // 0.0 to 1.0 (1.0 being very slow)
    required double errorRate,
  }) {
    double rawNext = currentDifficulty + 
                     (alpha * (successRate - targetSuccessRate)) - 
                     (beta * (normalizedLatency + errorRate));
                     
    // Ensure difficulty changes gradually (max delta of 1.5 per session)
    double delta = rawNext - currentDifficulty;
    delta = delta.clamp(-1.5, 1.5);
    
    double nextDifficulty = currentDifficulty + delta;
    
    return nextDifficulty.clamp(minDifficulty, maxDifficulty);
  }

  /// Heuristic calculation for Cognitive Vitality Score (CVS)
  /// Scale of 0 - 100 based on session performance at the given difficulty
  static double calculateCVS({
    required double successRate,
    required double errorRate,
    required double normalizedLatency,
    required double difficultyLevel,
  }) {
    // Base score from success vs error
    double baseScore = (successRate * 100) - (errorRate * 50);
    
    // Time penalty
    double timePenalty = normalizedLatency * 20;
    
    // Difficulty multiplier (higher difficulty amplifies positive scores)
    double difficultyMultiplier = 1.0 + (difficultyLevel * 0.05); 
    
    double cvs = (baseScore - timePenalty) * difficultyMultiplier;
    return cvs.clamp(0.0, 100.0);
  }
}

