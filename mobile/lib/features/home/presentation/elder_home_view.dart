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
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/game_card.dart';
import '../../../shared/widgets/reminder_card.dart';
import '../../../shared/widgets/state_widgets.dart';

import '../../games/presentation/level_selection_view.dart';
import '../../games/memory_match/memory_match_game.dart';
import '../../games/picture_recall/picture_recall_game.dart';
import '../../games/pattern_builder/pattern_builder_game.dart';
import '../../games/word_garden/word_garden_game.dart';
import '../../games/card_recall/card_recall_game.dart';
import '../../games/daily_helper/daily_helper_game.dart';
import '../../games/domain/game_session_model.dart';
import '../../games/core/game_progression_service.dart';

import '../../caregiver/presentation/caregiver_auth_view.dart';
import '../../reminders/presentation/reminders_view.dart';
import '../../about/presentation/about_view.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../application/elder_home_provider.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../reminders/application/reminder_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/patient_settings_view.dart';
import '../../analytics/presentation/patient_analytics_view.dart';

class ElderHomeView extends ConsumerStatefulWidget {
  const ElderHomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<ElderHomeView> createState() => _ElderHomeViewState();
}

class _ElderHomeViewState extends ConsumerState<ElderHomeView> {
  String? _selectedWellbeing;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(elderHomeProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getTimeGreeting(String name, int hour) {
    if (hour >= 5 && hour < 12) {
      return "Good Morning,\n$name 👋";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon,\n$name ☀️";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening,\n$name 🌄";
    } else {
      return "Restful Evening,\n$name 🌙";
    }
  }

  bool _isEveningTime(int hour) {
    return hour >= 17 || hour < 5;
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(elderHomeProvider);
    final userState = ref.watch(activeUserProvider);
    final user = userState.value;
    final l10n = AppLocalizations.of(context)!;
    final currentHour = DateTime.now().hour;
    final isEvening = _isEveningTime(currentHour);

    final activeMood = _selectedWellbeing ?? homeState.latestWellbeing?.status ?? 'good';

    if (homeState.isLoading || userState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.warmSand,
        body: AppLoadingState(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.warmSand,
      appBar: AppBar(
        title: Text(
          "Smritivan • স্মৃতিবন",
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isEvening ? const Color(0xFF2F3E46) : AppColors.deepSageGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 28),
            tooltip: 'Your Progress',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientAnalyticsView()),
            ).then((_) {
              ref.read(elderHomeProvider.notifier).loadData();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientSettingsView()),
            ).then((_) {
              ref.read(activeUserProvider.notifier).loadActiveUser();
              ref.read(elderHomeProvider.notifier).loadData();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
            tooltip: 'About',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
            tooltip: 'Caregiver Mode',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CaregiverAuthView()),
            ).then((_) {
              ref.read(elderHomeProvider.notifier).loadData();
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Time-Aware & Sundowning-Aware Header
              _buildGreetingHeader(user, l10n, activeMood, currentHour, isEvening),

              // 2. Today's Honest Summary / Progress Bar
              _buildOverviewPanel(homeState, l10n),

              // 3. Today's Focused / Suggested Cognitive Activity
              _buildSuggestedActivityCard(context, user?.id ?? 'patient_ner_001', l10n),

              // 4. Today's Reminders Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.todaysReminders,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textCharcoal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RemindersView()),
                      ).then((_) {
                        ref.read(elderHomeProvider.notifier).loadData();
                      }),
                      icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.deepSageGreen),
                      label: const Text(
                        "Manage",
                        style: TextStyle(
                          color: AppColors.deepSageGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildInlineReminders(context, homeState, l10n),

              // 5. Cognitive Games Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Text(
                  l10n.cognitiveGames,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textCharcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Text(
                  l10n.cognitiveGamesDesc,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
              _buildResponsiveGamesGrid(l10n),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(
    dynamic user,
    AppLocalizations l10n,
    String activeMood,
    int hour,
    bool isEvening,
  ) {
    String fullName = user?.name ?? "Bhaben Bora";
    String displayName = fullName.split(" ").first;
    final userId = user?.id ?? 'patient_ner_001';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEvening
              ? const [Color(0xFF52796F), Color(0xFF2F3E46)]
              : const [AppColors.softSageGreen, AppColors.deepSageGreen],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time-Aware Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _getTimeGreeting(displayName, hour),
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Audio Guidance Quick Toggle
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    if (user != null) {
                      final updated = user.copyWith(
                        soundEffectsEnabled: !user.soundEffectsEnabled,
                        voiceGuidanceEnabled: !user.soundEffectsEnabled,
                      );
                      await ref.read(activeUserProvider.notifier).updateUser(updated);
                      ref.read(elderHomeProvider.notifier).loadData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user?.soundEffectsEnabled == true ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user?.soundEffectsEnabled == true ? "Audio ON" : "Audio OFF",
                          style: AppTypography.buttonLabel.copyWith(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isEvening
                  ? "Take a calm moment. Relax and rest your mind."
                  : "Let's take today one gentle step at a time.",
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 22),

            // How Are You Feeling Check-in
            Text(
              l10n.howAreYouFeeling,
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildWellbeingBtn('good', '😊', l10n.feelingGood, userId, activeMood, l10n)),
                const SizedBox(width: 10),
                Expanded(child: _buildWellbeingBtn('okay', '🙂', l10n.feelingOkay, userId, activeMood, l10n)),
                const SizedBox(width: 10),
                Expanded(child: _buildWellbeingBtn('not_great', '😐', l10n.feelingNotGreat, userId, activeMood, l10n)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingBtn(
    String id,
    String emoji,
    String label,
    String userId,
    String activeMood,
    AppLocalizations l10n,
  ) {
    final bool isSelected = activeMood == id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          setState(() => _selectedWellbeing = id);
          await ref.read(wellbeingRepositoryProvider).saveCheckIn(userId, id);
          await ref.read(elderHomeProvider.notifier).loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("✓ ${l10n.wellbeingSaved}"),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.deepSageGreen,
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                clipBehavior: Clip.none,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  if (isSelected)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.deepSageGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? AppColors.deepSageGreen : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewPanel(ElderHomeState state, AppLocalizations l10n) {
    final totalSessions = state.gameStats['total_sessions'] ?? 0;
    final totalReminders = state.reminders.length;
    final doneReminders = state.reminders.where((r) => r.status == 'done').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        backgroundColor: Colors.white,
        borderColor: AppColors.paleParchment,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientAnalyticsView()),
                  ).then((_) => ref.read(elderHomeProvider.notifier).loadData());
                },
                child: _buildOverviewStat(
                  l10n.activityLabel,
                  "$totalSessions done",
                ),
              ),
            ),
            Container(width: 1, height: 44, color: AppColors.paleParchment),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RemindersView()),
                  ).then((_) => ref.read(elderHomeProvider.notifier).loadData());
                },
                child: _buildOverviewStat(
                  l10n.remindersLabel,
                  "$doneReminders / $totalReminders",
                ),
              ),
            ),
            Container(width: 1, height: 44, color: AppColors.paleParchment),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "❤️ Today's mood: ${state.latestWellbeing?.status.toUpperCase() ?? 'Good'}. Tap the smileys above to update anytime.",
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.deepSageGreen,
                    ),
                  );
                },
                child: _buildOverviewStat(
                  l10n.wellbeingLabel,
                  state.latestWellbeing?.status.toUpperCase() ?? 'GOOD',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.metricLabel.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepSageGreen,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuggestedActivityCard(BuildContext context, String userId, AppLocalizations l10n) {
    final progressionService = ref.watch(gameProgressionProvider);

    return FutureBuilder<double>(
      future: progressionService.getRecommendedLevel(userId, 'memory_match'),
      builder: (context, snapshot) {
        final currentLevel = snapshot.data ?? 1.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: AppCard(
            padding: const EdgeInsets.all(20.0),
            backgroundColor: const Color(0xFFFAF7F0),
            borderColor: AppColors.softSageGreen.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9C46A).withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🧠', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Suggested Game",
                            style: AppTypography.metricLabel.copyWith(
                              color: AppColors.deepSageGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Memory Match",
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.deepSageGreen.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Level ${currentLevel.toInt()}",
                        style: const TextStyle(
                          color: AppColors.deepSageGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Gentle concentration & card matching designed with cultural North-Eastern motifs.",
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppButton.primary(
                        text: "Play Activity",
                        icon: Icons.play_arrow,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LevelSelectionView(
                                gameType: 'memory_match',
                                gameTitle: 'Memory Match',
                                gameIcon: '🧠',
                                gameColor: const Color(0xFFE9C46A),
                                gameBuilder: (level) => MemoryMatchGame(currentDifficulty: level),
                              ),
                            ),
                          ).then((_) {
                            ref.read(elderHomeProvider.notifier).loadData();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.deepSageGreen,
                          side: const BorderSide(color: AppColors.deepSageGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          _scrollController.animateTo(
                            600,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          "More Games",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveGamesGrid(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final games = [
            GameCard(
              title: l10n.gameMemoryMatch,
              description: l10n.gameMemoryMatchDesc,
              icon: "🧠",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFFE9C46A),
              playLabel: l10n.play,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelSelectionView(
                    gameType: 'memory_match',
                    gameTitle: l10n.gameMemoryMatch,
                    gameIcon: '🧠',
                    gameColor: const Color(0xFFE9C46A),
                    gameBuilder: (level) => MemoryMatchGame(currentDifficulty: level),
                  ),
                ),
              ).then((_) => ref.read(elderHomeProvider.notifier).loadData()),
            ),
            GameCard(
              title: l10n.gamePictureRecall,
              description: l10n.gamePictureRecallDesc,
              icon: "🖼️",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFFF4A261),
              playLabel: l10n.play,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelSelectionView(
                    gameType: 'picture_recall',
                    gameTitle: l10n.gamePictureRecall,
                    gameIcon: '🖼️',
                    gameColor: const Color(0xFFF4A261),
                    gameBuilder: (level) => PictureRecallGame(currentDifficulty: level),
                  ),
                ),
              ).then((_) => ref.read(elderHomeProvider.notifier).loadData()),
            ),
            GameCard(
              title: l10n.gamePatternBuilder,
              description: l10n.gamePatternBuilderDesc,
              icon: "🧩",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFFE76F51),
              playLabel: l10n.play,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelSelectionView(
                    gameType: 'pattern_builder',
                    gameTitle: l10n.gamePatternBuilder,
                    gameIcon: '🧩',
                    gameColor: const Color(0xFFE76F51),
                    gameBuilder: (level) => PatternBuilderGame(currentDifficulty: level),
                  ),
                ),
              ).then((_) => ref.read(elderHomeProvider.notifier).loadData()),
            ),
            GameCard(
              title: l10n.gameWordGarden,
              description: l10n.gameWordGardenDesc,
              icon: "🔤",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFF2A9D8F),
              playLabel: l10n.play,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelSelectionView(
                    gameType: 'word_garden',
                    gameTitle: l10n.gameWordGarden,
                    gameIcon: '🔤',
                    gameColor: const Color(0xFF2A9D8F),
                    gameBuilder: (level) => WordGardenGame(currentDifficulty: level),
                  ),
                ),
              ).then((_) => ref.read(elderHomeProvider.notifier).loadData()),
            ),
            GameCard(
              title: l10n.gameCardRecall,
              description: l10n.gameCardRecallDesc,
              icon: "🃏",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFF264653),
              playLabel: l10n.play,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelSelectionView(
                    gameType: 'card_recall',
                    gameTitle: l10n.gameCardRecall,
                    gameIcon: '🃏',
                    gameColor: const Color(0xFF264653),
                    gameBuilder: (level) => CardRecallGame(currentDifficulty: level),
                  ),
                ),
              ).then((_) => ref.read(elderHomeProvider.notifier).loadData()),
            ),
            GameCard(
              title: l10n.gameDailyHelper,
              description: l10n.gameDailyHelperDesc,
              icon: "🛒",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFF84A98C),
              playLabel: l10n.play,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelSelectionView(
                    gameType: 'daily_helper',
                    gameTitle: l10n.gameDailyHelper,
                    gameIcon: '🛒',
                    gameColor: const Color(0xFF84A98C),
                    gameBuilder: (level) => DailyHelperGame(currentDifficulty: level),
                  ),
                ),
              ).then((_) => ref.read(elderHomeProvider.notifier).loadData()),
            ),
          ];

          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: games.map((game) => SizedBox(
              width: constraints.maxWidth >= 768
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth,
              child: game,
            )).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInlineReminders(BuildContext context, ElderHomeState state, AppLocalizations l10n) {
    if (state.reminders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: AppEmptyState(message: l10n.noRemindersToday),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          ...state.reminders.map((r) {
            final isDone = r.status == 'done' || r.status == 'acknowledged';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ReminderCard(
                title: r.title,
                time: r.time,
                icon: r.icon,
                themeColor: r.accentColor,
                isDone: isDone,
                doneLabel: l10n.done,
                markDoneLabel: l10n.markDone,
                onMarkDone: () async {
                  await ref.read(remindersProvider.notifier).markAsDone(r.id);
                  await ref.read(elderHomeProvider.notifier).loadData();
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
