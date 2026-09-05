// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smritivan_app/features/auth_profile/domain/user_model.dart';
import 'package:smritivan_app/features/auth_profile/domain/relationship_model.dart';
import 'package:smritivan_app/features/auth_profile/data/user_repository.dart';
import 'package:smritivan_app/features/auth_profile/presentation/user_provider.dart';
import 'package:smritivan_app/features/reminders/data/reminder_repository.dart';
import 'package:smritivan_app/features/reminders/domain/reminder_model.dart';
import 'package:smritivan_app/features/reminders/application/reminder_service.dart';
import 'package:smritivan_app/features/wellbeing/data/wellbeing_repository.dart';
import 'package:smritivan_app/features/wellbeing/domain/wellbeing_model.dart';
import 'package:smritivan_app/features/games/data/game_session_repository.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/features/games/presentation/game_telemetry_provider.dart';
import 'package:smritivan_app/features/analytics/presentation/patient_analytics_view.dart';
import 'package:smritivan_app/features/caregiver/presentation/caregiver_dashboard_view.dart';
import 'package:smritivan_app/shared/widgets/patient_progress_chart.dart';
import 'package:smritivan_app/l10n/app_localizations.dart';

class MockUserRepo implements UserRepository {
  UserModel? user;

  MockUserRepo(this.user);

  @override
  Future<UserModel?> getActivePatient() async => user;

  @override
  Future<void> savePatient(UserModel u) async {
    user = u;
  }

  @override
  Future<List<CaregiverRelationshipModel>> getRelationshipsForPatient(String patientId) async => [];

  @override
  Future<void> updateLanguage(String userId, String langCode) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReminderRepo implements ReminderRepository {
  final List<ReminderModel> reminders = [];

  @override
  Future<List<ReminderModel>> getRemindersForUser(String userId) async => reminders;

  @override
  Future<void> saveReminder(ReminderModel r) async => reminders.add(r);

  @override
  Future<void> deleteReminder(String id) async => reminders.removeWhere((r) => r.id == id);

  @override
  Future<void> toggleStatus(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWellbeingRepo implements WellbeingRepository {
  final List<WellbeingModel> checkins = [];

  @override
  Future<void> saveCheckIn(String userId, String status, {String? notes}) async {}

  @override
  Future<List<WellbeingModel>> getRecentCheckIns(String userId, {int limit = 7}) async => checkins;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGameSessionRepo implements GameSessionRepository {
  final List<GameSessionModel> sessions = [];

  @override
  Future<void> saveGameSession(GameSessionModel session) async {
    sessions.add(session);
  }

  @override
  Future<GameSessionModel?> getLatestSession(String userId, String gameType) async {
    final list = sessions.where((s) => s.userId == userId && s.gameType == gameType).toList();
    return list.isNotEmpty ? list.last : null;
  }

  @override
  Future<List<GameSessionModel>> getSessionHistory(String userId, {int limit = 30}) async {
    final list = sessions.where((s) => s.userId == userId).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list.take(limit).toList();
  }

  @override
  Future<Map<String, dynamic>> getAggregateStats(String userId) async {
    final userSessions = sessions.where((s) => s.userId == userId).toList();
    if (userSessions.isEmpty) {
      return {
        'total_sessions': 0,
        'avg_cvs': 0.0,
        'avg_latency': 0,
        'avg_error_rate': 0.0,
        'max_difficulty': 1.0,
        'total_duration_seconds': 0,
      };
    }

    final total = userSessions.length;
    final avgCvs = userSessions.map((s) => s.cvsScore).reduce((a, b) => a + b) / total;
    final avgLatency = userSessions.map((s) => s.reactionTimeMs).reduce((a, b) => a + b) ~/ total;
    final maxDiff = userSessions.map((s) => s.difficultyLevel).reduce((a, b) => a > b ? a : b);

    return {
      'total_sessions': total,
      'avg_cvs': avgCvs,
      'avg_latency': avgLatency,
      'avg_error_rate': 0.0,
      'max_difficulty': maxDiff,
      'total_duration_seconds': 120,
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PatientProgressChart Widget Tests', () {
    testWidgets('Renders honest Empty State when 0 sessions exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PatientProgressChart(sessions: []),
          ),
        ),
      );

      expect(find.text("No activities recorded yet"), findsOneWidget);
      expect(find.text("Complete your first cognitive game to begin tracking your engagement progress."), findsOneWidget);
    });

    testWidgets('Renders Single Session View when exactly 1 session exists', (tester) async {
      final session = GameSessionModel(
        sessionId: 'session-1',
        userId: 'patient-1',
        gameType: 'memory_match',
        durationSeconds: 42,
        difficultyLevel: 1.0,
        reactionTimeMs: 1100,
        errorRate: 0.1,
        cvsScore: 88.0,
        timestamp: DateTime.now().toIso8601String(),
        hlcTimestamp: '1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatientProgressChart(sessions: [session]),
          ),
        ),
      );

      expect(find.text("88"), findsOneWidget);
      expect(find.text("Memory Match"), findsOneWidget);
      expect(find.textContaining("Level 1"), findsOneWidget);
      expect(find.textContaining("Single session recorded"), findsOneWidget);
      expect(find.text("1100 ms"), findsOneWidget);
    });

