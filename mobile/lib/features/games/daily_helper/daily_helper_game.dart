// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptic/haptic_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

import '../presentation/friendly_result_view.dart';

class DailyHelperGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  const DailyHelperGame({Key? key, required this.currentDifficulty}) : super(key: key);

  @override
  ConsumerState<DailyHelperGame> createState() => _DailyHelperGameState();
}

class _Scenario {
  final String title;
  final List<String> steps;
  final List<String> distractors;

  _Scenario(this.title, this.steps, this.distractors);
}

class _DailyHelperGameState extends ConsumerState<DailyHelperGame> {
  late String _scenarioTitle;
  late List<String> _correctSequence;
  late List<String> _shuffledSteps;
  List<String> _selectedSequence = [];
  
  bool _isAnswered = false;
  bool _isCorrect = false;

  final List<_Scenario> _scenarios = [
    // 3 steps
    _Scenario("Wash your hands", ["Turn on water", "Use soap", "Rinse hands"], ["Comb hair", "Drink water"]),
    _Scenario("Brush your teeth", ["Put paste on brush", "Brush teeth", "Rinse mouth"], ["Wash face", "Put on shoes"]),
    
    // 4 steps
    _Scenario("Make a cup of tea", ["Boil water", "Add tea leaves", "Add milk & sugar", "Pour in cup"], ["Fry an egg", "Eat an apple"]),
    _Scenario("Make a sandwich", ["Take bread", "Spread butter", "Add filling", "Close sandwich"], ["Boil rice", "Drink milk"]),
    
    // 5 steps
    _Scenario("Get ready for a walk", ["Wear socks", "Wear shoes", "Take keys", "Lock door", "Start walking"], ["Turn on TV", "Cook dinner"]),
    _Scenario("Water the plants", ["Get watering can", "Fill with water", "Walk to garden", "Water plants", "Return can"], ["Cut grass", "Paint fence"]),
    
    // 6-8 steps (Complex)
    _Scenario("Prepare to go shopping", ["Check pantry", "Make a shopping list", "Take wallet", "Take reusable bag", "Check the list", "Go to store"], ["Turn on oven", "Feed the dog", "Take an umbrella"]),
    _Scenario("Do the laundry", ["Gather dirty clothes", "Sort colors", "Put in machine", "Add detergent", "Start machine", "Hang to dry"], ["Wash dishes", "Sweep floor", "Iron clothes"]),
  ];

  @override
  void initState() {
    super.initState();
    _setupRound();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).reset();
      ref.read(gameSessionProvider.notifier).startInteraction();
    });
  }

  void _setupRound() {
    int level = widget.currentDifficulty.floor();
    final random = Random();
    
    // Filter scenarios by required length
    int targetLength = 3;
    if (level == 2) targetLength = 4;
    else if (level == 3) targetLength = 5;
    else if (level >= 4) targetLength = 6; // Includes 6+

    List<_Scenario> possible = _scenarios.where((s) => s.steps.length == targetLength).toList();
    if (possible.isEmpty) {
      possible = _scenarios; // fallback
    }
    
    possible.shuffle();
    final scenario = possible.first;

    _scenarioTitle = scenario.title;
    _correctSequence = scenario.steps;
    
    _shuffledSteps = List.from(_correctSequence);

    // Add distractors for levels 4 and 5
    if (level >= 4) {
      List<String> dists = List.from(scenario.distractors)..shuffle();
      int numDistractors = level == 5 ? 3 : 1;
      _shuffledSteps.addAll(dists.take(numDistractors));
    }
    
    _shuffledSteps.shuffle();
  }

  void _onStepSelected(String step) {
    if (_isAnswered || _selectedSequence.contains(step)) return;

    ref.read(hapticServiceProvider).selection();

    setState(() {
      _selectedSequence.add(step);
    });

    if (_selectedSequence.length == _correctSequence.length) {
      _validateSequence();
    }
  }

  void _onStepRemoved(String step) {
    if (_isAnswered) return;
    ref.read(hapticServiceProvider).selection();
    setState(() {
      _selectedSequence.remove(step);
    });
  }

  void _validateSequence() {
    bool isCorrect = true;
    for (int i = 0; i < _correctSequence.length; i++) {
      if (_selectedSequence[i] != _correctSequence[i]) {
        isCorrect = false;
        break;
      }
    }

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

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ref.read(audioServiceProvider).speakInstruction("Excellent. You completed the level.");
          ref.read(gameSessionProvider.notifier).finalizeAndSaveSession(
            currentDifficulty: widget.currentDifficulty,
            gameType: 'daily_helper',
            ref: ref,
          ).then((results) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendlyResultView(
                    gameType: 'daily_helper',
                    gameTitle: 'Daily Helper',
                    gameIcon: '📅',
                    gameColor: const Color(0xFF457B9D),
                    currentLevel: widget.currentDifficulty,
                    results: results,
                    gameBuilder: (lvl) => DailyHelperGame(currentDifficulty: lvl),
                  ),
                ),
              );
            }
          });
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedSequence.clear();
      _isAnswered = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CognitiveGameEngine(
      gameTitle: 'Daily Helper (Level ${widget.currentDifficulty.toInt()})',
      initialDifficulty: widget.currentDifficulty,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Activity: $_scenarioTitle",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
                onPressed: () {
                  ref.read(audioServiceProvider).speakInstruction("Tap the steps in the correct order for $_scenarioTitle.");
                },
                tooltip: "Listen to instructions",
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the steps in the correct order.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Selection Area
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF84A98C), width: 2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSequence.asMap().entries.map((entry) {
                return InkWell(
                  onTap: () => _onStepRemoved(entry.value),
                  child: Chip(
                    label: Text("${entry.key + 1}. ${entry.value}", style: const TextStyle(fontSize: 16)),
                    backgroundColor: const Color(0xFFCAD2C5),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: _isAnswered ? null : () => _onStepRemoved(entry.value),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Options Area
          if (!_isAnswered)
            Expanded(
              child: ListView(
                children: _shuffledSteps.map((step) {
                  bool isSelected = _selectedSequence.contains(step);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: isSelected ? null : () => _onStepSelected(step),
                      child: AppCard(
                        padding: const EdgeInsets.all(20),
                        backgroundColor: isSelected ? Colors.grey[200] : Colors.white,
                        borderColor: const Color(0xFFCAD2C5),
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected ? Colors.grey : const Color(0xFF2F3E46),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          if (_isAnswered) ...[
            const SizedBox(height: 20),
            Icon(
              _isCorrect ? Icons.check_circle : Icons.error,
              size: 64,
              color: _isCorrect ? const Color(0xFF84A98C) : Colors.orange,
            ),
            const SizedBox(height: 16),
            if (!_isCorrect)
              AppButton.secondary(
                text: "Try Again",
                onPressed: _reset,
              ),
          ]
        ],
      ),
    );
  }
}
