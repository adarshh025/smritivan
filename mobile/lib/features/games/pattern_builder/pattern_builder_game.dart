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
  bool _isEvaluating = false;
  final Set<String> _wrongOptionsChosen = {};
  String? _feedbackMessage;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _generatePattern();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).reset();
      ref.read(gameSessionProvider.notifier).startInteraction();
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
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
    if (_isAnswered || _isEvaluating || _wrongOptionsChosen.contains(option)) return;

    setState(() => _isEvaluating = true);

    bool isCorrect = (option == _correctAnswer);
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

      _completionTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          ref.read(audioServiceProvider).speakInstruction("Excellent. You completed the level.");
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
          
          const SizedBox(height: 40),
          
          // Options
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _options.map((option) {
              final isWrong = _wrongOptionsChosen.contains(option);
              final isTarget = _isAnswered && option == _correctAnswer;

              Color bgColor = Colors.white;
              Color borderColor = const Color(0xFFCAD2C5);
              Color textColor = const Color(0xFF2F3E46);

              if (isTarget) {
                bgColor = const Color(0xFF84A98C);
                borderColor = const Color(0xFF52796F);
                textColor = Colors.white;
              } else if (isWrong) {
                bgColor = Colors.grey.shade200;
                borderColor = Colors.grey.shade400;
                textColor = Colors.grey.shade600;
              }

              return InkWell(
                onTap: (isWrong || _isAnswered || _isEvaluating)
                    ? null
                    : () {
                        ref.read(hapticServiceProvider).selection();
                        _onOptionSelected(option);
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: borderColor, 
                      width: isTarget ? 3 : 1.5,
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Center(
                    child: Text(
                      isWrong ? "$option ✕" : option,
                      style: TextStyle(
                        fontSize: 36, 
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
