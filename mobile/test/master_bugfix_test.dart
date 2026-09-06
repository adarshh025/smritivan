import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smritivan_app/features/auth_profile/domain/user_model.dart';
import 'package:smritivan_app/features/auth_profile/domain/relationship_model.dart';
import 'package:smritivan_app/features/auth_profile/domain/caregiver_model.dart';
import 'package:smritivan_app/features/auth_profile/data/user_repository.dart';
import 'package:smritivan_app/features/auth_profile/presentation/user_provider.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/features/reminders/domain/reminder_model.dart';
import 'package:smritivan_app/features/settings/presentation/patient_settings_view.dart';
import 'package:smritivan_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FakeUserRepo implements UserRepository {
  @override
  Future<UserModel?> getActivePatient() async => null;

  @override
  Future<List<CaregiverRelationshipModel>> getRelationshipsForPatient(String patientId) async => [];

  @override
  Future<void> savePatient(UserModel user) async {}

  @override
  Future<void> saveRelationship(CaregiverRelationshipModel relationship) async {}

  @override
  Future<void> updateLanguage(String userId, String langCode) async {}

  @override
  Future<CaregiverModel?> getCaregiver(String caregiverId) async => null;

  @override
  Future<void> saveCaregiver(CaregiverModel caregiver) async {}

  @override
  Future<List<UserModel>> getAllPatients() async => [];

  @override
  Future<UserModel?> getPatientById(String userId) async => null;
}

void main() {
  group('Bug 4 - Patient Settings Screen Tests', () {
    testWidgets('PatientSettingsView renders immediately without crashing or spinning infinitely when user is null', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(FakeUserRepo()),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: PatientSettingsView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Caregiver Access'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Voice Guidance'), findsOneWidget);
      expect(find.text('Haptic Feedback'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Bug 2 - Caregiver Reminder Model & Status Toggle Tests', () {
    test('ReminderModel copyWith updates status and completion correctly', () {
      final reminder = ReminderModel(
        id: 'rem_test_01',
        userId: 'patient_ner_001',
        title: 'Morning Medicine',
        type: 'medication',
        time: '08:00 AM',
        priority: 'high',
        status: 'pending',
        createdAt: '2026-09-04T08:00:00Z',
        updatedAt: '2026-09-04T08:00:00Z',
        hlcTimestamp: '',
      );

      final completed = reminder.copyWith(
        status: 'done',
        completedAt: '2026-09-04T08:30:00Z',
        updatedAt: '2026-09-04T08:30:00Z',
      );

      expect(completed.status, 'done');
      expect(completed.completedAt, '2026-09-04T08:30:00Z');
      expect(completed.title, 'Morning Medicine');
      expect(completed.priority, 'high');

      final toggledBack = completed.copyWith(
        status: 'pending',
        completedAt: null,
      );

      expect(toggledBack.status, 'pending');
    });
  });

  group('Bug 3 - Game Session Model & Activity Telemetry Tests', () {
    test('GameSessionModel constructs accurately and retains duration & CVS scores', () {
      final session = GameSessionModel(
        sessionId: 'sess_123',
        userId: 'patient_ner_001',
        gameType: 'memory_match',
        durationSeconds: 120,
        difficultyLevel: 2.5,
        reactionTimeMs: 1350,
        errorRate: 0.1,
        cvsScore: 88.5,
        timestamp: '2026-09-04T10:00:00Z',
        syncStatus: 'pending',
        hlcTimestamp: '1-0',
      );

      final map = session.toMap();
      expect(map['session_id'], 'sess_123');
      expect(map['user_id'], 'patient_ner_001');
      expect(map['duration_seconds'], 120);
      expect(map['cvs_score'], 88.5);
      expect(map['reaction_time_ms'], 1350);

      final reconstituted = GameSessionModel.fromMap(map);
      expect(reconstituted.sessionId, session.sessionId);
      expect(reconstituted.durationSeconds, 120);
      expect(reconstituted.cvsScore, 88.5);
      expect(reconstituted.reactionTimeMs, 1350);
    });
  });

  group('Targeted Fix - Settings & Profile Persistence Tests', () {
    test('UserModel copyWith correctly updates profile and accessibility toggles', () {
      const user = UserModel(
        id: 'patient_ner_001',
        name: 'Bhaben Bora',
        age: 68,
        phone: '+91 98765 43210',
        nativeLanguage: 'as',
        dementiaStage: 'Early-Stage',
        soundEffectsEnabled: true,
        voiceGuidanceEnabled: true,
        hapticFeedbackEnabled: true,
        notificationsEnabled: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        hlcTimestamp: '',
      );

      final edited = user.copyWith(
        name: 'Bhaben Bora (Updated)',
        age: 69,
        phone: '+91 99999 88888',
        soundEffectsEnabled: false,
        voiceGuidanceEnabled: false,
        hapticFeedbackEnabled: false,
      );

      expect(edited.name, 'Bhaben Bora (Updated)');
      expect(edited.age, 69);
      expect(edited.phone, '+91 99999 88888');
      expect(edited.soundEffectsEnabled, false);
      expect(edited.voiceGuidanceEnabled, false);
      expect(edited.hapticFeedbackEnabled, false);
      expect(edited.nativeLanguage, 'as'); // preserved
    });
  });
}

