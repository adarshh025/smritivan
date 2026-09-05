// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../shared/widgets/app_card.dart';

class SoundsOfNeGame extends ConsumerStatefulWidget {
  final double currentDifficulty;

  const SoundsOfNeGame({
    Key? key,
    required this.currentDifficulty,
  }) : super(key: key);

  @override
  ConsumerState<SoundsOfNeGame> createState() => _SoundsOfNeGameState();
}

class _SoundsOfNeGameState extends ConsumerState<SoundsOfNeGame> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final Map<String, String> _soundMap = {
    'Brahmaputra River Flow': 'audio/brahmaputra_river.wav',
    'Hornbill Call': 'audio/hornbill_call.wav',
    'Bihu Dhol Beat': 'audio/bihu_dhol.wav',
  };
  
  late List<String> _allSounds;

  late String _targetSound;
  late List<String> _choices;
  
  bool _isPlaying = true;
  bool _showFeedback = false;
  bool _lastAttemptSuccessful = false;

  @override
  void initState() {
    super.initState();
    _allSounds = _soundMap.keys.toList();
    _setupRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupRound() {
    setState(() {
      _isPlaying = true;
      _showFeedback = false;
    });

    final random = Random();
    
    // Choose target
    _targetSound = _allSounds[random.nextInt(_allSounds.length)];
    
    // Determine number of choices based on difficulty (min 2, max 6)
    int numChoices = (2 + (widget.currentDifficulty * 0.4)).floor().clamp(2, 6);
    
    // Generate choices
    _choices = [_targetSound];
    while (_choices.length < numChoices) {
      String randomSound = _allSounds[random.nextInt(_allSounds.length)];
      if (!_choices.contains(randomSound)) {
        _choices.add(randomSound);
      }
    }
    _choices.shuffle();

    // Determine listening time based on difficulty (e.g., 5s easy, 2s hard)
    int playMs = (5000 - (widget.currentDifficulty * 300)).floor().clamp(2000, 5000);

    // Play the audio!
    _audioPlayer.play(AssetSource(_soundMap[_targetSound]!));

    Timer(Duration(milliseconds: playMs), () {
      if (mounted) {
        _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
        // Start timing the reaction now
        ref.read(gameSessionProvider.notifier).startInteraction();
      }
    });
  }

  void _onChoiceSelected(String choice) {
    if (_isPlaying || _showFeedback) return;

    bool isCorrect = (choice == _targetSound);
    
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
      gameTitle: 'Sounds of NE',
      initialDifficulty: widget.currentDifficulty,
      child: Center(
        child: _showFeedback 
            ? _buildFeedback()
            : _isPlaying 
                ? _buildListeningPhase() 
                : _buildSelectionPhase(),
      ),
    );
  }

  Widget _buildListeningPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Listen carefully...",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Icon(Icons.volume_up, size: 100, color: const Color(0xFF52796F)),
        const SizedBox(height: 20),
        Text(
          "🎵 Playing: $_targetSound",
          style: const TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSelectionPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "What did you hear?",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _choices.map((choice) => GestureDetector(
            onTap: () => _onChoiceSelected(choice),
            child: _buildChoiceCard(choice),
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

  Widget _buildChoiceCard(String text) {
    return SizedBox(
      width: 140,
      height: 100,
      child: AppCard(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            text, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF52796F), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

