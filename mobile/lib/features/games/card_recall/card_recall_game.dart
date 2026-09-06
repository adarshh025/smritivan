// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptic/haptic_service.dart';
import '../../../shared/widgets/app_button.dart';

import '../presentation/friendly_result_view.dart';

class CardRecallGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  const CardRecallGame({Key? key, required this.currentDifficulty}) : super(key: key);

  @override
  ConsumerState<CardRecallGame> createState() => _CardRecallGameState();
}

class _CardRecallGameState extends ConsumerState<CardRecallGame> {
  final List<String> _contentPool = [
    '🍎', '🚗', '🐶', '🌻', '☂️', '🎸', '⚽', '⏰', '🔑', '✈️',
    '🦋', '🐢', '🍉', '🍕', '🍔', '🎁', '🎈', '📚', '✏️', '✂️',
  ];
  
  late List<String> _targetCards;
  late List<String> _options;
  
  bool _isObserving = true;
  List<String> _selectedCards = [];
  bool _isAnswered = false;
  bool _isEvaluating = false;
  final Set<String> _wrongOptionsChosen = {};
  String? _feedbackMessage;
  Timer? _observeTimer;
  Timer? _endTimer;

  late int _qType; // 1 = Objects, 2 = Position/Order
  late String _questionPrompt;
  late String _correctAnswerString;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).reset();
    });
    _setupRound();
  }

  @override
  void dispose() {
    _observeTimer?.cancel();
    _endTimer?.cancel();
    super.dispose();
  }

  void _setupRound() {
    int level = widget.currentDifficulty.floor();
    int cardCount;
    int observeMs;

    if (level <= 1) {
      cardCount = 3;
      observeMs = 6000;
      _qType = 1;
    } else if (level == 2) {
      cardCount = 4;
      observeMs = 6000;
      _qType = 1;
    } else if (level == 3) {
      cardCount = 5;
      observeMs = 4000;
      _qType = 1;
    } else if (level == 4) {
      cardCount = 6;
      observeMs = 6000;
      _qType = 2; // Position
    } else {
      cardCount = 8;
      observeMs = 8000;
      _qType = 2; // Order/Position
    }

    _contentPool.shuffle();
    _targetCards = _contentPool.take(cardCount).toList();

    if (_qType == 1) {
      _questionPrompt = "Which objects did you see?";
      _options = List.from(_targetCards);
      _options.addAll(_contentPool.skip(cardCount).take(cardCount)); // add distractors
      _options.shuffle();
    } else {
      final random = Random();
      int askIndex = random.nextInt(cardCount);
      String posStr = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth'][askIndex];
      _questionPrompt = "What was the $posStr card?";
      _correctAnswerString = _targetCards[askIndex];
      _options = List.from(_targetCards);
      _options.shuffle();
    }

    _observeTimer = Timer(Duration(milliseconds: observeMs), () {
      if (mounted) {
        setState(() {
          _isObserving = false;
        });
        ref.read(gameSessionProvider.notifier).startInteraction();
      }
    });
  }

  void _onOptionSelected(String option) {
    if (_isAnswered || _isEvaluating) return;

    if (_qType == 1) {
      ref.read(hapticServiceProvider).selection();
      // Multi-select for objects
      setState(() {
        if (_selectedCards.contains(option)) {
          _selectedCards.remove(option);
        } else {
          _selectedCards.add(option);
        }
        _feedbackMessage = null; // Clear retry banner when user adjusts selection
      });
    } else {
      // Single select for position
      if (_wrongOptionsChosen.contains(option)) return;

      setState(() => _isEvaluating = true);

      bool isCorrect = (option == _correctAnswerString);
      ref.read(gameSessionProvider.notifier).recordAttempt(
        success: isCorrect,
        errorsInAttempt: isCorrect ? 0 : 1,
      );

      if (isCorrect) {
        ref.read(hapticServiceProvider).success();
        ref.read(audioServiceProvider).playGentleSuccessChime();

        setState(() {
          _selectedCards = [option];
          _isAnswered = true;
          _feedbackMessage = "✓ Correct!";
          _isEvaluating = false;
        });

        _endGame();
      } else {
        ref.read(hapticServiceProvider).error();
        ref.read(audioServiceProvider).playErrorChime();

        setState(() {
          _wrongOptionsChosen.add(option);
          _feedbackMessage = "Try Again";
          _isEvaluating = false;
        });
      }
    }
  }

  void _submitMultiAnswer() {
    if (_isAnswered || _isEvaluating || _selectedCards.isEmpty) return;

    setState(() => _isEvaluating = true);

    bool isCorrect = _selectedCards.length == _targetCards.length && 
                     _selectedCards.every((item) => _targetCards.contains(item));

    ref.read(gameSessionProvider.notifier).recordAttempt(
      success: isCorrect,
      errorsInAttempt: isCorrect ? 0 : 1,
    );

    if (isCorrect) {
      ref.read(hapticServiceProvider).success();
      ref.read(audioServiceProvider).playGentleSuccessChime();

      setState(() {
        _isAnswered = true;
        _feedbackMessage = "✓ Correct!";
        _isEvaluating = false;
      });

      _endGame();
    } else {
      ref.read(hapticServiceProvider).error();
      ref.read(audioServiceProvider).playErrorChime();

      setState(() {
        _feedbackMessage = "Try Again! Pick the ${_targetCards.length} cards shown.";
        _isEvaluating = false;
      });
    }
  }

  void _endGame() {
    _endTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        ref.read(audioServiceProvider).speakInstruction("Excellent. You completed the level.");
        ref.read(gameSessionProvider.notifier).finalizeAndSaveSession(
          currentDifficulty: widget.currentDifficulty,
          gameType: 'card_recall',
          ref: ref,
        ).then((results) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FriendlyResultView(
                  gameType: 'card_recall',
                  gameTitle: 'Card Recall',
                  gameIcon: '🃏',
                  gameColor: const Color(0xFFF4A261),
                  currentLevel: widget.currentDifficulty,
                  results: results,
                  gameBuilder: (lvl) => CardRecallGame(currentDifficulty: lvl),
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CognitiveGameEngine(
      gameTitle: 'Card Recall (Level ${widget.currentDifficulty.toInt()})',
      initialDifficulty: widget.currentDifficulty,
      child: Center(
        child: _isObserving
            ? _buildObservationPhase()
            : _buildSelectionPhase(),
      ),
    );
  }

  Widget _buildObservationPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _qType == 1 ? "Remember these objects..." : "Remember objects AND their order...",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
              onPressed: () {
                ref.read(audioServiceProvider).speakInstruction(_qType == 1 ? "Remember these objects" : "Remember objects and their order");
              },
              tooltip: "Listen to instructions",
            ),
          ],
        ),
        const SizedBox(height: 40),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 16,
          children: _targetCards.map((card) => Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              border: Border.all(color: const Color(0xFF52796F), width: 2),
            ),
            child: Center(child: Text(card, style: const TextStyle(fontSize: 48))),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectionPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _questionPrompt,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
              onPressed: () {
                ref.read(audioServiceProvider).speakInstruction(_questionPrompt);
              },
              tooltip: "Listen to instructions",
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_feedbackMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _isAnswered ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAnswered ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
              ),
            ),
            child: Text(
              _feedbackMessage!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isAnswered ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
              ),
            ),
          ),

        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _options.map((option) {
            bool isSelected = _selectedCards.contains(option);
            final isWrongSingle = _qType == 2 && _wrongOptionsChosen.contains(option);

            Color bgColor = Colors.white;
            Color borderColor = const Color(0xFFCAD2C5);
            
            if (_isAnswered) {
              if (_qType == 1) {
                if (_targetCards.contains(option)) bgColor = const Color(0xFF84A98C);
                else bgColor = Colors.grey[300]!;
              } else {
                if (option == _correctAnswerString) bgColor = const Color(0xFF84A98C);
                else bgColor = Colors.grey[300]!;
              }
            } else if (isWrongSingle) {
              bgColor = Colors.grey.shade200;
              borderColor = Colors.grey.shade400;
            } else if (isSelected) {
              bgColor = const Color(0xFFCAD2C5);
              borderColor = const Color(0xFF52796F);
            }

            return InkWell(
              onTap: (isWrongSingle || _isAnswered || _isEvaluating)
                  ? null
                  : () => _onOptionSelected(option),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 90,
                height: 120,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Center(
                  child: Text(
                    isWrongSingle ? "$option ✕" : option, 
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        if (!_isAnswered && _qType == 1)
          AppButton.primary(
            text: "Submit Selection (${_selectedCards.length}/${_targetCards.length})",
            onPressed: _selectedCards.isNotEmpty ? _submitMultiAnswer : null,
          ),
      ],
    );
  }
}
