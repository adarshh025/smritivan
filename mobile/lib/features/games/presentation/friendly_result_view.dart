// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';

class FriendlyResultView extends StatelessWidget {
  final Map<String, dynamic> results;
  final String? gameType;
  final String? gameTitle;
  final String? gameIcon;
  final Color? gameColor;
  final double? currentLevel;
  final Widget Function(double level)? gameBuilder;

  const FriendlyResultView({
    Key? key,
    required this.results,
    this.gameType,
    this.gameTitle,
    this.gameIcon,
    this.gameColor,
    this.currentLevel,
    this.gameBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int accuracy = ((results['successRate'] ?? 0.0) * 100).round();
    final int duration = results['durationSeconds'] ?? 0;
    final int cvsScore = ((results['cvs'] ?? 80.0) as num).round();
    final double level = currentLevel ?? 1.0;
    final String title = gameTitle ?? "Cognitive Exercise";
    final Color primaryColor = gameColor ?? const Color(0xFF2A9D8F);
    final bool hasNextLevel = level < 5.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.stars_rounded, size: 84, color: Color(0xFFE9C46A)),
              const SizedBox(height: 12),
              const Text(
                "Wonderful! 🌟",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3E46),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$title • Level ${level.toInt()} Completed",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF52796F),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricTile(
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF2A9D8F),
                          label: "Accuracy",
                          value: "$accuracy%",
                        ),
                        Container(height: 40, width: 1, color: Colors.grey.shade300),
                        _buildMetricTile(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFFE76F51),
                          label: "Time",
                          value: "${duration}s",
                        ),
                        Container(height: 40, width: 1, color: Colors.grey.shade300),
                        _buildMetricTile(
                          icon: Icons.psychology_outlined,
                          iconColor: const Color(0xFF457B9D),
                          label: "Score",
                          value: "$cvsScore",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Unlock status banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: hasNextLevel ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasNextLevel ? const Color(0xFF81C784) : const Color(0xFFFFD54F),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasNextLevel ? Icons.lock_open_rounded : Icons.military_tech_rounded,
                      color: hasNextLevel ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        hasNextLevel
                            ? "Level ${(level + 1).toInt()} Unlocked!"
                            : "All 5 levels completed for $title!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasNextLevel ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              if (gameBuilder != null) ...[
                if (hasNextLevel)
                  ElevatedButton.icon(
                    key: const Key('btn_play_next_level'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => gameBuilder!(level + 1.0)),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                    label: Text(
                      "Play Next Level (Level ${(level + 1).toInt()})",
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    key: const Key('btn_play_again'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => gameBuilder!(level)),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, size: 24),
                    label: const Text(
                      "Play Again",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              OutlinedButton.icon(
                key: const Key('btn_choose_level_game'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.grid_view_rounded, size: 22),
                label: const Text("Choose Another Game", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF264653),
                  side: const BorderSide(color: Color(0xFF264653), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),

              TextButton.icon(
                key: const Key('btn_back_to_home'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded, size: 22),
                label: const Text("Back to Games", style: TextStyle(fontSize: 16)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }
}
