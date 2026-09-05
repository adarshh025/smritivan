// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/handloom_pattern.dart';
import 'game_summary_dialog.dart';
import 'game_telemetry_provider.dart';

/// Card item representation in the active game grid
class _GameCard {
  final int cardIndex;
  final HandloomPattern pattern;
  bool isFlipped;
  bool isMatched;

  _GameCard({
    required this.cardIndex,
    required this.pattern,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

/// Game 1: Handloom Pattern Matching (Visual Memory Therapeutic Game)
class HandloomGameScreen extends ConsumerStatefulWidget {
  const HandloomGameScreen({super.key});

  @override
  ConsumerState<HandloomGameScreen> createState() => _HandloomGameScreenState();
}

class _HandloomGameScreenState extends ConsumerState<HandloomGameScreen> {
  List<_GameCard> _cards = [];
  int? _firstSelectedIndex;
  bool _isProcessingMatch = false;
  String _activeFeedbackText = '';
  Timer? _hintTimer;

  static const String _gameTitle = "Handloom Patterns";
  static const String _instructionText = "Tap two cards to find matching patterns.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewRound();
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  /// Initializes card deck scaled by patient's dynamic difficulty level
  void _startNewRound() {
    _firstSelectedIndex = null;
    _isProcessingMatch = false;

    // Start telemetry tracking
    final telemetryNotifier = ref.read(gameTelemetryProvider.notifier);
    telemetryNotifier.startSession(gameType: 'visual_handloom');

    final telemetryState = ref.read(gameTelemetryProvider);
    final difficulty = telemetryState.currentDifficulty;

    // Determine pair count based on clinical DDA scale (1.0 -> 5.0)
    int pairCount = 2; // Default 4 cards (2x2)
    if (difficulty >= 3.6) {
      pairCount = 4; // 8 cards
    } else if (difficulty >= 2.1) {
      pairCount = 3; // 6 cards
    }

    // Select distinct cultural patterns
    final selectedPatterns = (List<HandloomPattern>.from(HandloomPattern.nerPatterns)..shuffle()).take(pairCount).toList();

    // Create paired deck
    final List<_GameCard> deck = [];
    int idx = 0;
    for (final pat in selectedPatterns) {
      deck.add(_GameCard(cardIndex: idx++, pattern: pat));
      deck.add(_GameCard(cardIndex: idx++, pattern: pat));
    }
    deck.shuffle();

    setState(() {
      _cards = deck;
      _activeFeedbackText = '';
    });

    // Play spoken instruction
    ref.read(audioServiceProvider).speakInstruction(_instructionText);

    // Mark turn start
    telemetryNotifier.startTurn();
  }

  void _onCardTapped(int index) {
    if (_isProcessingMatch) return;
    final card = _cards[index];
    if (card.isFlipped || card.isMatched) return;

    final telemetryNotifier = ref.read(gameTelemetryProvider.notifier);

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelectedIndex == null) {
      // First card flipped
      _firstSelectedIndex = index;
      telemetryNotifier.recordInteraction(isCorrect: true);
      telemetryNotifier.startTurn();
    } else {
      // Second card flipped: Evaluate match
      _isProcessingMatch = true;
      final firstCard = _cards[_firstSelectedIndex!];

      if (firstCard.pattern.id == card.pattern.id) {
        // MATCH FOUND
        firstCard.isMatched = true;
        card.isMatched = true;
        _firstSelectedIndex = null;
        _isProcessingMatch = false;

        telemetryNotifier.recordInteraction(isCorrect: true);
        ref.read(audioServiceProvider).playGentleSuccessChime();

        setState(() {
          _activeFeedbackText = "Match found!";
        });

        _checkGameCompletion();
      } else {
        // MISTAKE
        telemetryNotifier.recordInteraction(isCorrect: false);

        setState(() {
          _activeFeedbackText = "Try again.";
        });
        ref.read(audioServiceProvider).speakInstruction("Try again.");

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              firstCard.isFlipped = false;
              card.isFlipped = false;
              _firstSelectedIndex = null;
              _isProcessingMatch = false;
            });
            telemetryNotifier.startTurn();
          }
        });
      }
    }
  }

  void _checkGameCompletion() {
    final allMatched = _cards.every((c) => c.isMatched);
    if (allMatched) {
      Future.delayed(const Duration(milliseconds: 600), () async {
        final telemetryNotifier = ref.read(gameTelemetryProvider.notifier);
        final ddaResult = await telemetryNotifier.completeSession();

        if (mounted) {
          final locale = Localizations.localeOf(context).languageCode;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GameSummaryDialog(
              ddaResult: ddaResult,
              languageCode: locale,
              onPlayAgain: () {
                Navigator.of(context).pop();
                _startNewRound();
              },
              onReturnHome: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(gameTelemetryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(_gameTitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softSageGreen.withAlpha(80),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Text(
              'Lvl: ${telemetry.currentDifficulty.toStringAsFixed(1)}',
              style: AppTypography.metricLabel.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.deepSageGreen,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Voice & Instructions Banner
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.softCream,
                  borderRadius: AppDimensions.cardBorderRadius,
                  border: Border.all(color: AppColors.paleParchment, width: 1.5),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 32, color: AppColors.deepSageGreen),
                      onPressed: () {
                        ref.read(audioServiceProvider).speakInstruction(_instructionText);
                      },
                      padding: const EdgeInsets.all(12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _activeFeedbackText.isNotEmpty ? _activeFeedbackText : _instructionText,
                        style: AppTypography.bodyLarge.copyWith(
                          color: _activeFeedbackText.isNotEmpty ? AppColors.deepSageGreen : AppColors.textCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Responsive Accessible Handloom Cards Grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0, // Tweaked for larger touch target
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _buildHandloomCard(card, index);
                  },
                ),
              ),

              // Bottom Accessibility Assistance Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matches: ${telemetry.correctMatches}  |  Errors: ${telemetry.mistakes}',
                    style: AppTypography.metricLabel,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 24),
                    label: Text('Reset', style: AppTypography.bodyMedium),
                    onPressed: _startNewRound,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(100, 64),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandloomCard(_GameCard card, int index) {
    final isRevealed = card.isFlipped || card.isMatched;

    return Semantics(
      label: isRevealed ? card.pattern.nameEnglish : 'Hidden Handloom Card',
      button: true,
      child: InkWell(
        onTap: () => _onCardTapped(index),
        borderRadius: AppDimensions.cardBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isRevealed ? AppColors.softCream : AppColors.cardSurface,
            borderRadius: AppDimensions.cardBorderRadius,
            border: Border.all(
              color: card.isMatched
                  ? AppColors.successSage
                  : (card.isFlipped ? AppColors.focusRing : AppColors.paleParchment),
              width: card.isMatched || card.isFlipped ? 3.0 : 1.5,
            ),
            boxShadow: isRevealed
                ? [
                    BoxShadow(
                      color: AppColors.deepSageGreen.withAlpha(25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isRevealed
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64, // Ensured large touch target dimension
                        height: 64,
                        decoration: BoxDecoration(
                          color: card.pattern.primaryColor.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          card.pattern.motifIcon,
                          size: 38,
                          color: card.pattern.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          card.pattern.nameEnglish,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.yard_outlined,
                        size: 48,
                        color: AppColors.mutedTeal,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Card',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.deepSageGreen.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

