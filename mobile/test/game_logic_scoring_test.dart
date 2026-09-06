// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smritivan_app/features/games/core/game_session_tracker.dart';
import 'package:smritivan_app/features/games/word_garden/word_garden_game.dart';
import 'package:smritivan_app/features/games/pattern_builder/pattern_builder_game.dart';
import 'package:smritivan_app/features/games/picture_recall/picture_recall_game.dart';
import 'package:smritivan_app/features/games/card_recall/card_recall_game.dart';
import 'package:smritivan_app/features/games/data/game_session_repository.dart';
import 'package:smritivan_app/features/games/presentation/game_telemetry_provider.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/core/audio/audio_service.dart';
import 'package:smritivan_app/core/haptic/haptic_service.dart';

class MockAudioService implements AudioService {
  @override
  bool get soundEffectsEnabled => true;
  @override
  bool get voiceGuidanceEnabled => true;
  @override
  String get nativeLanguage => 'en';
  @override
  String get activeTtsLocale => 'en-IN';
  @override
  bool get isCurrentLocaleSupported => true;

  @override
  Future<void> speakInstruction(String text) async {}
  @override
  Future<void> playInstructionWithFallback(String assetPath, String fallbackText) async {}
  @override
  Future<void> playGentleSuccessChime() async {}
  @override
  Future<void> playErrorChime() async {}
  @override
  Future<void> playAmbient(String assetPath) async {}
  @override
  Future<void> stopAmbient() async {}
  @override
  Future<void> stopAll() async {}
  @override
  void dispose() {}
}

class MockHapticService implements HapticService {
  @override
  bool get isEnabled => true;

  @override
  Future<void> light() async {}
  @override
  Future<void> medium() async {}
  @override
  Future<void> heavy() async {}
  @override
  Future<void> selection() async {}
  @override
  Future<void> success() async {}
  @override
  Future<void> error() async {}
}

class MockGameSessionRepository implements GameSessionRepository {
  final List<GameSessionModel> sessions = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<GameSessionModel>> getSessionHistory(String userId, {int limit = 30}) async => sessions;

  @override
  Future<void> saveGameSession(GameSessionModel session) async {
    sessions.add(session);
  }
}

void main() {
  group('1. GameSessionTracker Scoring & Accuracy Calculation', () {
    test('Zero successful attempts out of 1 attempt results in 0% successRate (NOT 100%)', () {
      final tracker = GameSessionTracker();
      tracker.recordAttempt(success: false, errorsInAttempt: 1);
      final results = tracker.finalizeSession(1.0);

      expect(results['successRate'], 0.0);
      expect(results['errorRate'], 1.0);
    });

    test('1 wrong attempt followed by 1 correct attempt results in exactly 50% accuracy', () {
      final tracker = GameSessionTracker();
      tracker.recordAttempt(success: false, errorsInAttempt: 1);
      tracker.recordAttempt(success: true, errorsInAttempt: 0);
      final results = tracker.finalizeSession(1.0);

      expect(results['successRate'], 0.5);
      expect(results['errorRate'], 0.5);
    });

    test('2 wrong attempts followed by 1 correct attempt results in ~33% accuracy', () {
      final tracker = GameSessionTracker();
      tracker.recordAttempt(success: false, errorsInAttempt: 1);
      tracker.recordAttempt(success: false, errorsInAttempt: 1);
      tracker.recordAttempt(success: true, errorsInAttempt: 0);
      final results = tracker.finalizeSession(1.0);

      expect((results['successRate'] as double).toStringAsFixed(2), '0.33');
    });

    test('Direct first correct attempt results in 100% accuracy', () {
      final tracker = GameSessionTracker();
      tracker.recordAttempt(success: true, errorsInAttempt: 0);
      final results = tracker.finalizeSession(1.0);

      expect(results['successRate'], 1.0);
      expect(results['errorRate'], 0.0);
    });
  });

  group('2. WordGardenGame Game Logic & Retry Tests', () {
    testWidgets('WordGardenGame renders options and handles attempt', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            hapticServiceProvider.overrideWithValue(MockHapticService()),
            gameSessionRepositoryProvider.overrideWithValue(MockGameSessionRepository()),
          ],
          child: const MaterialApp(
            home: WordGardenGame(currentDifficulty: 1.0),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final wrapOptions = find.descendant(of: find.byType(Wrap), matching: find.byType(InkWell));
      expect(wrapOptions, findsWidgets);

      await tester.tap(wrapOptions.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final hasTryAgain = find.text('Try Again');
      final hasCorrect = find.text('✓ Correct!');
      expect(hasTryAgain.evaluate().isNotEmpty || hasCorrect.evaluate().isNotEmpty, isTrue);
    });
  });

  group('3. PatternBuilderGame Game Logic & Retry Tests', () {
    testWidgets('Pattern Builder renders pattern and options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            hapticServiceProvider.overrideWithValue(MockHapticService()),
            gameSessionRepositoryProvider.overrideWithValue(MockGameSessionRepository()),
          ],
          child: const MaterialApp(
            home: PatternBuilderGame(currentDifficulty: 1.0),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text("What comes next?"), findsOneWidget);
      expect(find.text("❓"), findsOneWidget);

      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);
    });
  });

  group('4. PictureRecallGame & CardRecallGame Verification', () {
    testWidgets('PictureRecallGame observation phase renders cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            hapticServiceProvider.overrideWithValue(MockHapticService()),
            gameSessionRepositoryProvider.overrideWithValue(MockGameSessionRepository()),
          ],
          child: const MaterialApp(
            home: PictureRecallGame(currentDifficulty: 1.0),
          ),
        ),
      );

      await tester.pump();
      expect(find.text("Look carefully..."), findsOneWidget);
    });

    testWidgets('CardRecallGame observation phase renders cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            hapticServiceProvider.overrideWithValue(MockHapticService()),
            gameSessionRepositoryProvider.overrideWithValue(MockGameSessionRepository()),
          ],
          child: const MaterialApp(
            home: CardRecallGame(currentDifficulty: 1.0),
          ),
        ),
      );

      await tester.pump();
      expect(find.text("Remember these objects..."), findsOneWidget);
    });
  });
}
