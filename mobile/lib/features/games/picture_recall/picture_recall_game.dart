// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptic/haptic_service.dart';
import '../../../shared/widgets/app_card.dart';

import '../presentation/friendly_result_view.dart';

class PictureRecallGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  const PictureRecallGame({Key? key, required this.currentDifficulty}) : super(key: key);

  @override
  ConsumerState<PictureRecallGame> createState() => _PictureRecallGameState();
}

class _PictureRecallItem {
  final String emoji;
  final String name;
  final String color;
  final String category;

  _PictureRecallItem(this.emoji, this.name, this.color, this.category);
}

class _PictureRecallGameState extends ConsumerState<PictureRecallGame> {
  bool _isObserving = true;
  bool _isAnswered = false;
  bool _isCorrect = false;
  Timer? _observeTimer;
  Timer? _resultTimer;

  late int _observationMs;
  late List<_PictureRecallItem> _sceneItems;
  late String _question;
  late List<String> _options;
  late String _correctAnswer;

  final List<_PictureRecallItem> _contentPool = [
    _PictureRecallItem('🍎', 'Apple', 'Red', 'Fruit'),
    _PictureRecallItem('🚗', 'Car', 'Red', 'Vehicle'),
    _PictureRecallItem('🐶', 'Dog', 'Brown', 'Animal'),
    _PictureRecallItem('🌻', 'Flower', 'Yellow', 'Nature'),
    _PictureRecallItem('☂️', 'Umbrella', 'Purple', 'Object'),
    _PictureRecallItem('🎸', 'Guitar', 'Brown', 'Instrument'),
    _PictureRecallItem('⚽', 'Ball', 'White', 'Sport'),
    _PictureRecallItem('⏰', 'Clock', 'Red', 'Object'),
    _PictureRecallItem('🔑', 'Key', 'Gold', 'Object'),
    _PictureRecallItem('✈️', 'Plane', 'White', 'Vehicle'),
    _PictureRecallItem('🦋', 'Butterfly', 'Blue', 'Animal'),
    _PictureRecallItem('🐢', 'Turtle', 'Green', 'Animal'),
    _PictureRecallItem('🍉', 'Watermelon', 'Green', 'Fruit'),
    _PictureRecallItem('🚌', 'Bus', 'Yellow', 'Vehicle'),
    _PictureRecallItem('📚', 'Books', 'Blue', 'Object'),
  ];

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
    _resultTimer?.cancel();
    super.dispose();
  }

  void _setupRound() {
    int level = widget.currentDifficulty.floor();
    int itemCount;
    
    if (level <= 1) {
      itemCount = 3;
      _observationMs = 10000;
    } else if (level == 2) {
      itemCount = 5;
      _observationMs = 8000;
    } else if (level == 3) {
      itemCount = 7;
      _observationMs = 7000;
    } else if (level == 4) {
      itemCount = 9;
      _observationMs = 5000;
    } else {
      itemCount = 12;
      _observationMs = 4000;
    }

    _contentPool.shuffle();
    _sceneItems = _contentPool.take(itemCount).toList();

    _generateQuestion(level);

    _observeTimer = Timer(Duration(milliseconds: _observationMs), () {
      if (mounted) {
        setState(() {
          _isObserving = false;
        });
        ref.read(gameSessionProvider.notifier).startInteraction();
      }
    });
  }

  void _generateQuestion(int level) {
    final random = Random();
    final targetItem = _sceneItems[random.nextInt(_sceneItems.length)];
    
    int qType = 1;
    if (level == 2) qType = random.nextInt(2) + 1; // 1 or 2
    if (level >= 3) qType = random.nextInt(3) + 1; // 1, 2, or 3

    _options = [];

    switch (qType) {
      case 1: // Identity
        _question = "Which of these did you see?";
        _correctAnswer = targetItem.name;
        _options.add(_correctAnswer);
        final distractors = _contentPool.where((i) => !_sceneItems.contains(i)).toList()..shuffle();
        for (int i=0; i<3; i++) {
          if (i < distractors.length) _options.add(distractors[i].name);
        }
        break;
      case 2: // Color
        _question = "What color was the ${targetItem.name}?";
        _correctAnswer = targetItem.color;
        _options.addAll([_correctAnswer, 'Blue', 'Green', 'Yellow', 'Red', 'Purple', 'Brown'].toSet().toList());
        _options = _options.take(4).toList(); // keep 4 options
        break;
      case 3: // Category/Quantity
        int count = _sceneItems.where((i) => i.category == targetItem.category).length;
        _question = "How many ${targetItem.category}s were there?";
        _correctAnswer = count.toString();
        _options = [count.toString(), (count+1).toString(), (count > 0 ? count-1 : count+2).toString(), (count+3).toString()];
        break;
    }
    
    _options.shuffle();
  }

  void _onOptionSelected(String option) {
    if (_isAnswered) return;

    bool isCorrect = (option == _correctAnswer);
    ref.read(gameSessionProvider.notifier).recordAttempt(
      success: isCorrect,
      errorsInAttempt: isCorrect ? 0 : 1,
    );

    if (isCorrect) {
      ref.read(hapticServiceProvider).success();
      ref.read(audioServiceProvider).playGentleSuccessChime();
    } else {
      ref.read(hapticServiceProvider).error();
      ref.read(audioServiceProvider).playErrorChime();
    }

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    _resultTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        if (isCorrect) {
          ref.read(audioServiceProvider).speakInstruction("Excellent. You completed the level.");
        }
        ref.read(gameSessionProvider.notifier).finalizeAndSaveSession(
          currentDifficulty: widget.currentDifficulty,
          gameType: 'picture_recall',
          ref: ref,
        ).then((results) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FriendlyResultView(
                  gameType: 'picture_recall',
                  gameTitle: 'Picture Recall',
                  gameIcon: '🖼️',
                  gameColor: const Color(0xFFE76F51),
                  currentLevel: widget.currentDifficulty,
                  results: results,
                  gameBuilder: (lvl) => PictureRecallGame(currentDifficulty: lvl),
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
      gameTitle: 'Picture Recall (Level ${widget.currentDifficulty.toInt()})',
      initialDifficulty: widget.currentDifficulty,
      child: Center(
        child: _isObserving
            ? _buildObservationPhase()
            : _buildQuestionPhase(),
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
            const Text(
              "Look carefully...",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
              onPressed: () {
                ref.read(audioServiceProvider).speakInstruction("Look carefully at these objects. Memorize objects, colors, and quantities.");
              },
              tooltip: "Listen to instructions",
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Memorize objects, colors, and quantities",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 350,
          child: AppCard(
            padding: const EdgeInsets.all(24),
            borderColor: Colors.grey.withOpacity(0.2),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _sceneItems.map((item) => Text(item.emoji, style: const TextStyle(fontSize: 64))).toList(),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4A261))),
      ],
    );
  }

  Widget _buildQuestionPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _question,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
              onPressed: () {
                ref.read(audioServiceProvider).speakInstruction(_question);
              },
              tooltip: "Listen to question",
            ),
          ],
        ),
        const SizedBox(height: 40),
        ..._options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              ref.read(hapticServiceProvider).selection();
              _onOptionSelected(option);
            },
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: _isAnswered 
                  ? (option == _correctAnswer ? const Color(0xFF84A98C) : Colors.grey[300])
                  : Colors.white,
              borderColor: _isAnswered && option == _correctAnswer ? const Color(0xFF84A98C) : const Color(0xFFCAD2C5), 
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: _isAnswered && option == _correctAnswer ? Colors.white : const Color(0xFF2F3E46),
                  ),
                ),
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
}
