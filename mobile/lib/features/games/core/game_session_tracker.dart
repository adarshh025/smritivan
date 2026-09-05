import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'adaptive_difficulty_engine.dart';
import '../data/game_session_repository.dart';
import '../domain/game_session_model.dart';
import '../presentation/game_telemetry_provider.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../../core/database/database_provider.dart';
import '../../home/application/elder_home_provider.dart';
import '../../caregiver/application/caregiver_dashboard_provider.dart';

class GameSessionState {
  final int totalAttempts;
  final int successfulAttempts;
  final int totalErrors;
  final List<int> reactionTimesMs;
  final DateTime startTime;

  GameSessionState({
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.totalErrors,
    required this.reactionTimesMs,
    required this.startTime,
  });

  factory GameSessionState.initial() => GameSessionState(
    totalAttempts: 0,
    successfulAttempts: 0,
    totalErrors: 0,
    reactionTimesMs: [],
    startTime: DateTime.now(),
  );

  GameSessionState copyWith({
    int? totalAttempts,
    int? successfulAttempts,
    int? totalErrors,
    List<int>? reactionTimesMs,
  }) {
    return GameSessionState(
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successfulAttempts: successfulAttempts ?? this.successfulAttempts,
      totalErrors: totalErrors ?? this.totalErrors,
      reactionTimesMs: reactionTimesMs ?? this.reactionTimesMs,
      startTime: this.startTime,
    );
  }
}

class GameSessionTracker extends StateNotifier<GameSessionState> {
  GameSessionTracker() : super(GameSessionState.initial());

  DateTime? _lastInteractionTime;

  void reset() {
    state = GameSessionState.initial();
    _lastInteractionTime = null;
  }

  void startInteraction() {
    _lastInteractionTime = DateTime.now();
  }

  void recordAttempt({required bool success, int errorsInAttempt = 0}) {
    final reactionTime = _lastInteractionTime != null
        ? DateTime.now().difference(_lastInteractionTime!).inMilliseconds
        : 1200;
    
    state = state.copyWith(
      totalAttempts: state.totalAttempts + 1,
      successfulAttempts: state.successfulAttempts + (success ? 1 : 0),
      totalErrors: state.totalErrors + errorsInAttempt,
      reactionTimesMs: [...state.reactionTimesMs, reactionTime],
    );
    
    _lastInteractionTime = null; // Reset for next attempt
  }

  Map<String, dynamic> finalizeSession(double currentDifficulty) {
    int totalAttempts = state.totalAttempts > 0 ? state.totalAttempts : 1;
    int successfulAttempts = state.successfulAttempts > 0 ? state.successfulAttempts : 1;
    int totalErrors = state.totalErrors;

    double successRate = (successfulAttempts / totalAttempts).clamp(0.0, 1.0);
    double errorRate = (totalErrors / totalAttempts).clamp(0.0, 1.0);
    
    // Average reaction time
    double avgReactionTime = state.reactionTimesMs.isNotEmpty 
        ? state.reactionTimesMs.reduce((a, b) => a + b) / state.reactionTimesMs.length 
        : 1200.0;
        
    // Normalize latency (assuming 5000ms is max expected latency for elderly)
    double normalizedLatency = (avgReactionTime / 5000.0).clamp(0.0, 1.0);

    double nextDifficulty = AdaptiveDifficultyEngine.calculateNextDifficulty(
      currentDifficulty: currentDifficulty,
      successRate: successRate,
      targetSuccessRate: 0.7,
      normalizedLatency: normalizedLatency,
      errorRate: errorRate,
    );

    double cvs = AdaptiveDifficultyEngine.calculateCVS(
      successRate: successRate,
      errorRate: errorRate,
      normalizedLatency: normalizedLatency,
      difficultyLevel: currentDifficulty,
    );

    int durationSeconds = max(1, DateTime.now().difference(state.startTime).inSeconds);

    return {
      'durationSeconds': durationSeconds,
      'successRate': successRate,
      'errorRate': errorRate,
      'avgReactionTimeMs': avgReactionTime.round(),
      'cvs': cvs,
      'nextDifficulty': nextDifficulty,
    };
  }

  Future<Map<String, dynamic>> finalizeAndSaveSession({
    required double currentDifficulty,
    required String gameType,
    required WidgetRef ref,
  }) async {
    final results = finalizeSession(currentDifficulty);
    try {
      final user = ref.read(activeUserProvider).value;
      final userId = user?.id ?? 'patient_ner_001';
      final sessionRepo = ref.read(gameSessionRepositoryProvider);
      final appDb = ref.read(appDatabaseProvider);

      final sessionRecord = GameSessionModel(
        sessionId: const Uuid().v4(),
        userId: userId,
        gameType: gameType,
        durationSeconds: (results['durationSeconds'] as num?)?.toInt() ?? 30,
        difficultyLevel: currentDifficulty,
        reactionTimeMs: (results['avgReactionTimeMs'] as num?)?.toInt() ?? 1500,
        errorRate: (results['errorRate'] as num?)?.toDouble() ?? 0.0,
        cvsScore: (results['cvs'] as num?)?.toDouble() ?? 80.0,
        timestamp: DateTime.now().toIso8601String(),
        syncStatus: 'pending',
        hlcTimestamp: appDb.generateNextHlc().toCanonicalString(),
      );

      await sessionRepo.saveGameSession(sessionRecord);
      try {
        ref.read(elderHomeProvider.notifier).loadData();
        ref.read(caregiverDashboardProvider.notifier).loadData();
      } catch (_) {}
    } catch (_) {
      // Gracefully continue even if offline saving has issues
    }
    return results;
  }
}

final gameSessionProvider = StateNotifierProvider<GameSessionTracker, GameSessionState>((ref) {
  return GameSessionTracker();
});

