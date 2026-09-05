// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/audio/haptic_service.dart';
import '../../../core/database/database_provider.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../data/caregiver_alert_repository.dart';
import '../data/game_session_repository.dart';
import '../domain/dda_engine.dart';
import '../domain/dda_parameters.dart';
import '../domain/game_session_model.dart';

/// Repository Providers
final gameSessionRepositoryProvider = Provider<GameSessionRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return GameSessionRepository(appDb);
});

final caregiverAlertRepositoryProvider = Provider<CaregiverAlertRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return CaregiverAlertRepository(appDb);
});

/// Live In-Game Telemetry State
class GameTelemetryState {
  final String sessionId;
  final String gameType;
  final double currentDifficulty;
  final int correctMatches;
  final int mistakes;
  final int totalAttempts;
  final List<int> reactionLatenciesMs;
  final DateTime? sessionStartTime;
  final DateTime? currentTurnStartTime;
  final bool isSessionActive;
  final DDAResult? lastResult;

  const GameTelemetryState({
    required this.sessionId,
    required this.gameType,
    required this.currentDifficulty,
    this.correctMatches = 0,
    this.mistakes = 0,
    this.totalAttempts = 0,
    this.reactionLatenciesMs = const [],
    this.sessionStartTime,
    this.currentTurnStartTime,
    this.isSessionActive = false,
    this.lastResult,
  });

  int get averageReactionTimeMs {
    if (reactionLatenciesMs.isEmpty) return 1500;
    final sum = reactionLatenciesMs.reduce((a, b) => a + b);
    return (sum / reactionLatenciesMs.length).round();
  }

