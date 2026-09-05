// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smritivan_app/core/security/encryption_service.dart';
import 'package:smritivan_app/features/auth_profile/domain/user_model.dart';
import 'package:smritivan_app/features/auth_profile/domain/relationship_model.dart';
import 'package:smritivan_app/features/auth_profile/data/user_repository.dart';
import 'package:smritivan_app/features/auth_profile/presentation/user_provider.dart';
import 'package:smritivan_app/features/reminders/domain/reminder_model.dart';
import 'package:smritivan_app/features/reminders/data/reminder_repository.dart';
import 'package:smritivan_app/features/reminders/presentation/reminder_provider.dart';
import 'package:smritivan_app/features/reminders/application/reminder_service.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/features/games/data/game_session_repository.dart';
import 'package:smritivan_app/features/games/presentation/game_telemetry_provider.dart';
import 'package:smritivan_app/features/wellbeing/domain/wellbeing_model.dart';
import 'package:smritivan_app/features/wellbeing/data/wellbeing_repository.dart';
import 'package:smritivan_app/features/home/presentation/elder_home_view.dart';
import 'package:smritivan_app/features/home/application/elder_home_provider.dart';
import 'package:smritivan_app/features/caregiver/application/caregiver_dashboard_provider.dart';
import 'package:smritivan_app/l10n/app_localizations.dart';

// In-Memory Mock Repositories for deterministic testing
class InMemoryUserRepo implements UserRepository {
  UserModel? _user = const UserModel(
    id: 'patient_ner_001',
    name: 'Bhaben Bora',
    age: 68,
    phone: '+91 98765 43210',
    nativeLanguage: 'as',
    dementiaStage: 'Early-Stage (Mild Cognitive Impairment)',
    soundEffectsEnabled: true,
    voiceGuidanceEnabled: true,
    hapticFeedbackEnabled: true,
    notificationsEnabled: true,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    hlcTimestamp: '',
  );

  @override
  Future<UserModel?> getActivePatient() async => _user;

  @override
  Future<void> savePatient(UserModel user) async {
    _user = user;
  }

  @override
  Future<List<CaregiverRelationshipModel>> getRelationshipsForPatient(String patientId) async => [];

