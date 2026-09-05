// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
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

import '../../caregiver/presentation/caregiver_auth_view.dart';
import '../../reminders/presentation/reminders_view.dart';
import '../../about/presentation/about_view.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../application/elder_home_provider.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../reminders/application/reminder_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/patient_settings_view.dart';
import '../../personalization/application/personalization_provider.dart';
import '../../personalization/domain/personalization_models.dart';
import '../../daily_plan/application/daily_plan_provider.dart';
import '../../daily_plan/domain/daily_plan_model.dart';

class ElderHomeView extends ConsumerStatefulWidget {
  const ElderHomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<ElderHomeView> createState() => _ElderHomeViewState();
}

class _ElderHomeViewState extends ConsumerState<ElderHomeView> {
  String? _selectedWellbeing;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(elderHomeProvider.notifier).loadData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(elderHomeProvider);
    final dailyPlanState = ref.watch(dailyPlanProvider);
    final user = ref.watch(activeUserProvider).value;
    final l10n = AppLocalizations.of(context)!;
    final activeMood = _selectedWellbeing ?? homeState.latestWellbeing?.status ?? 'good';
    
    if (homeState.isLoading) {
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
        backgroundColor: AppColors.deepSageGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientSettingsView())),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutView())),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
            tooltip: 'Caregiver Mode',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverAuthView())),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(user, l10n, activeMood),
            _buildOverviewPanel(homeState, l10n),
            
            if (!dailyPlanState.isLoading && dailyPlanState.items.isNotEmpty)
              _buildTodaysPlan(context, dailyPlanState, l10n),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                l10n.cognitiveGames,
                style: AppTypography.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                l10n.cognitiveGamesDesc,
                style: AppTypography.bodyMedium,
              ),
            ),
            
            _buildResponsiveGamesGrid(l10n),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
              child: Text(
                l10n.todaysReminders,
                style: AppTypography.titleLarge,
              ),
            ),
            
            _buildInlineReminders(context, homeState, l10n),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(dynamic user, AppLocalizations l10n, String activeMood) {
    String name = user?.name ?? "Guest";
    if (name.contains(" ")) name = name.split(" ")[0];
    final userId = user?.id ?? 'patient_ner_001';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.softSageGreen, AppColors.deepSageGreen],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.goodAfternoon(name),
                style: AppTypography.displayLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  if (user != null) {
                    final updated = user.copyWith(
                      soundEffectsEnabled: !user.soundEffectsEnabled,
                      voiceGuidanceEnabled: !user.soundEffectsEnabled
                    );
                    ref.read(activeUserProvider.notifier).updateUser(updated);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user?.soundEffectsEnabled == true ? Icons.volume_up : Icons.volume_off, 
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user?.soundEffectsEnabled == true ? "Audio ON" : "Audio OFF",
                        style: AppTypography.buttonLabel.copyWith(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.howAreYouFeeling,
                style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildWellbeingBtn('good', '😊', l10n.feelingGood, userId, activeMood, l10n)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildWellbeingBtn('okay', '🙂', l10n.feelingOkay, userId, activeMood, l10n)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildWellbeingBtn('not_great', '😐', l10n.feelingNotGreat, userId, activeMood, l10n)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWellbeingBtn(String id, String emoji, String label, String userId, String activeMood, AppLocalizations l10n) {
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
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
              const SizedBox(height: 4),
              Text(
                label, 
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? AppColors.deepSageGreen : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("🎮 $totalSessions cognitive activities completed! Choose any game below to play."),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: _buildOverviewStat(l10n.activityLabel, l10n.totalSessionsLabel(totalSessions)),
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.paleParchment),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersView()));
                },
                child: _buildOverviewStat(l10n.remindersLabel, l10n.todayCountLabel(state.reminders.length)),
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.paleParchment),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❤️ Well-being: ${state.latestWellbeing?.status.toUpperCase() ?? 'Not logged yet'}. Tap the face icons above anytime to update!"),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: _buildOverviewStat(l10n.wellbeingLabel, state.latestWellbeing?.status.toUpperCase() ?? 'NONE'),
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
        Text(label, style: AppTypography.metricLabel, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.deepSageGreen), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildTodaysPlan(BuildContext context, DailyPlanState state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: AppColors.successSage, size: 28),
              const SizedBox(width: 8),
              Text("🌱 Today's Plan", style: AppTypography.titleLarge.copyWith(color: AppColors.deepSageGreen)),
            ],
          ),
          const SizedBox(height: 16),
          ...state.items.map((item) => _buildPlanItemNode(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildPlanItemNode(BuildContext context, DailyPlanItem item) {
    String timeStr = "";
    if (item.scheduledTime.hour < 12) timeStr += "☀️ Morning";
    else if (item.scheduledTime.hour < 17) timeStr += "🌤️ Afternoon";
    else timeStr += "🧩 Evening";

    timeStr += "\n${item.scheduledTime.hour > 12 ? item.scheduledTime.hour - 12 : item.scheduledTime.hour}:${item.scheduledTime.minute.toString().padLeft(2, '0')} ${item.scheduledTime.hour >= 12 ? 'PM' : 'AM'}";

    bool isCompleted = item.status == PlanItemStatus.completed;
    bool isSkipped = item.status == PlanItemStatus.skipped;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(timeStr, style: AppTypography.bodyMedium.copyWith(fontSize: 14)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 2,
            height: item.type == PlanItemType.game && !isCompleted && !isSkipped ? 160 : 70,
            color: AppColors.paleParchment,
          ),
          Expanded(
            child: Opacity(
              opacity: isSkipped ? 0.5 : 1.0,
              child: AppCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: isCompleted ? AppColors.successSage.withOpacity(0.1) : AppColors.cardSurface,
                borderColor: isCompleted ? AppColors.successSage : AppColors.paleParchment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.type == PlanItemType.reminder ? '⏰ ' : (item.type == PlanItemType.wellbeing ? '❤️ ' : '')}${item.title}",
                            style: AppTypography.titleMedium,
                          ),
                        ),
                        if (isCompleted)
                          Text("✓ Done", style: AppTypography.buttonLabel.copyWith(color: AppColors.successSage))
                        else if (isSkipped)
                          Text("Skipped", style: AppTypography.buttonLabel.copyWith(color: AppColors.textMuted))
                        else if (item.status == PlanItemStatus.missed)
                          Text("Missed", style: AppTypography.buttonLabel.copyWith(color: AppColors.warmTerracotta))
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.subtitle, style: AppTypography.bodyMedium),
                    
                    if (item.type == PlanItemType.game && !isCompleted && !isSkipped) ...[
                      const SizedBox(height: 16),
                      AppButton.primary(
                        text: "Start",
                        icon: Icons.play_arrow,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                            gameType: item.associatedGameType!,
                            gameTitle: CognitiveDomains.getGameName(item.associatedGameType!),
                            gameIcon: _getIconForGame(item.associatedGameType!),
                            gameColor: _getColorForGame(item.associatedGameType!),
                            gameBuilder: (level) => _buildGameScreen(item.associatedGameType!, item.gameLevel ?? level),
                          ))).then((_) {
                            ref.read(dailyPlanProvider.notifier).loadPlan();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              text: "Skip",
                              onPressed: () => ref.read(dailyPlanProvider.notifier).skipActivity(item.associatedGameType!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton.secondary(
                              text: "Change",
                              onPressed: () => ref.read(dailyPlanProvider.notifier).changeActivity(item.associatedGameType!),
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForGame(String type) {
    switch(type) {
      case 'memory_match': return '🧠';
      case 'picture_recall': return '🖼️';
      case 'pattern_builder': return '🧩';
      case 'word_garden': return '🔤';
      case 'card_recall': return '🃏';
      case 'daily_helper': return '🛒';
      default: return '🧠';
    }
  }

  Color _getColorForGame(String type) {
    switch(type) {
      case 'memory_match': return const Color(0xFFE9C46A);
      case 'picture_recall': return const Color(0xFFF4A261);
      case 'pattern_builder': return const Color(0xFFE76F51);
      case 'word_garden': return const Color(0xFF2A9D8F);
      case 'card_recall': return const Color(0xFF264653);
      case 'daily_helper': return const Color(0xFF84A98C);
      default: return AppColors.softSageGreen;
    }
  }

  Widget _buildGameScreen(String type, double level) {
    switch(type) {
      case 'memory_match': return MemoryMatchGame(currentDifficulty: level);
      case 'picture_recall': return PictureRecallGame(currentDifficulty: level);
      case 'pattern_builder': return PatternBuilderGame(currentDifficulty: level);
      case 'word_garden': return WordGardenGame(currentDifficulty: level);
      case 'card_recall': return CardRecallGame(currentDifficulty: level);
      case 'daily_helper': return DailyHelperGame(currentDifficulty: level);
      default: return MemoryMatchGame(currentDifficulty: level);
    }
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                gameType: 'memory_match',
                gameTitle: l10n.gameMemoryMatch,
                gameIcon: '🧠',
                gameColor: const Color(0xFFE9C46A),
                gameBuilder: (level) => MemoryMatchGame(currentDifficulty: level),
              ))),
            ),
            GameCard(
              title: l10n.gamePictureRecall,
              description: l10n.gamePictureRecallDesc,
              icon: "🖼️",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFFF4A261),
              playLabel: l10n.play,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                gameType: 'picture_recall',
                gameTitle: l10n.gamePictureRecall,
                gameIcon: '🖼️',
                gameColor: const Color(0xFFF4A261),
                gameBuilder: (level) => PictureRecallGame(currentDifficulty: level),
              ))),
            ),
            GameCard(
              title: l10n.gamePatternBuilder,
              description: l10n.gamePatternBuilderDesc,
              icon: "🧩",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFFE76F51),
              playLabel: l10n.play,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                gameType: 'pattern_builder',
                gameTitle: l10n.gamePatternBuilder,
                gameIcon: '🧩',
                gameColor: const Color(0xFFE76F51),
                gameBuilder: (level) => PatternBuilderGame(currentDifficulty: level),
              ))),
            ),
            GameCard(
              title: l10n.gameWordGarden,
              description: l10n.gameWordGardenDesc,
              icon: "🔤",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFF2A9D8F),
              playLabel: l10n.play,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                gameType: 'word_garden',
                gameTitle: l10n.gameWordGarden,
                gameIcon: '🔤',
                gameColor: const Color(0xFF2A9D8F),
                gameBuilder: (level) => WordGardenGame(currentDifficulty: level),
              ))),
            ),
            GameCard(
              title: l10n.gameCardRecall,
              description: l10n.gameCardRecallDesc,
              icon: "🃏",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFF264653),
              playLabel: l10n.play,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                gameType: 'card_recall',
                gameTitle: l10n.gameCardRecall,
                gameIcon: '🃏',
                gameColor: const Color(0xFF264653),
                gameBuilder: (level) => CardRecallGame(currentDifficulty: level),
              ))),
            ),
            GameCard(
              title: l10n.gameDailyHelper,
              description: l10n.gameDailyHelperDesc,
              icon: "🛒",
              difficultyLabel: l10n.adaptive,
              themeColor: const Color(0xFF84A98C),
              playLabel: l10n.play,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelSelectionView(
                gameType: 'daily_helper',
                gameTitle: l10n.gameDailyHelper,
                gameIcon: '🛒',
                gameColor: const Color(0xFF84A98C),
                gameBuilder: (level) => DailyHelperGame(currentDifficulty: level),
              ))),
            ),
          ];

          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: games.map((game) => SizedBox(
              width: constraints.maxWidth >= 1024 
                  ? (constraints.maxWidth - 32) / 3 
                  : constraints.maxWidth >= 768 
                      ? (constraints.maxWidth - 16) / 2 
                      : constraints.maxWidth,
              child: IntrinsicHeight(child: game),
            )).toList(),
          );
        }
      ),
    );
  }

  Widget _buildInlineReminders(BuildContext context, ElderHomeState state, AppLocalizations l10n) {
    if (state.reminders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: AppEmptyState(message: l10n.noRemindersToday),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          ...state.reminders.map((r) {
            final isDone = r.status == 'done';
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
                onMarkDone: () {
                  ref.read(remindersProvider.notifier).markAsDone(r.id);
                  ref.read(elderHomeProvider.notifier).loadData();
                },
              ),
            );
          }).toList(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AppButton.text(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersView())),
                icon: Icons.list,
                text: l10n.viewAllReminders,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
