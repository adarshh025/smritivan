// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/regional_voice_prompts.dart';
import '../../../shared/widgets/app_button.dart';
import '../domain/dda_engine.dart';

/// Clinical Game Summary Dialog displaying CVS Telemetry & DDA Adaptation
class GameSummaryDialog extends StatelessWidget {
  final DDAResult ddaResult;
  final String languageCode;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnHome;

  const GameSummaryDialog({
    super.key,
    required this.ddaResult,
    required this.languageCode,
    required this.onPlayAgain,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    final wellDoneText = RegionalVoicePrompts.get(languageCode, 'well_done');
    final cvsTitle = RegionalVoicePrompts.get(languageCode, 'cvs_summary');
    final playAgainText = RegionalVoicePrompts.get(languageCode, 'play_again');
    final returnHomeText = RegionalVoicePrompts.get(languageCode, 'back_home');

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.softCream,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: AppColors.paleParchment, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calming Celebration Icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.softSageGreen.withAlpha(80),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_outline_rounded,
                    size: 44,
                    color: AppColors.deepSageGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                wellDoneText,
                style: AppTypography.titleLarge.copyWith(color: AppColors.deepSageGreen),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Cognitive Vitality Score (CVS) Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.paleParchment, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      cvsTitle,
                      style: AppTypography.metricLabel,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${ddaResult.cvsScore.toStringAsFixed(0)} / 100',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.deepSageGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adaptive Level: ${ddaResult.nextDifficulty.toStringAsFixed(1)}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedTeal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Clinical Metric Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricTile(
                    'Accuracy',
                    '${(ddaResult.successRate * 100).toStringAsFixed(0)}%',
                    Icons.check_circle_outline,
                  ),
                  _buildMetricTile(
                    'Errors',
                    '${(ddaResult.errorRate * 10).toStringAsFixed(0)}',
                    Icons.refresh_rounded,
                  ),
                  _buildMetricTile(
                    'Speed',
                    '${(1.0 - ddaResult.normalizedLatency).clamp(0.1, 1.0) * 100 ~/ 1}%',
                    Icons.speed_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons (>=64dp large touch targets)
              AppButton.primary(
                text: playAgainText,
                onPressed: onPlayAgain,
              ),

              const SizedBox(height: 12),

              AppButton.secondary(
                text: returnHomeText,
                onPressed: onReturnHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.metricLabel),
      ],
    );
  }
}

