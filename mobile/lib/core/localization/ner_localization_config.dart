// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';

/// Represents a North Eastern State with its linguistic & regional metadata
class NerStateInfo {
  final String id;
  final String name;
  final String nativeName;
  final String capital;
  final String primaryLanguageCode;
  final List<String> supportedLanguageCodes;
  final String icon;
  final String culturalTagline;

  const NerStateInfo({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.capital,
    required this.primaryLanguageCode,
    required this.supportedLanguageCodes,
    required this.icon,
    required this.culturalTagline,
  });
}

/// Represents a language capability within the multi-lingual NER cognitive architecture
class NerLanguageCapability {
  final String code; // ISO-639-1/3 language code (e.g., 'as', 'bn', 'hi', 'en', 'ne')
  final String name; // English display name
  final String nativeName; // Native script display name
  final String flag; // Region/Country flag
  final String ttsLocale; // Target locale string for Text-To-Speech engine (e.g. 'as-IN', 'hi-IN')
  final bool isUiSupported; // Fully localized UI string bundles exist
  final bool isNativeTtsAvailableByDefault; // Typical default on standard Google/Android TTS engines
  final String statusDescription;

  const NerLanguageCapability({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.ttsLocale,
    required this.isUiSupported,
    required this.isNativeTtsAvailableByDefault,
    required this.statusDescription,
  });
}

/// Central authoritative configuration for all 8 North Eastern States of India and regional languages
class NerLocalizationConfig {
  NerLocalizationConfig._();

  /// All 8 North Eastern States of India (Complete Coverage)
  static const List<NerStateInfo> allStates = [
    NerStateInfo(
      id: 'assam',
      name: 'Assam',
      nativeName: 'অসম',
      capital: 'Dispur',
      primaryLanguageCode: 'as',
      supportedLanguageCodes: ['as', 'bn', 'hi', 'en'],
      icon: '🦏',
      culturalTagline: 'Land of the Red River and Blue Hills',
    ),
    NerStateInfo(
      id: 'arunachal_pradesh',
      name: 'Arunachal Pradesh',
      nativeName: 'अरुणाचल प्रदेश',
      capital: 'Itanagar',
      primaryLanguageCode: 'en',
      supportedLanguageCodes: ['en', 'hi', 'as'],
      icon: '🏔️',
      culturalTagline: 'Land of the Dawn-Lit Mountains',
    ),
    NerStateInfo(
      id: 'manipur',
      name: 'Manipur',
      nativeName: 'মণিপুর',
      capital: 'Imphal',
      primaryLanguageCode: 'mni',
      supportedLanguageCodes: ['mni', 'en', 'hi', 'bn'],
      icon: '🌺',
      culturalTagline: 'Jeweled Land of Loktak Lake',
    ),
    NerStateInfo(
      id: 'meghalaya',
      name: 'Meghalaya',
      nativeName: 'Meghalaya',
      capital: 'Shillong',
      primaryLanguageCode: 'kha',
      supportedLanguageCodes: ['kha', 'en', 'hi', 'as'],
      icon: '🌧️',
      culturalTagline: 'The Abode of Clouds',
    ),
    NerStateInfo(
      id: 'mizoram',
      name: 'Mizoram',
      nativeName: 'Mizoram',
      capital: 'Aizawl',
      primaryLanguageCode: 'mzo',
      supportedLanguageCodes: ['mzo', 'en', 'hi'],
      icon: '🌿',
      culturalTagline: 'Land of Rolling Hills and Songbirds',
    ),
    NerStateInfo(
      id: 'nagaland',
      name: 'Nagaland',
      nativeName: 'Nagaland',
      capital: 'Kohima',
      primaryLanguageCode: 'en',
      supportedLanguageCodes: ['en', 'hi', 'as'],
      icon: '🦅',
      culturalTagline: 'Land of Festivals and Heritage',
    ),
    NerStateInfo(
      id: 'sikkim',
      name: 'Sikkim',
      nativeName: 'सिक्किम',
      capital: 'Gangtok',
      primaryLanguageCode: 'ne',
      supportedLanguageCodes: ['ne', 'hi', 'en', 'bn'],
      icon: '🌸',
      culturalTagline: 'Valley of Flowers & Kanchenjunga',
    ),
    NerStateInfo(
      id: 'tripura',
      name: 'Tripura',
      nativeName: 'ত্রিপুরা',
      capital: 'Agartala',
      primaryLanguageCode: 'bn',
      supportedLanguageCodes: ['bn', 'hi', 'en'],
      icon: '🏛️',
      culturalTagline: 'Historic Land of Royal Palaces',
    ),
  ];

