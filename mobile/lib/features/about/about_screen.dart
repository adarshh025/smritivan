// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

/// About Screen displaying Team laccha paratha metadata, SIH 2026 Hackathon details,
/// and clinical architecture acknowledgements.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SMRITIVAN'),
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
              // Hero Brand Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.softCream,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.paleParchment, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.softSageGreen.withAlpha(80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 48,
                        color: AppColors.deepSageGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SMRITIVAN (स्मृतिवन)',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.deepSageGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cognitive Gaming & Memory Assistance for Elderly Dementia Patients in NER',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mutedTeal.withAlpha(40),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      ),
                      child: Text(
                        'SIH 2026 • Problem Statement ID: 26003',
                        style: AppTypography.metricLabel.copyWith(
                          color: AppColors.textCharcoal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Team laccha paratha Attribution Card
              Card(
                child: Padding(
                  padding: AppDimensions.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.groups_outlined, color: AppColors.deepSageGreen, size: 30),
                          const SizedBox(width: 12),
                          Text('Development Team', style: AppTypography.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warmSand,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        ),
                        child: Text(
                          'Team: Team laccha paratha',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepSageGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Core Contributors:', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildMemberTile('Adarsh A', 'Principal Architect & Full-Stack Lead'),
                      _buildMemberTile('Twinkle B', 'Cognitive DDA Engine Lead'),
                      _buildMemberTile('Kashish', 'Clinical UI/UX & Dementia Accessibility'),
                      _buildMemberTile('Utkarsh', 'Offline CRDT & Encrypted SQLite Lead'),
                      _buildMemberTile('Pratibha', 'NER Cultural Audio & Regional Voice Lead'),
                      _buildMemberTile('Akash', 'FastAPI Backend & Cloud Sync Engineer'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Architectural & Clinical Compliance
              Card(
                child: Padding(
                  padding: AppDimensions.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, color: AppColors.deepSageGreen, size: 30),
                          const SizedBox(width: 12),
                          Text('Clinical & Tech Standards', style: AppTypography.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStandardItem(Icons.lock_outline, 'ABHA Digital Health AES-256 local database encryption'),
                      _buildStandardItem(Icons.wifi_off_outlined, 'CRDT Hybrid Logical Clock (HLC) offline-first sync'),
                      _buildStandardItem(Icons.auto_graph_outlined, 'Real-time On-Device Cognitive Vitality Score (CVS) DDA'),
                      _buildStandardItem(Icons.translate_outlined, 'Bhashini & Vosk NER Regional Speech (Assamese, Meitei, Khasi, Bodo)'),
                      _buildStandardItem(Icons.wb_twilight_outlined, 'Sundowning-safe low-arousal accessibility framework'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Copyright Notice
              Text(
                '© 2026 Team laccha paratha. All rights reserved.\nLicensed for Smart India Hackathon 2026.',
                style: AppTypography.metricLabel,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColors.softSageGreen),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodyMedium,
                children: [
                  TextSpan(
                    text: '$name: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                  ),
                  TextSpan(text: role),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardItem(IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.mutedTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

