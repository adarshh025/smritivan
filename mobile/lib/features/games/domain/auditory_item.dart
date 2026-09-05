// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';

/// Auditory Item for Game 2: Identifying North-Eastern Sounds
class AuditoryItem {
  final String id;
  final String nameEnglish;
  final String nameAssamese;
  final String nameMeitei;
  final String nameKhasi;
  final String nameBodo;
  final String nameHindi;
  final String soundAsset;
  final IconData icon;
  final String hintText;

  const AuditoryItem({
    required this.id,
    required this.nameEnglish,
    required this.nameAssamese,
    required this.nameMeitei,
    required this.nameKhasi,
    required this.nameBodo,
    required this.nameHindi,
    required this.soundAsset,
    required this.icon,
    required this.hintText,
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

  static const List<AuditoryItem> nerSounds = [
    AuditoryItem(
      id: 'pepa_horn',
      nameEnglish: 'Pepa (Buffalo Horn Pipe)',
      nameAssamese: 'পেঁপা (Buffalo Horn Pipe)',
      nameMeitei: 'পেপা (Pepa Horn)',
      nameKhasi: 'Pepa Horn Assam',
      nameBodo: 'पेपा (Pepa)',
      nameHindi: 'पेपा (भैंस के सींग की बांसुरी)',
      soundAsset: 'audio/ner_sounds/pepa_sound.mp3',
      icon: Icons.music_note_rounded,
      hintText: 'Traditional Bihu folk wind instrument made of buffalo horn',
    ),
    AuditoryItem(
      id: 'bihu_dhol',
      nameEnglish: 'Bihu Dhol (Folk Drum)',
      nameAssamese: 'বিহু ঢোল (Bihu Dhol)',
      nameMeitei: 'ঢোল (Bihu Dhol)',
      nameKhasi: 'Ksing Dhol',
      nameBodo: 'दोल (Bihu Dhol)',
      nameHindi: 'बिहू ढोल (पारंपरिक ताल)',
      soundAsset: 'audio/ner_sounds/dhol_sound.mp3',
      icon: Icons.album_outlined,
      hintText: 'Rhythmic wooden drum played during harvest celebrations',
    ),
    AuditoryItem(
      id: 'cherrapunji_rain',
      nameEnglish: 'Cherrapunji Gentle Rain',
      nameAssamese: 'চেৰাপুঞ্জীৰ বৰষুণ (Rain)',
      nameMeitei: 'নোহাংলা নোং (Sohra Rain)',
      nameKhasi: 'Slap Sohra (Rain of Sohra)',
      nameBodo: 'अखा (Sohra Rain)',
      nameHindi: 'चेरापूंजी की हल्की फुहारें',
      soundAsset: 'audio/ner_sounds/cherrapunji_gentle_rain.mp3',
      icon: Icons.water_drop_outlined,
      hintText: 'Soothing rainfall over the lush green Meghalaya hills',
    ),
    AuditoryItem(
      id: 'hornbill_call',
      nameEnglish: 'Great Indian Hornbill',
      nameAssamese: 'ধনেশ পক্ষী (Hornbill)',
      nameMeitei: 'উচেক উচাও (Hornbill)',
      nameKhasi: 'Sim Hornbill',
      nameBodo: 'दाव हादा (Hornbill)',
      nameHindi: 'धनेश पक्षी की पुकार',
      soundAsset: 'audio/ner_sounds/hornbill_call.mp3',
      icon: Icons.air_outlined,
      hintText: 'The majestic call of the sacred bird of Nagaland & Arunachal forests',
    ),
  ];
}

