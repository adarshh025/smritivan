// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../shared/widgets/app_card.dart';

class TeaRoutineGame extends ConsumerStatefulWidget {
  final double currentDifficulty;

  const TeaRoutineGame({
    Key? key,
    required this.currentDifficulty,
  }) : super(key: key);

  @override
  ConsumerState<TeaRoutineGame> createState() => _TeaRoutineGameState();
}

class _TeaRoutineGameState extends ConsumerState<TeaRoutineGame> {
  final List<String> _correctSequence = [
    'Boil Water',
    'Add Assam Leaves',
    'Pour Milk',
    'Serve Tea'
  ];

  late List<String> _shuffledSteps;
  List<String> _userSequence = [];
  
  bool _showFeedback = false;
  bool _lastAttemptSuccessful = false;

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    setState(() {
      _showFeedback = false;
      _userSequence = [];
      _shuffledSteps = List.from(_correctSequence)..shuffle();
    });
    
    // Start timing immediately for sequencing tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).startInteraction();
    });
  }

  void _onStepSelected(String step) {
    if (_showFeedback) return;

    setState(() {
      if (_userSequence.contains(step)) {
        _userSequence.remove(step);
      } else {
        _userSequence.add(step);
      }
    });

    // Check if they selected all steps
    if (_userSequence.length == _correctSequence.length) {
      _evaluateSequence();
    }
  }

  void _evaluateSequence() {
    bool isCorrect = true;
    for (int i = 0; i < _correctSequence.length; i++) {
      if (_userSequence[i] != _correctSequence[i]) {
        isCorrect = false;
        break;
      }
    }

    ref.read(gameSessionProvider.notifier).recordAttempt(
      success: isCorrect,
      errorsInAttempt: isCorrect ? 0 : 1,
    );

    setState(() {
      _lastAttemptSuccessful = isCorrect;
      _showFeedback = true;
    });

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _setupRound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CognitiveGameEngine(
      gameTitle: 'Assam Tea Routine',
      initialDifficulty: widget.currentDifficulty,
      child: Center(
        child: _showFeedback 
            ? _buildFeedback()
            : _buildSequencingPhase(),
      ),
    );
  }

  Widget _buildSequencingPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Make Assam Tea in order",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Tap the steps in the correct sequence",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        ..._shuffledSteps.map((step) => _buildStepCard(step)).toList(),
      ],
    );
  }

  Widget _buildStepCard(String step) {
    int index = _userSequence.indexOf(step);
    bool isSelected = index != -1;

    return GestureDetector(
      onTap: () => _onStepSelected(step),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: isSelected ? const Color(0xFF52796F) : Colors.white,
        borderColor: const Color(0xFF52796F),
        child: Row(
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF52796F)),
                ),
              ),
            Text(
              step,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF52796F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _lastAttemptSuccessful ? Icons.check_circle : Icons.refresh,
          size: 100,
          color: _lastAttemptSuccessful ? const Color(0xFF84A98C) : Colors.orange,
        ),
        const SizedBox(height: 20),
        Text(
          _lastAttemptSuccessful ? "Perfect sequence!" : "Let's try that again",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}

