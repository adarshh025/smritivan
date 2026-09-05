// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/patient_progress_chart.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../games/data/game_session_repository.dart';
import '../../games/domain/game_session_model.dart';
import '../../games/presentation/game_telemetry_provider.dart';
import '../../home/application/elder_home_provider.dart';

class PatientAnalyticsView extends ConsumerStatefulWidget {
  const PatientAnalyticsView({Key? key}) : super(key: key);

  @override
  ConsumerState<PatientAnalyticsView> createState() => _PatientAnalyticsViewState();
}

class _PatientAnalyticsViewState extends ConsumerState<PatientAnalyticsView> {
  String _timeFilter = '30d';
  List<GameSessionModel> _sessions = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    ref.listenManual(activeUserProvider, (previous, next) {
      if (next.value != null && previous?.value?.id != next.value?.id) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(activeUserProvider).value;
      final userId = user?.id ?? 'patient_ner_001';
      final sessionRepo = ref.read(gameSessionRepositoryProvider);

      final history = await sessionRepo.getSessionHistory(userId, limit: 100);
      final stats = await sessionRepo.getAggregateStats(userId);

      if (mounted) {
        setState(() {
          _sessions = history;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatGameTitle(String gameType) {
    if (gameType.isEmpty) return 'Cognitive Activity';
    return gameType
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatDateTime(String timestamp) {
    final dt = DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "${dt.day} ${months[dt.month - 1]}, $hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(activeUserProvider).value;
    final totalSessions = (_stats['total_sessions'] as int?) ?? _sessions.length;
    final avgCvs = (_stats['avg_cvs'] as num?)?.toDouble() ?? (_sessions.isNotEmpty ? (_sessions.map((s) => s.cvsScore).reduce((a, b) => a + b) / _sessions.length) : 0.0);
    final avgLatency = (_stats['avg_latency'] as num?)?.toInt() ?? (_sessions.isNotEmpty ? (_sessions.map((s) => s.reactionTimeMs).reduce((a, b) => a + b) ~/ _sessions.length) : 0);
    final maxDifficulty = (_stats['max_difficulty'] as num?)?.toInt() ?? (_sessions.isNotEmpty ? _sessions.map((s) => s.difficultyLevel.toInt()).reduce((a, b) => a > b ? a : b) : 1);

    return Scaffold(
      backgroundColor: AppColors.warmSand,
      appBar: AppBar(
        title: const Text(
          "Activity & Game Progress",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.deepSageGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Progress",
            onPressed: () async {
              await _loadData();
              ref.read(elderHomeProvider.notifier).loadData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSageGreen))
            : RefreshIndicator(
                color: AppColors.deepSageGreen,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softSageGreen.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('📊', style: TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? "Bhaben Bora",
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.textCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Real progress recorded from your cognitive games",
                                  style: AppTypography.metricLabel.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 1. Primary Line Graph
                      PatientProgressChart(
                        sessions: _sessions,
                        activeTimeFilter: _timeFilter,
                        onFilterChanged: (newFilter) {
                          setState(() => _timeFilter = newFilter);
                        },
                      ),
                      const SizedBox(height: 24),

                      // 2. Secondary Real Metric Summary Cards
                      Text(
                        "Activity Overview",
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                          return GridView.count(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.6,
                            children: [
                              _buildMetricCard("Activities Done", "$totalSessions", Icons.task_alt, AppColors.deepSageGreen),
                              _buildMetricCard("Avg Engagement", totalSessions > 0 ? "${avgCvs.round()}/100" : "--", Icons.psychology, const Color(0xFFE9C46A)),
                              _buildMetricCard("Highest Level", totalSessions > 0 ? "Level $maxDifficulty" : "Level 1", Icons.military_tech_outlined, const Color(0xFF2A9D8F)),
                              _buildMetricCard("Avg Speed", totalSessions > 0 ? "$avgLatency ms" : "--", Icons.timer_outlined, const Color(0xFFE76F51)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // 3. Game Progression Section
                      Text(
                        "Level Progression",
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildProgressionList(_sessions),
                      const SizedBox(height: 28),

                      // 4. Chronological Game History
                      Text(
                        "Recent Game Sessions",
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_sessions.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.white,
                          borderColor: AppColors.paleParchment,
                          child: const Center(
                            child: Text(
                              "No game history recorded yet. Play a game to see your activity logs here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ..._sessions.take(15).map((s) => _buildSessionLogTile(s)).toList(),

                      const SizedBox(height: 28),

                      // 5. Healthcare Transparency Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.paleParchment),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 20, color: AppColors.deepSageGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Healthcare Notice: Progress trends reflect cognitive game participation, accuracy, and reaction speed. These metrics are designed for engagement tracking and do not constitute clinical medical diagnosis.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: Colors.white,
      borderColor: AppColors.paleParchment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionList(List<GameSessionModel> sessions) {
    final gameTypes = [
      {'type': 'memory_match', 'title': 'Memory Match', 'icon': '🧠'},
      {'type': 'picture_recall', 'title': 'Picture Recall', 'icon': '🖼️'},
      {'type': 'pattern_builder', 'title': 'Pattern Builder', 'icon': '🧩'},
      {'type': 'word_garden', 'title': 'Word Garden', 'icon': '🌸'},
      {'type': 'card_recall', 'title': 'Card Recall', 'icon': '🎴'},
      {'type': 'daily_helper', 'title': 'Daily Helper', 'icon': '🏡'},
    ];

    return Column(
      children: gameTypes.map((g) {
        final gType = g['type']!;
        final matching = sessions.where((s) => s.gameType == gType).toList();
        int maxLvl = 1;
        if (matching.isNotEmpty) {
          for (final s in matching) {
            if (s.difficultyLevel.toInt() > maxLvl) maxLvl = s.difficultyLevel.toInt();
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.paleParchment),
          ),
          child: Row(
            children: [
              Text(g['icon']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textCharcoal),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      matching.isEmpty
                          ? "Level 1 (Ready to play)"
                          : "Highest Reached: Level $maxLvl (${matching.length} sessions)",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final lvl = index + 1;
                  final isUnlocked = lvl <= (matching.isEmpty ? 1 : (maxLvl + 1).clamp(1, 3));
                  final isCompleted = lvl <= (matching.isEmpty ? 0 : maxLvl);

                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.deepSageGreen
                          : (isUnlocked ? AppColors.softSageGreen.withOpacity(0.3) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCompleted ? "L$lvl ✓" : (isUnlocked ? "L$lvl" : "🔒"),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.white : (isUnlocked ? AppColors.deepSageGreen : Colors.grey),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionLogTile(GameSessionModel session) {
    final title = _formatGameTitle(session.gameType);
    final dateStr = _formatDateTime(session.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.paleParchment),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.softSageGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_esports_outlined, color: AppColors.deepSageGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title • Level ${session.difficultyLevel.toInt()}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textCharcoal),
                ),
                const SizedBox(height: 2),
                Text(
                  "$dateStr • Latency: ${session.reactionTimeMs}ms",
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.deepSageGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${session.cvsScore.round()}/100",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.deepSageGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
