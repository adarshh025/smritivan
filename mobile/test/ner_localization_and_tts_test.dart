// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smritivan_app/core/localization/ner_localization_config.dart';
import 'package:smritivan_app/features/auth_profile/domain/user_model.dart';
import 'package:smritivan_app/core/audio/audio_service.dart';
import 'package:smritivan_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:smritivan_app/features/settings/presentation/patient_settings_view.dart';
import 'package:smritivan_app/l10n/app_localizations.dart';

void main() {
  group('1. North Eastern Region (NER) 8-State Coverage', () {
    test('All 8 NER states are present and correctly configured', () {
      expect(NerLocalizationConfig.allStates.length, 8);

      final stateNames = NerLocalizationConfig.allStates.map((s) => s.name).toSet();
      expect(stateNames.contains('Arunachal Pradesh'), isTrue);
      expect(stateNames.contains('Assam'), isTrue);
      expect(stateNames.contains('Manipur'), isTrue);
      expect(stateNames.contains('Meghalaya'), isTrue);
      expect(stateNames.contains('Mizoram'), isTrue);
      expect(stateNames.contains('Nagaland'), isTrue);
      expect(stateNames.contains('Sikkim'), isTrue);
      expect(stateNames.contains('Tripura'), isTrue);
    });

    test('Each NER state has valid capital and cultural information', () {
      for (final state in NerLocalizationConfig.allStates) {
        expect(state.name.isNotEmpty, isTrue);
        expect(state.capital.isNotEmpty, isTrue);
        expect(state.nativeName.isNotEmpty, isTrue);
        expect(state.primaryLanguageCode.isNotEmpty, isTrue);
        expect(state.icon.isNotEmpty, isTrue);
      }
    });

    test('State lookup by name or id resolves reliably', () {
      final assam = NerLocalizationConfig.getStateByNameOrId('assam');
      expect(assam.name, 'Assam');
      expect(assam.capital, 'Dispur');

      final sikkim = NerLocalizationConfig.getStateByNameOrId('Sikkim');
      expect(sikkim.name, 'Sikkim');
      expect(sikkim.primaryLanguageCode, 'ne');

      final arunachal = NerLocalizationConfig.getStateByNameOrId('Arunachal Pradesh');
      expect(arunachal.name, 'Arunachal Pradesh');
      expect(arunachal.capital, 'Itanagar');
    });
  });

  group('2. Multilingual TTS Locale Mapping & Language Capabilities', () {
    test('TTS locale resolution matches standard regional engine tags', () {
      expect(NerLocalizationConfig.getTtsLocaleForLanguage('as'), 'as-IN');
      expect(NerLocalizationConfig.getTtsLocaleForLanguage('bn'), 'bn-IN');
      expect(NerLocalizationConfig.getTtsLocaleForLanguage('hi'), 'hi-IN');
      expect(NerLocalizationConfig.getTtsLocaleForLanguage('ne'), 'ne-NP');
      expect(NerLocalizationConfig.getTtsLocaleForLanguage('en'), 'en-IN');
    });

    test('Language capabilities explicitly define UI and Native TTS status', () {
      final asLang = NerLocalizationConfig.getLanguageCapability('as');
      expect(asLang.isUiSupported, isTrue);
      expect(asLang.ttsLocale, 'as-IN');

      final bnLang = NerLocalizationConfig.getLanguageCapability('bn');
      expect(bnLang.isUiSupported, isTrue);
      expect(bnLang.ttsLocale, 'bn-IN');

      final neLang = NerLocalizationConfig.getLanguageCapability('ne');
      expect(neLang.isUiSupported, isTrue);
      expect(neLang.ttsLocale, 'ne-NP');
    });
  });

  group('3. UserModel State & Language Serialization', () {
    test('UserModel serializes and deserializes state correctly', () {
      const user = UserModel(
        id: 'patient_ner_001',
        name: 'Bhaben Bora (ভবেন বৰা)',
        nativeLanguage: 'as',
        state: 'Assam',
        dementiaStage: 'Early-Stage MCI',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        hlcTimestamp: '1.0',
      );

      final map = user.toMap();
      expect(map['state'], 'Assam');
      expect(map['native_language'], 'as');

      final restored = UserModel.fromMap(map);
      expect(restored.state, 'Assam');
      expect(restored.nativeLanguage, 'as');
    });

    test('UserModel copyWith preserves or updates state reliably', () {
      const user = UserModel(
        id: 'patient_ner_002',
        name: 'Tashi Lepcha',
        nativeLanguage: 'ne',
        state: 'Sikkim',
        dementiaStage: 'Early-Stage MCI',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        hlcTimestamp: '1.0',
      );

      final updated = user.copyWith(state: 'Manipur', nativeLanguage: 'mni');
      expect(updated.state, 'Manipur');
      expect(updated.nativeLanguage, 'mni');
    });
  });

  group('4. UI Widget Rendering for Settings & Onboarding', () {
    testWidgets('PatientSettingsView renders State and Language options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PatientSettingsView(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text("North Eastern State"), findsOneWidget);
      expect(find.text("Language"), findsOneWidget);
    });
  });
}
