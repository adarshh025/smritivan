import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smritivan_app/features/games/presentation/level_selection_view.dart';
import 'package:smritivan_app/features/games/presentation/game_telemetry_provider.dart';
import 'package:smritivan_app/features/games/data/game_session_repository.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/features/games/memory_match/memory_match_game.dart';
import 'package:smritivan_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

  testWidgets('LevelSelectionView progression loading with mock repository', (tester) async {
    final mockRepo = MockGameSessionRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameSessionRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: LevelSelectionView(
            gameType: 'memory_match',
            gameTitle: 'Memory Match',
            gameIcon: '🧠',
            gameColor: const Color(0xFFE9C46A),
            gameBuilder: (lvl) => MemoryMatchGame(currentDifficulty: lvl),
          ),
        ),
      ),
    );

    // Pump to settle
    await tester.pumpAndSettle();

    // Must show 'Choose a Level'
    expect(find.text('Choose a Level'), findsOneWidget);
    expect(find.text('Recommended: Level 1'), findsOneWidget);
    expect(find.text('Unable to start this game'), findsNothing);
  });
}
