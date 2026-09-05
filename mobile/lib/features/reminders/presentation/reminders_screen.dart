// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (স্মৃতিवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../domain/reminder_model.dart';
import 'reminder_provider.dart';

/// Dementia Patient Reminders Screen (Visual & Auditory Daily Schedule)
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersState = ref.watch(remindersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('স্মৃতি সোঁৱৰণী • Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: remindersState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.deepSageGreen)),
          error: (err, _) => Center(child: Text('Error loading schedule: $err', style: AppTypography.bodyMedium)),
          data: (reminders) {
            if (reminders.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppDimensions.screenPadding,
                  child: Text(
                    'No active reminders for today.\nআজিৰ বাবে কোনো সোঁৱৰণী নাই।',
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: AppDimensions.screenPadding,
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rem = reminders[index];
                final isDone = rem.status == 'acknowledged';

                return Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.softSageGreen.withAlpha(40) : Colors.white,
                    borderRadius: AppDimensions.cardBorderRadius,
                    border: Border.all(
                      color: isDone ? AppColors.successSage : AppColors.paleParchment,
                      width: isDone ? 2.0 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepSageGreen.withAlpha(15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon Circle
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: rem.accentColor.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(rem.icon, size: 32, color: rem.accentColor),
                      ),
                      const SizedBox(width: 16),

                      // Time & Detail
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rem.time,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDone ? AppColors.deepSageGreen : AppColors.textCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getReminderTypeLabel(rem.type),
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDone ? AppColors.textMuted : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Spoken Audio Cue Button
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 32, color: AppColors.mutedTeal),
                        tooltip: 'Play spoken voice reminder',
                        onPressed: () {
                          if (rem.assetUrl != null && rem.assetUrl!.isNotEmpty) {
                            ref.read(audioServiceProvider).playInstructionWithFallback(rem.assetUrl!, rem.title);
                          } else {
                            ref.read(audioServiceProvider).speakInstruction(rem.title);
                          }
                        },
                      ),

                      const SizedBox(width: 8),

                      // Acknowledge Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone ? AppColors.successSage : AppColors.softSageGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          minimumSize: const Size(64, 56),
                        ),
                        onPressed: isDone
                            ? null
                            : () {
                                ref.read(remindersListProvider.notifier).acknowledgeReminder(rem.id);
                              },
                        child: Icon(
                          isDone ? Icons.check_circle : Icons.check,
                          size: 28,
                          color: isDone ? Colors.white : AppColors.textCharcoal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getReminderTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'medicine':
        return 'ঔষধ খোৱাৰ সময় • Medication';
      case 'water':
        return 'পানী খোৱাৰ সময় • Hydration';
      case 'walk':
        return 'সন্ধিয়া খোজ কঢ়া • Evening Walk';
      default:
        return 'দৈনন্দিন কাম • Daily Task';
    }
  }
}

