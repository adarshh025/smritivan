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
import '../domain/auditory_item.dart';
import 'game_summary_dialog.dart';
import 'game_telemetry_provider.dart';

/// Game 2: Auditory Focus & Identifying North-Eastern Sounds
class AuditoryGameScreen extends ConsumerStatefulWidget {
  const AuditoryGameScreen({super.key});

  @override
  ConsumerState<AuditoryGameScreen> createState() => _AuditoryGameScreenState();
}

class _AuditoryGameScreenState extends ConsumerState<AuditoryGameScreen> {
  late AuditoryItem _targetSound;
  late List<AuditoryItem> _options;
  int _currentRound = 1;
  static const int _totalRounds = 3;
  String _activeFeedback = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewGameSession();
    });
  }

  void _startNewGameSession() {
    final telemetry = ref.read(gameTelemetryProvider.notifier);
    telemetry.startSession(gameType: 'auditory_focus');
    _currentRound = 1;
    _setupRound();
  }

  void _setupRound() {
    final allSounds = List<AuditoryItem>.from(AuditoryItem.nerSounds)..shuffle();
    _targetSound = allSounds.first;
    _options = allSounds.take(3).toList()..shuffle();

    setState(() {
      _activeFeedback = '';
    });

    _playSoundPrompt();
    ref.read(gameTelemetryProvider.notifier).startTurn();
  }

  void _playSoundPrompt() {
    ref.read(audioServiceProvider).playVoicePrompt(_targetSound.soundAsset);
  }

  void _onOptionSelected(AuditoryItem selected) async {
    final telemetry = ref.read(gameTelemetryProvider.notifier);
    final user = ref.read(activeUserProvider).value;
    final langCode = user?.nativeLanguage ?? 'as';

    if (selected.id == _targetSound.id) {
      telemetry.recordInteraction(isCorrect: true);
      ref.read(audioServiceProvider).playGentleSuccessChime();

      setState(() {
        _activeFeedback = RegionalVoicePrompts.get(langCode, 'match_found');
      });

      await Future.delayed(const Duration(milliseconds: 1200));

      if (_currentRound < _totalRounds) {
        if (mounted) {
          setState(() {
            _currentRound++;
          });
          _setupRound();
        }
      } else {
        // Complete Session
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
                _startNewGameSession();
              },
              onReturnHome: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          );
        }
      }
    } else {
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
    final gameTitle = RegionalVoicePrompts.get(langCode, 'game2_title');
    final instruction = RegionalVoicePrompts.get(langCode, 'game2_instruction');
    final tapToListen = RegionalVoicePrompts.get(langCode, 'tap_to_listen');

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
                child: Text(
                  _activeFeedback.isNotEmpty ? _activeFeedback : instruction,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _activeFeedback.isNotEmpty ? AppColors.deepSageGreen : AppColors.textCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Large Accessible Audio Playback Hero Button
              Center(
                child: InkWell(
                  onTap: _playSoundPrompt,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.softSageGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepSageGreen.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      size: 72,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tapToListen,
                style: AppTypography.metricLabel.copyWith(color: AppColors.deepSageGreen),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Choice Options (Large touch targets >= 72dp)
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final item = _options[idx];
                    return SizedBox(
                      height: 76,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textCharcoal,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        icon: Icon(item.icon, size: 36, color: AppColors.mutedTeal),
                        label: Expanded(
                          child: Text(
                            item.getLocalizedName(langCode),
                            style: AppTypography.titleMedium.copyWith(fontSize: 20),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onPressed: () => _onOptionSelected(item),
                      ),
                    );
                  },
                ),
              ),

              Text(
                'Round $_currentRound of $_totalRounds',
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

