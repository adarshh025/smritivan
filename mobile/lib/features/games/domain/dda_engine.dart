// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:math';
import 'dda_parameters.dart';

/// DDA Calculation Output Result
class DDAResult {
  final double nextDifficulty; // D_(t+1)
  final double currentDifficulty; // D_t
  final double successRate; // P_success
  final double normalizedLatency; // T_latency
  final double errorRate; // E_rate
  final double cvsScore; // Cognitive Vitality Score (0-100)
  final bool shouldTriggerCaregiverAlert;
  final String? alertReason;
  final String? alertUrgency; // 'LOW', 'MEDIUM', 'HIGH'

  const DDAResult({
    required this.nextDifficulty,
    required this.currentDifficulty,
    required this.successRate,
    required this.normalizedLatency,
    required this.errorRate,
    required this.cvsScore,
    required this.shouldTriggerCaregiverAlert,
    this.alertReason,
    this.alertUrgency,
  });
}

/// Core AI Dynamic Difficulty Adjustment Engine
/// Implements Reinforcement Heuristic: D_(t+1) = D_t + α(P_success - P_target) - β(T_latency + E_rate)
class DDAEngine {
  DDAEngine._();

  /// Computes the next session difficulty, CVS score, and checks for cognitive anomalies
  static DDAResult calculate({
    required double currentDifficulty,
    required int totalAttempts,
    required int correctMatches,
    required int mistakes,
    required int averageReactionTimeMs,
    required DDAParameters params,
    double? previousCvsScore,
  }) {
    // 1. Calculate P_success (Completion rate: 0.0 -> 1.0)
    final double successRate = totalAttempts > 0
        ? (correctMatches / max(1, (correctMatches + mistakes))).clamp(0.0, 1.0)
        : 0.0;

    // 2. Calculate E_rate (Error rate: 0.0 -> 1.0)
    final double errorRate = totalAttempts > 0
        ? (mistakes / max(1, totalAttempts)).clamp(0.0, 1.0)
        : 0.0;

    // 3. Normalize Reaction Latency T_latency to [0.0, 1.0]
    final double rawLatencyDelta = (averageReactionTimeMs - params.baselineReactionMs).toDouble();
    final double latencyRange = (params.maxAcceptableReactionMs - params.baselineReactionMs).toDouble();
    final double normalizedLatency = (rawLatencyDelta / max(1.0, latencyRange)).clamp(0.0, 1.0);

    // 4. Calculate D_(t+1) using formula: D_t + α(P_success - P_target) - β(T_latency + E_rate)
    final double performanceAdvancement = params.alpha * (successRate - params.targetSuccessRate);
    final double fatiguePenalty = params.beta * (normalizedLatency + errorRate);

    final double calculatedNextDifficulty = currentDifficulty + performanceAdvancement - fatiguePenalty;
    final double clampedNextDifficulty = calculatedNextDifficulty.clamp(
      params.minDifficulty,
      params.maxDifficulty,
    );

    // 5. Calculate Cognitive Vitality Score (CVS) (0.0 to 100.0)
    // Multi-factor clinical weighting: Success (40%), Accuracy (30%), Speed (20%), Challenge (10%)
    final double cvsComponentSuccess = 0.40 * successRate;
    final double cvsComponentAccuracy = 0.30 * (1.0 - errorRate);
    final double cvsComponentSpeed = 0.20 * (1.0 - normalizedLatency);
    final double cvsComponentDifficulty = 0.10 * (currentDifficulty / params.maxDifficulty);

    final double cvsScore = ((cvsComponentSuccess + cvsComponentAccuracy + cvsComponentSpeed + cvsComponentDifficulty) * 100.0)
        .clamp(0.0, 100.0);

    // 6. Clinical Anomaly & Delirium/Sundowning Detection
    bool triggerAlert = false;
    String? alertReason;
    String? alertUrgency;

    if (cvsScore < 30.0 && mistakes >= 4) {
      triggerAlert = true;
      alertReason = 'Acute Cognitive Drop: CVS score plummeted to ${cvsScore.toStringAsFixed(1)}/100 with excessive errors.';
      alertUrgency = 'HIGH';
    } else if (previousCvsScore != null && (previousCvsScore - cvsScore) > 25.0) {
      triggerAlert = true;
      alertReason = 'Rapid Cognitive Shift: Sudden 25%+ drop from baseline session ($previousCvsScore -> ${cvsScore.toStringAsFixed(1)}).';
      alertUrgency = 'HIGH';
    } else if (averageReactionTimeMs > params.maxAcceptableReactionMs) {
      triggerAlert = true;
      alertReason = 'Severe Reaction Delay: Response latency ($averageReactionTimeMs ms) indicates motor hesitation or disorientation.';
      alertUrgency = 'MEDIUM';
    }

    return DDAResult(
      nextDifficulty: double.parse(clampedNextDifficulty.toStringAsFixed(2)),
      currentDifficulty: currentDifficulty,
      successRate: double.parse(successRate.toStringAsFixed(3)),
      normalizedLatency: double.parse(normalizedLatency.toStringAsFixed(3)),
      errorRate: double.parse(errorRate.toStringAsFixed(3)),
      cvsScore: double.parse(cvsScore.toStringAsFixed(1)),
      shouldTriggerCaregiverAlert: triggerAlert,
      alertReason: alertReason,
      alertUrgency: alertUrgency,
    );
  }
}

