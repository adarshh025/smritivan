// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/regional_voice_prompts.dart';
import '../../auth_profile/presentation/user_provider.dart';
import 'auditory_game_screen.dart';
import 'handloom_game_screen.dart';
import 'routine_game_screen.dart';

/// Dementia Patient Games Hub - Central portal for all 3 NER therapeutic games
class GameHubScreen extends ConsumerWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(activeUserProvider).value;
    final langCode = user?.nativeLanguage ?? 'as';

    return Scaffold(
      appBar: AppBar(
        title: const Text('জ্ঞানীয় খেলসমূহ • Cognitive Games'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero prompt
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppColors.softCream,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.paleParchment, width: 1.5),
                ),
                child: Text(
                  'আপোনাৰ মন আৰু স্মৃতি সতেজ ৰাখক (Keep mind & memory fresh)',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.deepSageGreen),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Game 1 Card: Handloom Matching
              _buildGamePortalCard(
                context: context,
                title: RegionalVoicePrompts.get(langCode, 'game1_title'),
                subtitle: RegionalVoicePrompts.get(langCode, 'game1_subtitle'),
                description: 'Muga, Eri silk & Naga weaves visual pattern pairs',
                icon: Icons.yard_outlined,
                badgeColor: AppColors.mugaGoldenSilk,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HandloomGameScreen()),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Game 2 Card: Auditory Focus
              _buildGamePortalCard(
                context: context,
                title: RegionalVoicePrompts.get(langCode, 'game2_title'),
                subtitle: RegionalVoicePrompts.get(langCode, 'game2_subtitle'),
                description: 'Identify Pepa, Bihu Dhol, Cherrapunji rain & Hornbill',
                icon: Icons.graphic_eq_rounded,
                badgeColor: AppColors.mutedTeal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuditoryGameScreen()),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Game 3 Card: Daily Routine Recall
              _buildGamePortalCard(
                context: context,
                title: RegionalVoicePrompts.get(langCode, 'game3_title'),
                subtitle: RegionalVoicePrompts.get(langCode, 'game3_subtitle'),
                description: 'Step-by-step procedural sequencing for Assam tea preparation',
                icon: Icons.coffee_outlined,
                badgeColor: AppColors.gentleAmber,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RoutineGameScreen()),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamePortalCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.cardBorderRadius,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimensions.cardBorderRadius,
          border: Border.all(color: AppColors.paleParchment, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepSageGreen.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(50),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 2),
              ),
              child: Icon(icon, size: 40, color: AppColors.deepSageGreen),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.metricLabel.copyWith(
                      color: AppColors.mutedTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded, size: 44, color: AppColors.softSageGreen),
          ],
        ),
      ),
    );
  }
}