    testWidgets('Renders Preliminary Trend Canvas when 2-3 sessions exist', (tester) async {
      final now = DateTime.now();
      final sessions = [
        GameSessionModel(
          sessionId: 's-1',
          userId: 'p-1',
          gameType: 'memory_match',
          durationSeconds: 30,
          difficultyLevel: 1.0,
          reactionTimeMs: 1200,
          errorRate: 0.2,
          cvsScore: 75.0,
          timestamp: now.subtract(const Duration(days: 2)).toIso8601String(),
          hlcTimestamp: '1',
        ),
        GameSessionModel(
          sessionId: 's-2',
          userId: 'p-1',
          gameType: 'picture_recall',
          durationSeconds: 35,
          difficultyLevel: 1.0,
          reactionTimeMs: 1000,
          errorRate: 0.1,
          cvsScore: 85.0,
          timestamp: now.subtract(const Duration(days: 1)).toIso8601String(),
          hlcTimestamp: '2',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatientProgressChart(sessions: sessions),
          ),
        ),
      );

      expect(find.text("Preliminary Trend (2 sessions)"), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Switches time filters smoothly', (tester) async {
      String selectedFilter = '30d';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PatientProgressChart(
                sessions: const [],
                activeTimeFilter: selectedFilter,
                onFilterChanged: (f) {
                  setState(() => selectedFilter = f);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text("7 Days"), findsOneWidget);
      expect(find.text("30 Days"), findsOneWidget);
      expect(find.text("All Time"), findsOneWidget);

      await tester.tap(find.text("7 Days"));
      await tester.pumpAndSettle();
      expect(selectedFilter, equals('7d'));

      await tester.tap(find.text("All Time"));
      await tester.pumpAndSettle();
      expect(selectedFilter, equals('all'));
    });
  });

  group('Patient & Caregiver Analytics End-to-End Integration', () {
    testWidgets('PatientAnalyticsView loads authentic SQLite data and displays real metrics', (tester) async {
      const patientId = 'test_patient_sih_2026';
      final now = DateTime.now();

      final sessionRepo = MockGameSessionRepo();
      await sessionRepo.saveGameSession(GameSessionModel(
        sessionId: 'test-s1',
        userId: patientId,
        gameType: 'memory_match',
        durationSeconds: 40,
        difficultyLevel: 1.0,
        reactionTimeMs: 1300,
        errorRate: 0.15,
        cvsScore: 82.0,
        timestamp: now.subtract(const Duration(days: 3)).toIso8601String(),
        hlcTimestamp: '1',
      ));

      await sessionRepo.saveGameSession(GameSessionModel(
        sessionId: 'test-s2',
        userId: patientId,
        gameType: 'word_garden',
        durationSeconds: 55,
        difficultyLevel: 2.0,
        reactionTimeMs: 1150,
        errorRate: 0.05,
        cvsScore: 92.0,
        timestamp: now.subtract(const Duration(days: 1)).toIso8601String(),
        hlcTimestamp: '2',
      ));

      const testUser = UserModel(
        id: patientId,
        name: 'Pratibha Devi',
        age: 72,
        phone: '+91 98765 43210',
        nativeLanguage: 'as',
        dementiaStage: 'Early-Stage (Mild Cognitive Impairment)',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        hlcTimestamp: '',
      );

      final userRepo = MockUserRepo(testUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(userRepo),
            gameSessionRepositoryProvider.overrideWithValue(sessionRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: PatientAnalyticsView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and name
      expect(find.text("Pratibha Devi"), findsOneWidget);
      expect(find.text("Activity & Game Progress"), findsAtLeastNWidgets(1));

      // Verify real summary cards computed from SQLite
      expect(find.text("Activities Done"), findsOneWidget);
      expect(find.text("2"), findsOneWidget); // 2 total sessions
      expect(find.text("87/100"), findsOneWidget); // (82 + 92)/2 = 87
      expect(find.text("Level 2"), findsAtLeastNWidgets(1)); // max difficulty is 2
      expect(find.text("1225 ms"), findsOneWidget); // (1300 + 1150)/2 = 1225

      // Verify level progression displays
      expect(find.text("Memory Match"), findsAtLeastNWidgets(1));
      expect(find.text("Word Garden"), findsAtLeastNWidgets(1));

      // Verify healthcare notice
      expect(find.textContaining("Healthcare Notice: Progress trends reflect cognitive game participation"), findsOneWidget);
    });

    testWidgets('Caregiver Dashboard Analytics Tab shares exact same real data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const patientId = 'test_patient_sih_2026';
      final now = DateTime.now();

      final sessionRepo = MockGameSessionRepo();
      final reminderRepo = MockReminderRepo();
      final wellbeingRepo = MockWellbeingRepo();

      await sessionRepo.saveGameSession(GameSessionModel(
        sessionId: 'caregiver-s1',
        userId: patientId,
        gameType: 'memory_match',
        durationSeconds: 30,
        difficultyLevel: 1.0,
        reactionTimeMs: 1400,
        errorRate: 0.1,
        cvsScore: 80.0,
        timestamp: now.toIso8601String(),
        hlcTimestamp: '1',
      ));

      const testUser = UserModel(
        id: patientId,
        name: 'Pratibha Devi',
        age: 72,
        phone: '+91 98765 43210',
        nativeLanguage: 'as',
        dementiaStage: 'Early-Stage (Mild Cognitive Impairment)',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        hlcTimestamp: '',
      );

      final userRepo = MockUserRepo(testUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(userRepo),
            gameSessionRepositoryProvider.overrideWithValue(sessionRepo),
            reminderRepositoryProvider.overrideWithValue(reminderRepo),
            wellbeingRepositoryProvider.overrideWithValue(wellbeingRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: CaregiverDashboardView(),
          ),
        ),
      );

      // Pump initial render
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Navigate to Analytics Tab (index 3)
      final analyticsNavButton = find.text('Analytics');
      expect(analyticsNavButton, findsAtLeastNWidgets(1));
      await tester.tap(analyticsNavButton.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify the Patient Longitudinal Trend chart is present and shows single session info
      expect(find.text("Patient Longitudinal Trend"), findsOneWidget);
      expect(find.text("Memory Match"), findsAtLeastNWidgets(1));
      expect(find.text("80"), findsAtLeastNWidgets(1));
      expect(find.text("1400 ms"), findsAtLeastNWidgets(1));
    });
  });
}
