// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/cultural_assets.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';

class VisualMemoryGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  final String region;

  const VisualMemoryGame({
    Key? key,
    required this.currentDifficulty,
    this.region = 'assam',
  }) : super(key: key);

  @override
  ConsumerState<VisualMemoryGame> createState() => _VisualMemoryGameState();
}

class _VisualMemoryGameState extends ConsumerState<VisualMemoryGame> {
  late List<Map<String, String>> _regionalPatterns;
  late Map<String, String> _targetPattern;
  late List<Map<String, String>> _choices;
  
  bool _isObserving = true;
  bool _showFeedback = false;
  bool _lastAttemptSuccessful = false;

  @override
  void initState() {
    super.initState();
    _regionalPatterns = CulturalAssets.getPatternsForRegion(widget.region);
    _setupRound();
  }

  void _setupRound() {
    setState(() {
      _isObserving = true;
      _showFeedback = false;
    });

    final random = Random();
    
    // Choose target
    _targetPattern = _regionalPatterns[random.nextInt(_regionalPatterns.length)];
    
    // Determine number of choices based on difficulty (min 2, max 6)
    int numChoices = (2 + (widget.currentDifficulty * 0.4)).floor().clamp(2, 6);
    
    // Generate choices
    _choices = [_targetPattern];
    while (_choices.length < numChoices) {
      String randomPattern = _regionalPatterns[random.nextInt(_regionalPatterns.length)]['name']!;
      if (!_choices.any((c) => c['name'] == randomPattern)) {
        _choices.add(_regionalPatterns.firstWhere((p) => p['name'] == randomPattern));
      }
    }
    _choices.shuffle();

    // Determine observation time based on difficulty (e.g., 5s easy, 1s hard)
    int observeMs = (5000 - (widget.currentDifficulty * 400)).floor().clamp(1000, 5000);

    Timer(Duration(milliseconds: observeMs), () {
      if (mounted) {
        setState(() {
          _isObserving = false;
        });
        // Start timing the reaction now
        ref.read(gameSessionProvider.notifier).startInteraction();
      }
    });
  }

  void _onChoiceSelected(Map<String, String> choice) {
    if (_isObserving || _showFeedback) return;

    bool isCorrect = (choice['name'] == _targetPattern['name']);
    
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
      gameTitle: 'Visual Memory',
      initialDifficulty: widget.currentDifficulty,
      child: Center(
        child: _showFeedback 
            ? _buildFeedback()
            : _isObserving 
                ? _buildObservationPhase() 
                : _buildSelectionPhase(),
      ),
    );
  }

  Widget _buildObservationPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Remember this pattern",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        _buildPatternCard(_targetPattern),
      ],
    );
  }

  Widget _buildSelectionPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Which pattern did you see?",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _choices.map((choice) => GestureDetector(
            onTap: () => _onChoiceSelected(choice),
            child: _buildPatternCard(choice),
          )).toList(),
        ),
      ],
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
          _lastAttemptSuccessful ? "Well done!" : "Let's try again",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildPatternCard(Map<String, String> pattern) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        image: DecorationImage(
          image: AssetImage(pattern['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                pattern['name']!, 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

