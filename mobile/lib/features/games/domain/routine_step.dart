// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';

/// Step in a daily NER living routine for procedural memory rehabilitation
class RoutineStep {
  final int stepOrder; // 1, 2, 3, 4
  final String titleEnglish;
  final String titleAssamese;
  final String titleMeitei;
  final String titleKhasi;
  final String titleBodo;
  final String titleHindi;
  final IconData icon;

  const RoutineStep({
    required this.stepOrder,
    required this.titleEnglish,
    required this.titleAssamese,
    required this.titleMeitei,
    required this.titleKhasi,
    required this.titleBodo,
    required this.titleHindi,
    required this.icon,
  });

  String getLocalizedTitle(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'as':
        return titleAssamese;
      case 'mni':
        return titleMeitei;
      case 'kha':
        return titleKhasi;
      case 'brx':
        return titleBodo;
      case 'hi':
        return titleHindi;
      default:
        return titleEnglish;
    }
  }
}

/// A complete multi-step daily activity sequence
class RoutineActivity {
  final String id;
  final String nameEnglish;
  final String nameAssamese;
  final String nameMeitei;
  final String nameKhasi;
  final String nameBodo;
  final String nameHindi;
  final List<RoutineStep> steps;

  const RoutineActivity({
    required this.id,
    required this.nameEnglish,
    required this.nameAssamese,
    required this.nameMeitei,
    required this.nameKhasi,
    required this.nameBodo,
    required this.nameHindi,
    required this.steps,
  });

  String getLocalizedName(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'as':
        return nameAssamese;
      case 'mni':
        return nameMeitei;
      case 'kha':
        return nameKhasi;
      case 'brx':
        return nameBodo;
      case 'hi':
        return nameHindi;
      default:
        return nameEnglish;
    }
  }

  static const List<RoutineActivity> nerRoutines = [
    RoutineActivity(
      id: 'making_assam_tea',
      nameEnglish: 'Making Fresh Assam Tea (চাহ বনোৱা)',
      nameAssamese: 'অসমীয়া ৰঙা বা গাখীৰ চাহ বনোৱা',
      nameMeitei: 'অসাম চা শেম্বা (Making Tea)',
      nameKhasi: 'Shet Sha Assam',
      nameBodo: 'साहा बानायनाय (Making Tea)',
      nameHindi: 'असम की ताज़ा चाय बनाना',
      steps: [
        RoutineStep(
          stepOrder: 1,
          titleEnglish: '1. Boil pure fresh water in kettle',
          titleAssamese: '১. কেটলীত পৰিষ্কাৰ পানী উতলাওক',
          titleMeitei: '১. ঈশিং থম্বীদা ফুত্থোকউ',
          titleKhasi: '1. Pynkhluit um ha ketli',
          titleBodo: '1. केतलियाव दै फुदुं',
          titleHindi: '१. केतली में साफ़ पानी उबालें',
          icon: Icons.water_drop,
        ),
        RoutineStep(
          stepOrder: 2,
          titleEnglish: '2. Add aromatic Assam CTC tea leaves',
          titleAssamese: '২. সুগন্ধি অসমৰ চাহপাত দিয়ক',
          titleMeitei: '২. অসাম চা-মনা হাপ্পু',
          titleKhasi: '2. Thep sla sha Assam',
          titleBodo: '2. मोजां साहा बिखा हो',
          titleHindi: '२. असम की कड़क चाय पत्ती डालें',
          icon: Icons.eco,
        ),
        RoutineStep(
          stepOrder: 3,
          titleEnglish: '3. Add warm milk and fresh crushed ginger',
          titleAssamese: '৩. অলপ গাখীৰ আৰু আদাৰ ৰস দিয়ক',
          titleMeitei: '৩. শঙ্গোম অমসুং শিঙ হাপ্পু',
          titleKhasi: '3. Thep dud bad sying',
          titleBodo: '3. गायखेर आरो सिनारि हो',
          titleHindi: '३. दूध और कुटा हुआ अदरक डालें',
          icon: Icons.coffee,
        ),
        RoutineStep(
          stepOrder: 4,
          titleEnglish: '4. Strain the hot fragrant tea into clay cup',
          titleAssamese: '৪. গৰম চাহ কাপত চালি পৰিবেশন কৰক',
          titleMeitei: '৪. চা কাপতা চেন্সুন খায়উ',
          titleKhasi: '4. Thep ha khuri sha',
          titleBodo: '4. खाबआव साहा सारना ला',
          titleHindi: '४. छानकर गरमा-गरम चाय का आनंद लें',
          icon: Icons.emoji_food_beverage,
        ),
      ],
    ),
  ];
}

