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
import '../../../core/localization/regional_voice_prompts.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../domain/routine_step.dart';
import 'game_summary_dialog.dart';
import 'game_telemetry_provider.dart';

/// Game 3: Daily NER Life Sequencing (Procedural Memory Recovery)
class RoutineGameScreen extends ConsumerStatefulWidget {
  const RoutineGameScreen({super.key});

  @override
  ConsumerState<RoutineGameScreen> createState() => _RoutineGameScreenState();
}

class _RoutineGameScreenState extends ConsumerState<RoutineGameScreen> {
  final RoutineActivity _activity = RoutineActivity.nerRoutines.first;
  List<RoutineStep> _shuffledSteps = [];
  int _nextExpectedStep = 1;
  final Set<int> _completedStepOrders = {};
  String _activeFeedback = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  void _startSession() {
    final telemetry = ref.read(gameTelemetryProvider.notifier);
    telemetry.startSession(gameType: 'routine_recall');

    setState(() {
      _shuffledSteps = List<RoutineStep>.from(_activity.steps)..shuffle();
      _nextExpectedStep = 1;
      _completedStepOrders.clear();
      _activeFeedback = '';
    });

    telemetry.startTurn();
  }

  void _onStepTapped(RoutineStep step) async {
    if (_completedStepOrders.contains(step.stepOrder)) return;

    final telemetry = ref.read(gameTelemetryProvider.notifier);
    final user = ref.read(activeUserProvider).value;
    final langCode = user?.nativeLanguage ?? 'as';

    if (step.stepOrder == _nextExpectedStep) {
      // CORRECT SEQUENCE
      telemetry.recordInteraction(isCorrect: true);
      ref.read(audioServiceProvider).playGentleSuccessChime();

      setState(() {
        _completedStepOrders.add(step.stepOrder);
        _nextExpectedStep++;
        _activeFeedback = RegionalVoicePrompts.get(langCode, 'match_found');
      });

      if (_completedStepOrders.length == _activity.steps.length) {
        // All steps sequenced!
        final ddaResult = await telemetry.completeSession();
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GameSummaryDialog(
              ddaResult: ddaResult,
              languageCode: langCode,
              onPlayAgain: () {
                Navigator.of(context).pop();
                _startSession();
              },
              onReturnHome: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          );
        }
      } else {
        telemetry.startTurn();
      }
    } else {
      // INCORRECT STEP
      telemetry.recordInteraction(isCorrect: false);
      setState(() {
        _activeFeedback = RegionalVoicePrompts.get(langCode, 'try_again');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(activeUserProvider).value;
    final langCode = user?.nativeLanguage ?? 'as';
    final gameTitle = RegionalVoicePrompts.get(langCode, 'game3_title');
    final instruction = RegionalVoicePrompts.get(langCode, 'game3_instruction');

    return Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prompt banner
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.softCream,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.paleParchment, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      _activity.getLocalizedName(langCode),
                      style: AppTypography.titleMedium.copyWith(color: AppColors.deepSageGreen),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _activeFeedback.isNotEmpty ? _activeFeedback : instruction,
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Sequenced Steps List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _shuffledSteps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final step = _shuffledSteps[idx];
                    final isDone = _completedStepOrders.contains(step.stepOrder);

                    return InkWell(
                      onTap: () => _onStepTapped(step),
                      borderRadius: AppDimensions.cardBorderRadius,
                      child: Container(
                        height: 84,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.softSageGreen.withAlpha(60) : Colors.white,
                          borderRadius: AppDimensions.cardBorderRadius,
                          border: Border.all(
                            color: isDone ? AppColors.successSage : AppColors.paleParchment,
                            width: isDone ? 2.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDone ? AppColors.successSage : AppColors.softCream,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDone ? Icons.check : step.icon,
                                size: 28,
                                color: isDone ? Colors.white : AppColors.mutedTeal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.getLocalizedTitle(langCode),
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                                  color: isDone ? AppColors.deepSageGreen : AppColors.textCharcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Text(
                'Next Step: $_nextExpectedStep of ${_activity.steps.length}',
                style: AppTypography.metricLabel,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

