// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';

/// Supported North Eastern Regional (NER) & National Locales for Dementia Care
enum NERLanguage {
  assamese(
    code: 'as',
    name: 'Assamese',
    nativeName: 'অসমীয়া',
    region: 'Assam / Brahmaputra Valley',
    bhashiniCode: 'as',
    voskModelPath: 'models/vosk-model-small-as',
  ),
  meitei(
    code: 'mni',
    name: 'Meitei / Manipuri',
    nativeName: 'মৈতৈলোন্ / ꯃꯤꯇꯩꯂꯣꯟ',
    region: 'Manipur / Imphal Valley',
    bhashiniCode: 'mni',
    voskModelPath: 'models/vosk-model-small-mni',
  ),
  khasi(
    code: 'kha',
    name: 'Khasi',
    nativeName: 'Ka Ktien Khasi',
    region: 'Meghalaya / Shillong Plateau',
    bhashiniCode: 'kha',
    voskModelPath: 'models/vosk-model-small-kha',
  ),
  bodo(
    code: 'brx',
    name: 'Bodo',
    nativeName: 'बड़ो / Boro',
    region: 'Bodoland Territorial Region (BTR)',
    bhashiniCode: 'brx',
    voskModelPath: 'models/vosk-model-small-brx',
  ),
  hindi(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    region: 'Pan-India / NER Urban Centres',
    bhashiniCode: 'hi',
    voskModelPath: 'models/vosk-model-small-hi',
  ),
  english(
    code: 'en',
    name: 'English',
    nativeName: 'English (NER Clinical)',
    region: 'Clinical Standard',
    bhashiniCode: 'en',
    voskModelPath: 'models/vosk-model-small-en',
  );

  final String code;
  final String name;
  final String nativeName;
  final String region;
  final String bhashiniCode;
  final String voskModelPath;

  const NERLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.region,
    required this.bhashiniCode,
    required this.voskModelPath,
  });

  Locale get locale => Locale(code);

  static NERLanguage fromCode(String code) {
    return NERLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => NERLanguage.assamese,
    );
  }
}

