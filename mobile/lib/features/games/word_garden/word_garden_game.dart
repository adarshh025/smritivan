// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptic/haptic_service.dart';
import '../../../shared/widgets/app_card.dart';

import '../presentation/friendly_result_view.dart';

class WordGardenGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  const WordGardenGame({Key? key, required this.currentDifficulty}) : super(key: key);

  @override
  ConsumerState<WordGardenGame> createState() => _WordGardenGameState();
}

class _WordItem {
  final String emoji;
  final String word;
  final String category;
  final String association;

  _WordItem(this.emoji, this.word, this.category, this.association);
}

class _WordGardenGameState extends ConsumerState<WordGardenGame> {
  late String _questionPrompt;
  late Widget _promptWidget;
  late List<String> _options;
  late String _correctAnswer;
  
  bool _isAnswered = false;
  bool _isCorrect = false;

  final List<_WordItem> _contentPool = [
    _WordItem('🍎', 'APPLE', 'FRUIT', 'ORCHARD'),
    _WordItem('🍌', 'BANANA', 'FRUIT', 'MONKEY'),
    _WordItem('🚗', 'CAR', 'VEHICLE', 'ROAD'),
    _WordItem('🐶', 'DOG', 'ANIMAL', 'BONE'),
    _WordItem('☕', 'TEA', 'DRINK', 'CUP'),
    _WordItem('🏠', 'HOUSE', 'BUILDING', 'DOOR'),
    _WordItem('🌳', 'TREE', 'NATURE', 'LEAF'),
    _WordItem('☀️', 'SUN', 'NATURE', 'SKY'),
    _WordItem('📖', 'BOOK', 'OBJECT', 'READ'),
    _WordItem('👟', 'SHOE', 'CLOTHING', 'FOOT'),
    _WordItem('☂️', 'UMBRELLA', 'OBJECT', 'RAIN'),
    _WordItem('🎸', 'GUITAR', 'INSTRUMENT', 'MUSIC'),
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).reset();
      ref.read(gameSessionProvider.notifier).startInteraction();
    });
  }

  void _generateQuestion() {
    int level = widget.currentDifficulty.floor();
    final random = Random();
    _contentPool.shuffle();
    final target = _contentPool.first;
    
    _options = [];

    if (level <= 1) {
      // Level 1: Image -> Identify object (Very Easy, basically a matching game but with words)
      // We will show an image, and give 2 options.
      _questionPrompt = "What is this?";
      _promptWidget = Text(target.emoji, style: const TextStyle(fontSize: 80));
      _correctAnswer = target.word;
      _options.add(target.word);
      _options.add(_contentPool[1].word);
      _options.shuffle();
    } else if (level == 2) {
      // Level 2: Image -> Choose from 4
      _questionPrompt = "What is this?";
      _promptWidget = Text(target.emoji, style: const TextStyle(fontSize: 80));
      _correctAnswer = target.word;
      _options.add(target.word);
      _options.add(_contentPool[1].word);
      _options.add(_contentPool[2].word);
      _options.add(_contentPool[3].word);
      _options.shuffle();
    } else if (level == 3) {
      // Level 3: Complete simple words
      _questionPrompt = "Complete the word for:\n${target.emoji}";
      String word = target.word;
      int hideIdx = random.nextInt(word.length);
      String hiddenWord = word.substring(0, hideIdx) + "_" + word.substring(hideIdx + 1);
      
      _promptWidget = Text(hiddenWord, style: const TextStyle(fontSize: 48, letterSpacing: 8, fontWeight: FontWeight.bold));
      _correctAnswer = word[hideIdx];
      
      String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      _options.add(_correctAnswer);
      while(_options.length < 4) {
        String randChar = alphabet[random.nextInt(alphabet.length)];
        if (!_options.contains(randChar)) _options.add(randChar);
      }
      _options.shuffle();
    } else if (level == 4) {
      // Level 4: Category association
      _questionPrompt = "Which word belongs with these?";
      
      final categoryItems = _contentPool.where((c) => c.category == target.category).toList();
      if (categoryItems.length >= 2) {
        // e.g. APPLE, BANANA -> ?
        _promptWidget = Column(
          children: [
            Text(categoryItems[0].word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(categoryItems[1].word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ]
        );
        _correctAnswer = target.category;
        _options.add(target.category);
        _options.add(_contentPool.firstWhere((c) => c.category != target.category).category);
        _options.add("FOOD");
        _options.add("TOOL");
      } else {
        // Fallback
        _promptWidget = Text(target.word, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold));
        _correctAnswer = target.category;
        _options.add(target.category);
        _options.add(_contentPool[1].category);
        _options.add("NATURE");
        _options.add("VEHICLE");
      }
      _options.shuffle();
    } else {
      // Level 5: Word association (TEA -> CUP)
      _questionPrompt = "Which word is most related?";
      _promptWidget = Text(target.word, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 4));
      _correctAnswer = target.association;
      _options.add(target.association);
      _options.add(_contentPool[1].word);
      _options.add(_contentPool[2].word);
      _options.add(_contentPool[3].word);
      _options.shuffle();
    }
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (isCorrect) {
          ref.read(audioServiceProvider).speakInstruction("Excellent. You completed the level.");
        }
        ref.read(gameSessionProvider.notifier).finalizeAndSaveSession(
          currentDifficulty: widget.currentDifficulty,
          gameType: 'word_garden',
          ref: ref,
        ).then((results) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FriendlyResultView(
                  gameType: 'word_garden',
                  gameTitle: 'Word Garden',
                  gameIcon: '🌸',
                  gameColor: const Color(0xFF2A9D8F),
                  currentLevel: widget.currentDifficulty,
                  results: results,
                  gameBuilder: (lvl) => WordGardenGame(currentDifficulty: lvl),
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
      gameTitle: 'Word Garden (Level ${widget.currentDifficulty.toInt()})',
      initialDifficulty: widget.currentDifficulty,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _questionPrompt,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
                  textAlign: TextAlign.center,
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
          const SizedBox(height: 30),
          
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
            borderColor: const Color(0xFF52796F),
            child: _promptWidget,
          ),
          
          const SizedBox(height: 50),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _options.map((option) => InkWell(
              onTap: () {
                ref.read(hapticServiceProvider).selection();
                _onOptionSelected(option);
              },
              child: SizedBox(
                width: 150,
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
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: _isAnswered && option == _correctAnswer ? Colors.white : const Color(0xFF2F3E46),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