  @override
  Future<void> updateLanguage(String userId, String langCode) async {
    if (_user != null) {
      _user = _user!.copyWith(nativeLanguage: langCode);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryReminderRepo implements ReminderRepository {
  final List<ReminderModel> _reminders = [
    ReminderModel(
      id: 'rem_001',
      userId: 'patient_ner_001',
      title: 'Morning Medication',
      type: 'medication',
      time: '08:30 AM',
      priority: 'high',
      status: 'pending',
      createdAt: '2026-09-05T08:30:00Z',
      updatedAt: '2026-09-05T08:30:00Z',
      hlcTimestamp: '',
    ),
    ReminderModel(
      id: 'rem_002',
      userId: 'patient_ner_001',
      title: 'Hydration Check',
      type: 'water',
      time: '11:00 AM',
      priority: 'normal',
      status: 'pending',
      createdAt: '2026-09-05T11:00:00Z',
      updatedAt: '2026-09-05T11:00:00Z',
      hlcTimestamp: '',
    ),
  ];

  @override
  Future<List<ReminderModel>> getRemindersForUser(String userId) async {
    return List.from(_reminders);
  }

  @override
  Future<void> saveReminder(ReminderModel reminder) async {
    final idx = _reminders.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      _reminders[idx] = reminder;
    } else {
      _reminders.add(reminder);
    }
  }

  @override
  Future<void> updateStatus(String reminderId, String newStatus) async {
    final idx = _reminders.indexWhere((r) => r.id == reminderId);
    if (idx >= 0) {
      _reminders[idx] = _reminders[idx].copyWith(status: newStatus);
    }
  }

  @override
  Future<void> toggleStatus(String reminderId) async {
    final idx = _reminders.indexWhere((r) => r.id == reminderId);
    if (idx >= 0) {
      final current = _reminders[idx];
      final newStatus = current.status == 'done' ? 'pending' : 'done';
      _reminders[idx] = current.copyWith(
        status: newStatus,
        completedAt: newStatus == 'done' ? DateTime.now().toIso8601String() : null,
      );
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    _reminders.removeWhere((r) => r.id == reminderId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryGameSessionRepo implements GameSessionRepository {
  final List<GameSessionModel> _sessions = [];

  @override
  Future<void> saveGameSession(GameSessionModel session) async {
    _sessions.add(session);
  }

  @override
  Future<GameSessionModel?> getLatestSession(String userId, String gameType) async {
    final filtered = _sessions.where((s) => s.userId == userId && s.gameType == gameType).toList();
    if (filtered.isEmpty) return null;
    return filtered.last;
  }

  @override
  Future<List<GameSessionModel>> getSessionHistory(String userId, {int limit = 30}) async {
    return _sessions.where((s) => s.userId == userId).take(limit).toList();
  }

  @override
  Future<Map<String, dynamic>> getAggregateStats(String userId) async {
    final userSessions = _sessions.where((s) => s.userId == userId).toList();
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
    return {
      'total_sessions': userSessions.length,
      'avg_cvs': userSessions.map((s) => s.cvsScore).reduce((a, b) => a + b) / userSessions.length,
      'avg_latency': 1200,
      'avg_error_rate': 0.05,
      'max_difficulty': userSessions.map((s) => s.difficultyLevel).reduce((a, b) => a > b ? a : b),
      'total_duration_seconds': userSessions.map((s) => s.durationSeconds).reduce((a, b) => a + b),
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryWellbeingRepo implements WellbeingRepository {
  final List<WellbeingModel> _checkins = [];

  @override
  Future<void> saveCheckIn(String userId, String status, {String? notes}) async {
    _checkins.insert(
      0,
      WellbeingModel(
        id: 'wb_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        status: status,
        notes: notes,
        timestamp: DateTime.now().toIso8601String(),
        hlcTimestamp: '',
      ),
    );
  }

  @override
  Future<List<WellbeingModel>> getRecentCheckIns(String userId, {int limit = 7}) async {
    return _checkins.take(limit).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Priority 1 & 2: Data Persistence and Model Integrity', () {
    test('EncryptionService has valid fallbackPassphrase and stable alias', () {
      expect(EncryptionService.fallbackPassphrase, isNotEmpty);
      expect(EncryptionService.fallbackPassphrase, 'smritivan_secure_db_passphrase_patient_ner_v1');
    });

    test('UserModel persists and serializes name, age, phone, and accessibility preferences', () {
      const user = UserModel(
        id: 'patient_ner_001',
        name: 'Bhaben Bora',
        age: 72,
        phone: '+91 98765 11111',
        preferredActivityTime: 'Morning',
        nativeLanguage: 'as',
        dementiaStage: 'Early-Stage',
        soundEffectsEnabled: true,
        voiceGuidanceEnabled: true,
        hapticFeedbackEnabled: true,
        notificationsEnabled: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        hlcTimestamp: '1-0',
      );

      final map = user.toMap();
      expect(map['name'], 'Bhaben Bora');
      expect(map['age'], 72);
      expect(map['phone'], '+91 98765 11111');
      expect(map['preferred_activity_time'], 'Morning');
      expect(map['sound_effects_enabled'], 1);

      final reconstructed = UserModel.fromMap(map);
      expect(reconstructed.name, user.name);
      expect(reconstructed.age, 72);
      expect(reconstructed.phone, '+91 98765 11111');
      expect(reconstructed.soundEffectsEnabled, true);
    });

    test('ReminderModel updates status and completedAt accurately', () {
      final rem = ReminderModel(
        id: 'rem_99',
        userId: 'patient_ner_001',
        title: 'Drink Herbal Tea',
        type: 'water',
        time: '04:00 PM',
        priority: 'normal',
        status: 'pending',
        createdAt: '2026-09-05T16:00:00Z',
        updatedAt: '2026-09-05T16:00:00Z',
        hlcTimestamp: '',
      );

      final doneRem = rem.copyWith(
        status: 'done',
        completedAt: '2026-09-05T16:05:00Z',
      );

      expect(doneRem.status, 'done');
      expect(doneRem.completedAt, '2026-09-05T16:05:00Z');
    });
  });

  group('Priority 3, 4 & 5: ElderHomeView UI, Interactivity, & Sundowning-Aware Layout', () {
    late InMemoryUserRepo userRepo;
    late InMemoryReminderRepo reminderRepo;
    late InMemoryGameSessionRepo gameRepo;
    late InMemoryWellbeingRepo wellbeingRepo;

    setUp(() {
      userRepo = InMemoryUserRepo();
      reminderRepo = InMemoryReminderRepo();
      gameRepo = InMemoryGameSessionRepo();
      wellbeingRepo = InMemoryWellbeingRepo();
    });

    testWidgets('ElderHomeView renders with time-aware greeting, wellbeing checkin, reminders, and games', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(userRepo),
            reminderRepositoryProvider.overrideWithValue(reminderRepo),
            gameSessionRepositoryProvider.overrideWithValue(gameRepo),
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
            home: ElderHomeView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header verification
      expect(find.textContaining('Bhaben'), findsWidgets);
      expect(find.text('Audio ON'), findsOneWidget);

      // Wellbeing buttons verification
      expect(find.text('Good'), findsWidgets);
      expect(find.text('Okay'), findsWidgets);
      expect(find.text('Not great'), findsWidgets);

      // Reminders verification
      expect(find.text('Morning Medication'), findsOneWidget);
      expect(find.text('Hydration Check'), findsOneWidget);

      // Cognitive games verification
      expect(find.text('🧠 Cognitive Games'), findsOneWidget);
      expect(find.text('Memory Match'), findsWidgets);
      expect(find.text('Picture Recall'), findsOneWidget);
      expect(find.text('Pattern Builder'), findsOneWidget);
      expect(find.text('Word Garden'), findsOneWidget);
      expect(find.text('Card Recall'), findsOneWidget);
      expect(find.text('Daily Helper'), findsOneWidget);
    });

    testWidgets('Wellbeing button taps execute callback and save check-in', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(userRepo),
            reminderRepositoryProvider.overrideWithValue(reminderRepo),
            gameSessionRepositoryProvider.overrideWithValue(gameRepo),
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
            home: ElderHomeView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'Good' mood button
      await tester.tap(find.text('Good').first);
      await tester.pumpAndSettle();

      final recent = await wellbeingRepo.getRecentCheckIns('patient_ner_001');
      expect(recent.isNotEmpty, true);
      expect(recent.first.status, 'good');
    });

    testWidgets('Marking reminder as done updates status interactively', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(userRepo),
            reminderRepositoryProvider.overrideWithValue(reminderRepo),
            gameSessionRepositoryProvider.overrideWithValue(gameRepo),
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
            home: ElderHomeView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find Mark Done button on the first reminder
      final markDoneBtn = find.text('Mark Done').first;
      expect(markDoneBtn, findsOneWidget);

      await tester.tap(markDoneBtn);
      await tester.pumpAndSettle();

      final updatedList = await reminderRepo.getRemindersForUser('patient_ner_001');
      expect(updatedList.first.status, 'done');
    });
  });
}
