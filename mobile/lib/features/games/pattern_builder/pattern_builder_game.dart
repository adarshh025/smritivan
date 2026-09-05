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

class PatternBuilderGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  const PatternBuilderGame({Key? key, required this.currentDifficulty}) : super(key: key);

  @override
  ConsumerState<PatternBuilderGame> createState() => _PatternBuilderGameState();
}

class _PatternBuilderGameState extends ConsumerState<PatternBuilderGame> {
  late List<String> _pattern;
  late List<String> _options;
  late String _correctAnswer;
  
  bool _isAnswered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generatePattern();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).reset();
      ref.read(gameSessionProvider.notifier).startInteraction();
    });
  }

  void _generatePattern() {
    int level = widget.currentDifficulty.floor();
    final random = Random();
    
    _pattern = [];
    _options = [];

    if (level <= 1) {
      // Level 1: A B A B ?
      final pool = ['🔴', '🔵', '🟢', '🟡', '🟠', '🟣'];
      pool.shuffle();
      String a = pool[0];
      String b = pool[1];
      _pattern = [a, b, a, b];
      _correctAnswer = a;
      _options = [a, b, pool[2], pool[3]]..shuffle();
    } else if (level == 2) {
      // Level 2: A B C A B ?
      final pool = ['🍎', '🍌', '🍇', '🍉', '🍓'];
      pool.shuffle();
      String a = pool[0];
      String b = pool[1];
      String c = pool[2];
      _pattern = [a, b, c, a, b];
      _correctAnswer = c;
      _options = [a, b, c, pool[3]]..shuffle();
    } else if (level == 3) {
      // Level 3: Changing attributes (e.g. big/small, different colored same shapes)
      final pool = [
        ['🚗', '🚙'], ['🍎', '🍏'], ['📙', '📘'], ['❤️', '💙']
      ];
      pool.shuffle();
      final set1 = pool[0]; // e.g. red car, blue car
      final set2 = pool[1]; // e.g. red apple, green apple
      _pattern = [set1[0], set1[1], set2[0], set2[1], set1[0]];
      _correctAnswer = set1[1];
      _options = [set1[0], set1[1], set2[0], set2[1]]..shuffle();
    } else if (level == 4) {
      // Level 4: Simple numerical
      int start = random.nextInt(5) + 1;
      int step = random.nextInt(3) + 2; // 2, 3, or 4
      _pattern = [
        start.toString(),
        (start + step).toString(),
        (start + step*2).toString(),
        (start + step*3).toString()
      ];
      _correctAnswer = (start + step*4).toString();
      _options = [
        _correctAnswer,
        (start + step*5).toString(),
        (start + step*4 + 1).toString(),
        (start + step*3 + 1).toString()
      ]..shuffle();
    } else {
      // Level 5: Multi-rule (Palindrome/Mirror A B C B A)
      final pool = ['☀️', '🌙', '⭐', '☁️'];
      pool.shuffle();
      String a = pool[0];
      String b = pool[1];
      String c = pool[2];
      _pattern = [a, b, c, b];
      _correctAnswer = a;
      _options = [a, b, c, pool[3]]..shuffle();
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
          gameType: 'pattern_builder',
          ref: ref,
        ).then((results) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FriendlyResultView(
                  gameType: 'pattern_builder',
                  gameTitle: 'Pattern Builder',
                  gameIcon: '🧩',
                  gameColor: const Color(0xFF264653),
                  currentLevel: widget.currentDifficulty,
                  results: results,
                  gameBuilder: (lvl) => PatternBuilderGame(currentDifficulty: lvl),
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
      gameTitle: 'Pattern Builder (Level ${widget.currentDifficulty.toInt()})',
      initialDifficulty: widget.currentDifficulty,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "What comes next?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
                onPressed: () {
                  ref.read(audioServiceProvider).speakInstruction("Look at the pattern. What comes next?");
                },
                tooltip: "Listen to instructions",
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Pattern Display
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            borderColor: Colors.grey.withOpacity(0.2),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ..._pattern.map((item) => Text(item, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
                const Text("❓", style: TextStyle(fontSize: 40)),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Options
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _options.map((option) => InkWell(
              onTap: () {
                ref.read(hapticServiceProvider).selection();
                _onOptionSelected(option);
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isAnswered 
                      ? (option == _correctAnswer ? const Color(0xFF84A98C) : Colors.grey[300])
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isAnswered && option == _correctAnswer ? const Color(0xFF84A98C) : const Color(0xFFCAD2C5), 
                    width: 3
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Center(
                  child: Text(option, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
