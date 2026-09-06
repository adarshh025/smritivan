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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smritivan_app/features/health_worker/domain/health_worker_model.dart';
import 'package:smritivan_app/features/health_worker/presentation/health_worker_auth_view.dart';
import 'package:smritivan_app/features/health_worker/presentation/health_worker_dashboard_view.dart';
import 'package:smritivan_app/features/health_worker/presentation/patient_clinical_detail_view.dart';
import 'package:smritivan_app/features/health_worker/application/health_worker_provider.dart';
import 'package:smritivan_app/features/auth_profile/domain/user_model.dart';
import 'package:smritivan_app/features/games/domain/game_session_model.dart';
import 'package:smritivan_app/features/reminders/domain/reminder_model.dart';
import 'package:smritivan_app/features/wellbeing/domain/wellbeing_model.dart';
import 'package:smritivan_app/core/localization/ner_localization_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'health_worker_pin': '1234',
    });
  });

  group('1. Health Worker Domain & Telemetry Models', () {
    test('HealthWorkerProfile serialization and default factory', () {
      final defaultProf = HealthWorkerProfile.defaultWorker();
      expect(defaultProf.workerId, 'NHM-NER-2026');
      expect(defaultProf.state, 'Assam');

      final map = defaultProf.toMap();
      final restored = HealthWorkerProfile.fromMap(map);
      expect(restored.name, defaultProf.name);
      expect(restored.facilityName, defaultProf.facilityName);
      expect(restored.designation, defaultProf.designation);
    });

    test('PatientClinicalSummary stores comprehensive telemetry', () {
      final user = UserModel(
        id: 'patient_ner_001',
        name: 'Bhaben Bora',
        nativeLanguage: 'as',
        state: 'Assam',
        dementiaStage: 'Early-Stage MCI',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        hlcTimestamp: '',
      );

      final summary = PatientClinicalSummary(
        patient: user,
        totalSessions: 12,
        avgAccuracy: 84.5,
        avgLatencyMs: 1420,
        avgErrorRate: 0.155,
        totalPlaytimeSeconds: 720,
        lastActiveDate: DateTime.now().toIso8601String(),
        gameMetrics: [
          const GamePerformanceMetric(
            gameType: 'memory_match',
            title: 'Memory Match',
            icon: '🎴',
            totalSessions: 6,
            maxLevelUnlocked: 3.0,
            avgAccuracy: 85.0,
            avgErrorRate: 0.15,
            avgLatencyMs: 1300,
            bestAccuracy: 95.0,
            recentAccuracy: 90.0,
            totalPlaytimeSeconds: 360,
          ),
        ],
        levelProgressions: {'memory_match': 3.0},
        adherence: const PatientAdherenceStats(
          totalReminders: 10,
          completedReminders: 9,
          pendingReminders: 1,
          adherenceRate: 90.0,
        ),
        observations: [
          ClinicalObservation(
            id: 'obs_1',
            patientId: 'patient_ner_001',
            title: 'Strong Task Precision',
            message: 'Average accuracy is 84.5%.',
            severity: ObservationSeverity.positive,
            category: 'Executive Function',
            timestamp: DateTime.now().toIso8601String(),
          ),
        ],
        wellbeingHistory: [
          WellbeingModel(
            id: 'wb_1',
            userId: 'patient_ner_001',
            status: 'good',
            timestamp: DateTime.now().toIso8601String(),
            hlcTimestamp: '',
          ),
        ],
        allSessions: [
          GameSessionModel(
            sessionId: 'sess_1',
            userId: 'patient_ner_001',
            gameType: 'memory_match',
            durationSeconds: 60,
            difficultyLevel: 2.0,
            reactionTimeMs: 1200,
            errorRate: 0.10,
            cvsScore: 90.0,
            timestamp: DateTime.now().toIso8601String(),
            hlcTimestamp: '',
          ),
        ],
      );

      expect(summary.totalSessions, 12);
      expect(summary.avgAccuracy, 84.5);
      expect(summary.adherence.adherenceRate, 90.0);
      expect(summary.observations.first.severity, ObservationSeverity.positive);
      expect(summary.allSessions.length, 1);
    });
  });

  group('2. NER 8-State Coverage in Health Worker Space', () {
    test('All 8 NER states are represented in NerLocalizationConfig', () {
      final states = NerLocalizationConfig.allStates;
      expect(states.length, 8);
      final stateNames = states.map((s) => s.name).toList();
      expect(stateNames, containsAll([
        'Arunachal Pradesh',
        'Assam',
        'Manipur',
        'Meghalaya',
        'Mizoram',
        'Nagaland',
        'Sikkim',
        'Tripura',
      ]));
    });
  });

  group('3. Health Worker Widget UI Tests', () {
    testWidgets('HealthWorkerAuthView renders keypad and header', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HealthWorkerAuthView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Healthcare Professional Access'), findsOneWidget);
      expect(find.text('Healthcare Worker Authorization'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Reset Health Worker PIN'), findsOneWidget);
    });

    testWidgets('PatientClinicalDetailView renders all 5 clinical tabs and disclaimer', (tester) async {
      final dummyUser = UserModel(
        id: 'patient_ner_001',
        name: 'Bhaben Bora',
        nativeLanguage: 'as',
        state: 'Assam',
        dementiaStage: 'Early-Stage MCI',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        hlcTimestamp: '',
      );

      final dummySummary = PatientClinicalSummary(
        patient: dummyUser,
        totalSessions: 4,
        avgAccuracy: 82.0,
        avgLatencyMs: 1350,
        avgErrorRate: 0.18,
        totalPlaytimeSeconds: 240,
        lastActiveDate: DateTime.now().toIso8601String(),
        gameMetrics: [
          const GamePerformanceMetric(
            gameType: 'memory_match',
            title: 'Memory Match',
            icon: '🎴',
            totalSessions: 4,
            maxLevelUnlocked: 2.0,
            avgAccuracy: 82.0,
            avgErrorRate: 0.18,
            avgLatencyMs: 1350,
            bestAccuracy: 90.0,
            recentAccuracy: 85.0,
            totalPlaytimeSeconds: 240,
          ),
        ],
        levelProgressions: {'memory_match': 2.0},
        adherence: const PatientAdherenceStats(
          totalReminders: 4,
          completedReminders: 4,
          pendingReminders: 0,
          adherenceRate: 100.0,
        ),
        observations: [
          ClinicalObservation(
            id: 'obs_test_1',
            patientId: 'patient_ner_001',
            title: 'Consistent Daily Engagement',
            message: 'Patient has completed activities regularly.',
            severity: ObservationSeverity.positive,
            category: 'Engagement',
            timestamp: DateTime.now().toIso8601String(),
          ),
        ],
        wellbeingHistory: [],
        allSessions: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientClinicalDetailProvider('patient_ner_001').overrideWith(
              (ref) => Future.value(dummySummary),
            ),
          ],
          child: const MaterialApp(
            home: PatientClinicalDetailView(patientId: 'patient_ner_001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify tabs exist
      expect(find.text('Cognitive Performance'), findsOneWidget);
      expect(find.text('Activity Timeline'), findsOneWidget);
      expect(find.text('Reminders & Adherence'), findsOneWidget);
      expect(find.text('Wellbeing History'), findsOneWidget);
      expect(find.text('Observations & Alerts'), findsOneWidget);

      // Verify Header Demographics
      expect(find.textContaining('Bhaben Bora'), findsOneWidget);
      expect(find.textContaining('State: Assam'), findsOneWidget);

      // Verify KPIs
      expect(find.text('Total Sessions'), findsOneWidget);
      expect(find.text('Average Accuracy'), findsOneWidget);

      // Verify Disclaimer
      expect(find.text('Medical & Clinical Decision Support Notice'), findsOneWidget);
    });
  });
}
