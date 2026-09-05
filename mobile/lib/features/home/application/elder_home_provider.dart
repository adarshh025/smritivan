// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_profile/presentation/user_provider.dart';
import '../../games/presentation/game_telemetry_provider.dart';
import '../../reminders/application/reminder_service.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../../reminders/domain/reminder_model.dart';
import '../../wellbeing/domain/wellbeing_model.dart';

class ElderHomeState {
  final Map<String, dynamic> gameStats;
  final List<ReminderModel> reminders;
  final WellbeingModel? latestWellbeing;
  final bool isLoading;

  ElderHomeState({
    required this.gameStats,
    required this.reminders,
    this.latestWellbeing,
    this.isLoading = false,
  });

  factory ElderHomeState.initial() => ElderHomeState(
    gameStats: {},
    reminders: [],
    latestWellbeing: null,
    isLoading: true,
  );
}

class ElderHomeNotifier extends StateNotifier<ElderHomeState> {
  final Ref _ref;

  ElderHomeNotifier(this._ref) : super(ElderHomeState.initial()) {
    loadData();
    _ref.listen(activeUserProvider, (previous, next) {
      if (next.value != null) {
        loadData();
      }
    });
  }

  Future<void> loadData() async {
    state = ElderHomeState(
      gameStats: state.gameStats,
      reminders: state.reminders,
      latestWellbeing: state.latestWellbeing,
      isLoading: true,
    );

    try {
      final user = _ref.read(activeUserProvider).value;
      if (user == null) {
        state = ElderHomeState.initial().copyWith(isLoading: false);
        return;
      }
      
      final userId = user.id;

      final gameRepo = _ref.read(gameSessionRepositoryProvider);
      final reminderRepo = _ref.read(reminderRepositoryProvider);
      final wellbeingRepo = _ref.read(wellbeingRepositoryProvider);

      final stats = await gameRepo.getAggregateStats(userId);
      final reminders = await reminderRepo.getRemindersForUser(userId);
      
      // Get today's reminders only
      final today = DateTime.now();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";
      final todayReminders = reminders.where((r) => r.createdAt.startsWith(todayStr)).toList();

      final wellbeingList = await wellbeingRepo.getRecentCheckIns(userId, limit: 1);
      final latestWellbeing = wellbeingList.isNotEmpty ? wellbeingList.first : null;

      state = ElderHomeState(
        gameStats: stats,
        reminders: reminders, // keep all, let UI filter or just use all for mvp
        latestWellbeing: latestWellbeing,
        isLoading: false,
      );
    } catch (e) {
      state = ElderHomeState(
        gameStats: state.gameStats,
        reminders: state.reminders,
        latestWellbeing: state.latestWellbeing,
        isLoading: false,
      );
    }
  }
}

extension on ElderHomeState {
  ElderHomeState copyWith({
    Map<String, dynamic>? gameStats,
    List<ReminderModel>? reminders,
    WellbeingModel? latestWellbeing,
    bool? isLoading,
  }) {
    return ElderHomeState(
      gameStats: gameStats ?? this.gameStats,
      reminders: reminders ?? this.reminders,
      latestWellbeing: latestWellbeing ?? this.latestWellbeing,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final elderHomeProvider = StateNotifierProvider<ElderHomeNotifier, ElderHomeState>((ref) {
  return ElderHomeNotifier(ref);
});
