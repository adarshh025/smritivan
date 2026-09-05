import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smritivan_app/features/games/memory_match/memory_match_game.dart';
import 'package:smritivan_app/features/games/picture_recall/picture_recall_game.dart';
import 'package:smritivan_app/features/games/pattern_builder/pattern_builder_game.dart';
import 'package:smritivan_app/features/games/word_garden/word_garden_game.dart';
import 'package:smritivan_app/features/games/card_recall/card_recall_game.dart';
import 'package:smritivan_app/features/games/daily_helper/daily_helper_game.dart';
import 'package:smritivan_app/features/games/core/game_progression_service.dart';
import 'package:smritivan_app/features/games/data/game_session_repository.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/features/games/presentation/friendly_result_view.dart';

class MockGameSessionRepository implements GameSessionRepository {
  final List<GameSessionModel> sessions = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<GameSessionModel>> getSessionHistory(String userId, {int limit = 30}) async {
    return sessions.where((s) => s.userId == userId).take(limit).toList();
  }

  @override
  Future<void> saveGameSession(GameSessionModel session) async {
    sessions.add(session);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Game Progression & Initialization Tests', () {
    test('GameProgressionService handles brand new user with no history', () async {
      final mockRepo = MockGameSessionRepository();
      final service = GameProgressionService(mockRepo);

      final unlocked = await service.getUnlockedLevel('new_user_123', 'memory_match');
      expect(unlocked, 1.0);

      final recommended = await service.getRecommendedLevel('new_user_123', 'memory_match');
      expect(recommended, 1.0);
    });

    testWidgets('MemoryMatchGame renders and initializes properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MemoryMatchGame(currentDifficulty: 1.0),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Memory Match'), findsOneWidget);
      // Pump past preview timer
      await tester.pump(const Duration(seconds: 9));
    });

    testWidgets('PictureRecallGame renders and initializes properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PictureRecallGame(currentDifficulty: 1.0),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Picture Recall'), findsOneWidget);
      // Pump past observation timer
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('PatternBuilderGame renders and initializes properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PatternBuilderGame(currentDifficulty: 1.0),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Pattern Builder'), findsOneWidget);
    });

    testWidgets('WordGardenGame renders and initializes properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WordGardenGame(currentDifficulty: 1.0),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Word Garden'), findsOneWidget);
    });

    testWidgets('CardRecallGame renders and initializes properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CardRecallGame(currentDifficulty: 1.0),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Card Recall'), findsOneWidget);
      // Pump past observe timer
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('DailyHelperGame renders and initializes properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DailyHelperGame(currentDifficulty: 1.0),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Daily Helper'), findsOneWidget);
    });

    test('GameProgressionService unlocks level 2 after completing level 1 for specific game without cross contamination', () async {
      final mockRepo = MockGameSessionRepository();
      final service = GameProgressionService(mockRepo);

      // Initially both games at level 1
      expect(await service.getUnlockedLevel('user_1', 'memory_match'), 1.0);
      expect(await service.getUnlockedLevel('user_1', 'pattern_builder'), 1.0);

      // Save a completed session for memory_match Level 1
      await mockRepo.saveGameSession(
        GameSessionModel(
          sessionId: 's1',
          userId: 'user_1',
          gameType: 'memory_match',
          durationSeconds: 35,
          difficultyLevel: 1.0,
          reactionTimeMs: 1400,
          errorRate: 0.1,
          cvsScore: 85.0,
          timestamp: DateTime.now().toIso8601String(),
          syncStatus: 'synced',
          hlcTimestamp: 'hlc1',
        ),
      );

      // Memory match level 2 is now unlocked!
      expect(await service.getUnlockedLevel('user_1', 'memory_match'), 2.0);

      // Pattern builder level 2 MUST REMAIN LOCKED (1.0)
      expect(await service.getUnlockedLevel('user_1', 'pattern_builder'), 1.0);
    });

    testWidgets('FriendlyResultView displays accurate level complete details and choice buttons', (tester) async {
      bool nextLevelTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FriendlyResultView(
            gameType: 'memory_match',
            gameTitle: 'Memory Match',
            gameIcon: '🧠',
            gameColor: const Color(0xFF2A9D8F),
            currentLevel: 1.0,
            results: const {
              'successRate': 0.90,
              'durationSeconds': 42,
              'cvs': 88.0,
            },
            gameBuilder: (lvl) {
              nextLevelTriggered = true;
              return const Scaffold(body: Text('Next Level Screen'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wonderful! 🌟'), findsOneWidget);
      expect(find.text('Memory Match • Level 1 Completed'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('42s'), findsOneWidget);
      expect(find.text('88'), findsOneWidget);
      expect(find.text('Level 2 Unlocked!'), findsOneWidget);

      // Verify buttons
      expect(find.byKey(const Key('btn_play_next_level')), findsOneWidget);
      expect(find.byKey(const Key('btn_choose_level_game')), findsOneWidget);
      expect(find.byKey(const Key('btn_back_to_home')), findsOneWidget);

      // Tap play next level
      await tester.tap(find.byKey(const Key('btn_play_next_level')));
      await tester.pumpAndSettle();
      expect(nextLevelTriggered, isTrue);
      expect(find.text('Next Level Screen'), findsOneWidget);
    });
  });
}
