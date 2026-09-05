// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मৃতি文) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

/// Calibration weights for the Dynamic Difficulty Adjustment (DDA) Heuristic
/// D_(t+1) = D_t + α(P_success - P_target) - β(T_latency + E_rate)
class DDAParameters {
  final double alpha; // Sensitivity to success (reinforcement boost)
  final double beta; // Penalty weight for latency + error (prevent agitation)
  final double targetSuccessRate; // Optimal clinical engagement zone (default: 0.75)
  final double minDifficulty; // Minimum floor (1.0)
  final double maxDifficulty; // Maximum ceiling (5.0)
  final int baselineReactionMs; // Standard expected reaction window
  final int maxAcceptableReactionMs; // Latency saturation threshold

  const DDAParameters({
    required this.alpha,
    required this.beta,
    this.targetSuccessRate = 0.75,
    this.minDifficulty = 1.0,
    this.maxDifficulty = 5.0,
    this.baselineReactionMs = 1200,
    this.maxAcceptableReactionMs = 6000,
  });

  /// Calibrated parameters by dementia stage
  factory DDAParameters.forStage(String dementiaStage) {
    final lower = dementiaStage.toLowerCase();
    if (lower.contains('early') || lower.contains('mci')) {
      // Early Stage MCI: Moderate challenge adaptability
      return const DDAParameters(
        alpha: 0.40,
        beta: 0.25,
        targetSuccessRate: 0.75,
        baselineReactionMs: 1200,
        maxAcceptableReactionMs: 5000,
      );
    } else if (lower.contains('moderate')) {
      // Moderate Dementia: Higher penalty on fatigue to prevent frustration
      return const DDAParameters(
        alpha: 0.25,
        beta: 0.35,
        targetSuccessRate: 0.70,
        baselineReactionMs: 1800,
        maxAcceptableReactionMs: 7000,
      );
    } else {
      // Severe or Unspecified: Gentle, slow progression with low stress ceiling
      return const DDAParameters(
        alpha: 0.15,
        beta: 0.45,
        targetSuccessRate: 0.65,
        baselineReactionMs: 2500,
        maxAcceptableReactionMs: 9000,
      );
    }
  }
}

