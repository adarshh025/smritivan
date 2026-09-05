// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Cultural Heritage Handloom Weave Definition for Dementia Visual Memory
class HandloomPattern {
  final String id;
  final String nameEnglish;
  final String nameAssamese;
  final String nameMeitei;
  final String nameKhasi;
  final String nameBodo;
  final String nameHindi;
  final String region;
  final String culturalDescription;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData motifIcon;
  final String assetGraphic;

  const HandloomPattern({
    required this.id,
    required this.nameEnglish,
    required this.nameAssamese,
    required this.nameMeitei,
    required this.nameKhasi,
    required this.nameBodo,
    required this.nameHindi,
    required this.region,
    required this.culturalDescription,
    required this.primaryColor,
    required this.secondaryColor,
    required this.motifIcon,
    required this.assetGraphic,
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

  /// Master Registry of NER Authentic Handloom Patterns
  static const List<HandloomPattern> nerPatterns = [
    HandloomPattern(
      id: 'muga_silk',
      nameEnglish: 'Muga Golden Silk',
      nameAssamese: 'মুগা ৰেচম (Muga Silk)',
      nameMeitei: 'মুগা খোইচি (Muga Silk)',
      nameKhasi: 'Kymphad Muga',
      nameBodo: 'मुगा रेशम (Muga)',
      nameHindi: 'मूगा गोल्डन सिल्क',
      region: 'Assam / Sualkuchi',
      culturalDescription: 'The sacred golden silk of the Brahmaputra valley woven with ancient Kingkhap peacock motifs.',
      primaryColor: AppColors.mugaGoldenSilk,
      secondaryColor: AppColors.nagaWeaveRed,
      motifIcon: Icons.auto_awesome,
      assetGraphic: 'assets/images/handloom/muga_silk.png',
    ),
    HandloomPattern(
      id: 'eri_silk',
      nameEnglish: 'Eri Ahimsa Silk',
      nameAssamese: 'এৰী কাপোৰ (Eri Silk)',
      nameMeitei: 'এরি ফি (Eri Phi)',
      nameKhasi: 'Ryndia Khasi Weave',
      nameBodo: 'एंडी रेशम (Endi)',
      nameHindi: 'एरी अहिंसा सिल्क',
      region: 'Meghalaya / Ri-Bhoi & Assam',
      culturalDescription: 'Peace silk handspun in Ri-Bhoi district with natural plant dyes and warm earthy texture.',
      primaryColor: AppColors.eriSilkIvory,
      secondaryColor: AppColors.deepSageGreen,
      motifIcon: Icons.spa_outlined,
      assetGraphic: 'assets/images/handloom/eri_silk.png',
    ),
    HandloomPattern(
      id: 'naga_shawl',
      nameEnglish: 'Naga Warrior Shawl',
      nameAssamese: 'নগা শাল (Naga Shawl)',
      nameMeitei: 'নাগা ফি (Naga Phi)',
      nameKhasi: 'Jainsem Naga',
      nameBodo: 'नागा शाल (Naga)',
      nameHindi: 'नागा पारंपरिक शॉल',
      region: 'Nagaland / Kohima & Mokokchung',
      culturalDescription: 'Geometric lozenge patterns representing courage, woven with rich madder red and midnight black.',
      primaryColor: AppColors.nagaWeaveRed,
      secondaryColor: AppColors.textCharcoal,
      motifIcon: Icons.grid_view_rounded,
      assetGraphic: 'assets/images/handloom/naga_shawl.png',
    ),
    HandloomPattern(
      id: 'manipuri_phanek',
      nameEnglish: 'Manipuri Mayek Naibi',
      nameAssamese: 'মণিপুৰী ফনেক (Manipuri Phanek)',
      nameMeitei: 'মায়েক নাইবী ফনেক (Mayek Naibi)',
      nameKhasi: 'Jain Phanek Manipur',
      nameBodo: 'मनिपुरी फनेक (Phanek)',
      nameHindi: 'मणिपुरी मयेक नैबी',
      region: 'Manipur / Imphal Valley',
      culturalDescription: 'Traditional Meitei wrap-around skirt with sacred geometric borders and lotus motifs.',
      primaryColor: AppColors.mutedTeal,
      secondaryColor: AppColors.mugaGoldenSilk,
      motifIcon: Icons.filter_vintage,
      assetGraphic: 'assets/images/handloom/manipuri_phanek.png',
    ),
    HandloomPattern(
      id: 'bodo_dokhona',
      nameEnglish: 'Bodo Dokhona Agor',
      nameAssamese: 'বড়ো দখনা (Bodo Dokhona)',
      nameMeitei: 'বোডো দখন (Bodo Dokhona)',
      nameKhasi: 'Jain Dokhona Bodo',
      nameBodo: 'दखना आगर (Dokhona Agor)',
      nameHindi: 'बोडो दखना आगर',
      region: 'Bodoland / Kokrajhar',
      culturalDescription: 'Vibrant saffron and green attire adorned with sacred Hajw (mountain) and Dauri weaving motifs.',
      primaryColor: AppColors.gentleAmber,
      secondaryColor: AppColors.bambooGroveGreen,
      motifIcon: Icons.terrain_outlined,
      assetGraphic: 'assets/images/handloom/bodo_dokhona.png',
    ),
    HandloomPattern(
      id: 'mizo_puan',
      nameEnglish: 'Mizo Puanchei',
      nameAssamese: 'মিজো পুয়ানচেই (Mizo Puanchei)',
      nameMeitei: 'মিজো পুয়ান (Mizo Puan)',
      nameKhasi: 'Jain Puanchei Mizoram',
      nameBodo: 'मिजो पुवान (Mizo Puan)',
      nameHindi: 'मिज़ो पुआनचेई',
      region: 'Mizoram / Aizawl',
      culturalDescription: 'Celebratory handloom featuring horizontal striped bands symbolizing community festivities.',
      primaryColor: AppColors.calmBlue,
      secondaryColor: AppColors.warmSand,
      motifIcon: Icons.horizontal_split_rounded,
      assetGraphic: 'assets/images/handloom/mizo_puan.png',
    ),
  ];
}