  /// Comprehensive Language Capabilities Model
  static const List<NerLanguageCapability> languages = [
    NerLanguageCapability(
      code: 'as',
      name: 'Assamese',
      nativeName: 'অসমীয়া',
      flag: '🇮🇳',
      ttsLocale: 'as-IN',
      isUiSupported: true,
      isNativeTtsAvailableByDefault: false,
      statusDescription: 'Full UI & Regional Localization (Voice if engine installed)',
    ),
    NerLanguageCapability(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇮🇳',
      ttsLocale: 'bn-IN',
      isUiSupported: true,
      isNativeTtsAvailableByDefault: true,
      statusDescription: 'Full UI & Native TTS Voice Guidance',
    ),
    NerLanguageCapability(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      ttsLocale: 'hi-IN',
      isUiSupported: true,
      isNativeTtsAvailableByDefault: true,
      statusDescription: 'Full UI & Native TTS Voice Guidance',
    ),
    NerLanguageCapability(
      code: 'en',
      name: 'English',
      nativeName: 'English (India)',
      flag: '🇬🇧',
      ttsLocale: 'en-IN',
      isUiSupported: true,
      isNativeTtsAvailableByDefault: true,
      statusDescription: 'Full UI & Native TTS Voice Guidance',
    ),
    NerLanguageCapability(
      code: 'ne',
      name: 'Nepali',
      nativeName: 'नेपाली',
      flag: '🇳🇵',
      ttsLocale: 'ne-NP',
      isUiSupported: true,
      isNativeTtsAvailableByDefault: true,
      statusDescription: 'Full UI (Sikkim / Gorkha NER) & Native TTS Voice',
    ),
    NerLanguageCapability(
      code: 'mni',
      name: 'Manipuri / Meitei',
      nativeName: 'মৈতৈলোন্',
      flag: '🇮🇳',
      ttsLocale: 'mni-IN',
      isUiSupported: false,
      isNativeTtsAvailableByDefault: false,
      statusDescription: 'Regional Language Asset Pipeline (Text Fallback)',
    ),
    NerLanguageCapability(
      code: 'kha',
      name: 'Khasi',
      nativeName: 'Ka Ktien Khasi',
      flag: '🇮🇳',
      ttsLocale: 'kha-IN',
      isUiSupported: false,
      isNativeTtsAvailableByDefault: false,
      statusDescription: 'Regional Language Asset Pipeline (Text Fallback)',
    ),
    NerLanguageCapability(
      code: 'mzo',
      name: 'Mizo',
      nativeName: 'Mizo ṭawng',
      flag: '🇮🇳',
      ttsLocale: 'mzo-IN',
      isUiSupported: false,
      isNativeTtsAvailableByDefault: false,
      statusDescription: 'Regional Language Asset Pipeline (Text Fallback)',
    ),
  ];

  /// Resolves the recommended TTS locale tag for a given language code
  static String getTtsLocaleForLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'as':
        return 'as-IN';
      case 'bn':
        return 'bn-IN';
      case 'hi':
        return 'hi-IN';
      case 'ne':
        return 'ne-NP';
      case 'mni':
        return 'mni-IN';
      case 'kha':
        return 'kha-IN';
      case 'mzo':
        return 'mzo-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }

  /// Resolves matching NerStateInfo by name or ID
  static NerStateInfo getStateByNameOrId(String query) {
    final clean = query.trim().toLowerCase().replaceAll(' ', '_');
    return allStates.firstWhere(
      (s) => s.id == clean || s.name.toLowerCase() == query.trim().toLowerCase(),
      orElse: () => allStates.first, // Defaults to Assam
    );
  }

  /// Resolves matching language capability by language code
  static NerLanguageCapability getLanguageCapability(String code) {
    return languages.firstWhere(
      (l) => l.code == code.toLowerCase(),
      orElse: () => languages.firstWhere((l) => l.code == 'en'),
    );
  }
}