  GameTelemetryState copyWith({
    String? sessionId,
    String? gameType,
    double? currentDifficulty,
    int? correctMatches,
    int? mistakes,
    int? totalAttempts,
    List<int>? reactionLatenciesMs,
    DateTime? sessionStartTime,
    DateTime? currentTurnStartTime,
    bool? isSessionActive,
    DDAResult? lastResult,
  }) {
    return GameTelemetryState(
      sessionId: sessionId ?? this.sessionId,
      gameType: gameType ?? this.gameType,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      correctMatches: correctMatches ?? this.correctMatches,
      mistakes: mistakes ?? this.mistakes,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      reactionLatenciesMs: reactionLatenciesMs ?? this.reactionLatenciesMs,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      currentTurnStartTime: currentTurnStartTime ?? this.currentTurnStartTime,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

/// StateNotifier that manages real-time telemetry and triggers the adaptive DDA heuristic
class GameTelemetryNotifier extends StateNotifier<GameTelemetryState> {
  final Ref _ref;

  GameTelemetryNotifier(this._ref)
      : super(
          GameTelemetryState(
            sessionId: const Uuid().v4(),
            gameType: 'visual_handloom',
            currentDifficulty: 1.0,
          ),
        );

  /// Initializes and starts a new cognitive gaming round
  Future<void> startSession({
    required String gameType,
    double? initialDifficulty,
  }) async {
    final user = _ref.read(activeUserProvider).value;
    final userId = user?.id ?? 'patient_ner_001';

    double startingDifficulty = initialDifficulty ?? 1.0;
    if (initialDifficulty == null) {
      final repo = _ref.read(gameSessionRepositoryProvider);
      final lastSession = await repo.getLatestSession(userId, gameType);
      if (lastSession != null) {
        startingDifficulty = lastSession.difficultyLevel;
      }
    }

    state = GameTelemetryState(
      sessionId: const Uuid().v4(),
      gameType: gameType,
      currentDifficulty: startingDifficulty,
      correctMatches: 0,
      mistakes: 0,
      totalAttempts: 0,
      reactionLatenciesMs: [],
      sessionStartTime: DateTime.now(),
      currentTurnStartTime: DateTime.now(),
      isSessionActive: true,
      lastResult: null,
    );
  }

  /// Marks the presentation of a new prompt/tile set to measure precise reaction latency
  void startTurn() {
    state = state.copyWith(currentTurnStartTime: DateTime.now());
  }

  /// Records patient touch interaction, calculates millisecond latency, and provides gentle haptics
  void recordInteraction({required bool isCorrect}) {
    if (!state.isSessionActive) return;

    final now = DateTime.now();
    int latencyMs = 1200;
    if (state.currentTurnStartTime != null) {
      latencyMs = now.difference(state.currentTurnStartTime!).inMilliseconds;
      // Tremor filtering: Ignore ultra-fast erratic twitch taps (< 120ms)
      if (latencyMs < 120) latencyMs = 120;
    }

    final updatedLatencies = List<int>.from(state.reactionLatenciesMs)..add(latencyMs);

    if (isCorrect) {
      HapticService.successFeedback();
      state = state.copyWith(
        correctMatches: state.correctMatches + 1,
        totalAttempts: state.totalAttempts + 1,
        reactionLatenciesMs: updatedLatencies,
        currentTurnStartTime: now,
      );
    } else {
      HapticService.lightTouch();
      state = state.copyWith(
        mistakes: state.mistakes + 1,
        totalAttempts: state.totalAttempts + 1,
        reactionLatenciesMs: updatedLatencies,
        currentTurnStartTime: now,
      );
    }
  }

  /// Finalizes game session, executes DDA algorithm, updates local encrypted SQLite, and generates clinical alerts
  Future<DDAResult> completeSession() async {
    final user = _ref.read(activeUserProvider).value;
    final userId = user?.id ?? 'patient_ner_001';
    final dementiaStage = user?.dementiaStage ?? 'Early-Stage MCI';
    final params = DDAParameters.forStage(dementiaStage);

    final durationSec = state.sessionStartTime != null
        ? DateTime.now().difference(state.sessionStartTime!).inSeconds
        : 60;

    final sessionRepo = _ref.read(gameSessionRepositoryProvider);
    final alertRepo = _ref.read(caregiverAlertRepositoryProvider);
    final appDb = _ref.read(appDatabaseProvider);

    // Retrieve previous session CVS for anomaly detection
    final prevSession = await sessionRepo.getLatestSession(userId, state.gameType);

    // 1. Run Core DDA Algorithm
    final ddaResult = DDAEngine.calculate(
      currentDifficulty: state.currentDifficulty,
      totalAttempts: max(1, state.totalAttempts),
      correctMatches: state.correctMatches,
      mistakes: state.mistakes,
      averageReactionTimeMs: state.averageReactionTimeMs,
      params: params,
      previousCvsScore: prevSession?.cvsScore,
    );

    final nowIso = DateTime.now().toIso8601String();
    final hlc = appDb.generateNextHlc().toCanonicalString();

    // 2. Build and Persist Encrypted Session Record
    final sessionRecord = GameSessionModel(
      sessionId: state.sessionId,
      userId: userId,
      gameType: state.gameType,
      durationSeconds: max(10, durationSec),
      difficultyLevel: ddaResult.nextDifficulty,
      reactionTimeMs: state.averageReactionTimeMs,
      errorRate: ddaResult.errorRate,
      cvsScore: ddaResult.cvsScore,
      timestamp: nowIso,
      syncStatus: 'pending',
      hlcTimestamp: hlc,
    );

    await sessionRepo.saveGameSession(sessionRecord);

    // 3. Clinical Anomaly Alert Logging
    if (ddaResult.shouldTriggerCaregiverAlert && ddaResult.alertReason != null) {
      final alertRecord = CaregiverAlertModel(
        alertId: const Uuid().v4(),
        triggerReason: ddaResult.alertReason!,
        urgency: ddaResult.alertUrgency ?? 'MEDIUM',
        timestamp: nowIso,
        syncStatus: 'pending',
        hlcTimestamp: appDb.generateNextHlc().toCanonicalString(),
      );
      await alertRepo.createAlert(alertRecord);
    }

    state = state.copyWith(
      isSessionActive: false,
      lastResult: ddaResult,
      currentDifficulty: ddaResult.nextDifficulty,
    );

    return ddaResult;
  }
}

/// Provider for Game Telemetry & DDA State
final gameTelemetryProvider = StateNotifierProvider<GameTelemetryNotifier, GameTelemetryState>((ref) {
  return GameTelemetryNotifier(ref);
});

