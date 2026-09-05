// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cognitive_game_engine.dart';
import '../core/game_session_tracker.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptic/haptic_service.dart';

import '../presentation/friendly_result_view.dart';

class MemoryMatchGame extends ConsumerStatefulWidget {
  final double currentDifficulty;
  const MemoryMatchGame({Key? key, required this.currentDifficulty}) : super(key: key);

  @override
  ConsumerState<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends ConsumerState<MemoryMatchGame> {
  // Massive content pool for variety
  final List<String> _contentPool = [
    // Local Assets
    'assets/images/objects/mango.jpg',
    'assets/images/objects/tiger.jpg',
    'assets/images/objects/auto.jpg',
    'assets/images/objects/lotus.jpg',
    'assets/images/objects/village.jpg',
    'assets/images/objects/chai.jpg',
    'assets/images/objects/hornbill.jpg',
    'assets/images/objects/elephant.jpg',
    // Emojis (Objects & Animals)
    '🍎', '🚗', '🐶', '🌻', '☂️', '🎸', '⚽', '⏰', '🔑', '✈️',
    '🚲', '🦋', '🐟', '🐢', '🍉', '🍕', '🍔', '🎁', '🎈', '📚',
    '✏️', '✂️', '🧸', '🥁', '🚀', '⛵', '🏠', '🌳', '🌙', '⭐'
  ];
  
  late List<String> _cards;
  late List<bool> _isFlipped;
  late List<bool> _isMatched;
  
  int _firstSelected = -1;
  bool _isProcessing = true; 
  int _pairsFound = 0;
  late int _totalPairs;
  Timer? _previewTimer;
  Timer? _flipBackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).reset();
    });
    _setupGame();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _flipBackTimer?.cancel();
    super.dispose();
  }

  void _setupGame() {
    // Level Logic
    int level = widget.currentDifficulty.floor();
    int previewMs;

    if (level <= 1) {
      _totalPairs = 3;
      previewMs = 8000;
    } else if (level == 2) {
      _totalPairs = 4;
      previewMs = 7000;
    } else if (level == 3) {
      _totalPairs = 6;
      previewMs = 5000;
    } else if (level == 4) {
      _totalPairs = 8;
      previewMs = 4000;
    } else {
      _totalPairs = 10;
      previewMs = 3000;
    }
    
    // Select subset for this session
    _contentPool.shuffle();
    final selectedContent = _contentPool.take(_totalPairs).toList();
    
    // Create pairs and shuffle
    _cards = [...selectedContent, ...selectedContent];
    _cards.shuffle();
    
    _isFlipped = List.filled(_cards.length, true); // Face up initially
    _isMatched = List.filled(_cards.length, false);
    
    // Preview phase
    _previewTimer = Timer(Duration(milliseconds: previewMs), () {
      if (mounted) {
        setState(() {
          _isFlipped = List.filled(_cards.length, false); // Flip face down
          _isProcessing = false;
        });
        ref.read(gameSessionProvider.notifier).startInteraction();
      }
    });
  }

  void _onCardTapped(int index) {
    if (_isProcessing || _isFlipped[index] || _isMatched[index]) return;

    ref.read(hapticServiceProvider).selection();

    setState(() {
      _isFlipped[index] = true;
    });

    if (_firstSelected == -1) {
      _firstSelected = index;
    } else {
      _isProcessing = true;
      int first = _firstSelected;
      int second = index;
      _firstSelected = -1;

      bool isMatch = _cards[first] == _cards[second];
      
      ref.read(gameSessionProvider.notifier).recordAttempt(
        success: isMatch,
        errorsInAttempt: isMatch ? 0 : 1,
      );

      if (isMatch) {
        ref.read(hapticServiceProvider).success();
        ref.read(audioServiceProvider).playGentleSuccessChime();

        setState(() {
          _isMatched[first] = true;
          _isMatched[second] = true;
          _pairsFound++;
          _isProcessing = false;
        });
        
        if (_pairsFound == _totalPairs) {
          // Trigger game end sequence
          ref.read(audioServiceProvider).speakInstruction("Excellent. You completed the level.");
          ref.read(gameSessionProvider.notifier).finalizeAndSaveSession(
            currentDifficulty: widget.currentDifficulty,
            gameType: 'memory_match',
            ref: ref,
          ).then((results) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendlyResultView(
                    gameType: 'memory_match',
                    gameTitle: 'Memory Match',
                    gameIcon: '🧠',
                    gameColor: const Color(0xFF2A9D8F),
                    currentLevel: widget.currentDifficulty,
                    results: results,
                    gameBuilder: (lvl) => MemoryMatchGame(currentDifficulty: lvl),
                  ),
                ),
              );
            }
          });
        }
      } else {
        ref.read(hapticServiceProvider).error();
        ref.read(audioServiceProvider).playErrorChime();
        _flipBackTimer = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _isFlipped[first] = false;
              _isFlipped[second] = false;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  Widget _buildCardContent(String content) {
    if (content.endsWith('.jpg') || content.endsWith('.png')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          content,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      // It's an emoji
      return Text(
        content,
        style: const TextStyle(fontSize: 48),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxis = 3;
    if (_totalPairs == 4) crossAxis = 4; // 2x4
    else if (_totalPairs == 6) crossAxis = 4; // 3x4
    else if (_totalPairs == 8) crossAxis = 4; // 4x4
    else if (_totalPairs == 10) crossAxis = 5; // 4x5

    return CognitiveGameEngine(
      gameTitle: 'Memory Match (Level ${widget.currentDifficulty.toInt()})',
      initialDifficulty: widget.currentDifficulty,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Match the pairs",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF264653)),
                onPressed: () {
                  ref.read(audioServiceProvider).speakInstruction("Match the two identical pictures.");
                },
                tooltip: "Listen to instructions",
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Pairs found: $_pairsFound / $_totalPairs",
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxis,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: _totalPairs > 8 ? 0.9 : 1.0,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _isFlipped[index] ? Colors.white : const Color(0xFFE9C46A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      border: Border.all(
                        color: _isMatched[index] ? const Color(0xFF84A98C) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: _isFlipped[index] 
                        ? _buildCardContent(_cards[index])
                        : const Text(
                            "?",
                            style: TextStyle(
                              fontSize: 32, 
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
