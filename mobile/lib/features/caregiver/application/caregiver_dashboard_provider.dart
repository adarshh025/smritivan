import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../games/presentation/game_telemetry_provider.dart'; // contains gameSessionRepositoryProvider
import '../../reminders/application/reminder_service.dart';     // contains reminderRepositoryProvider
import '../../wellbeing/data/wellbeing_repository.dart';      // contains wellbeingRepositoryProvider
import '../../home/application/elder_home_provider.dart';

import '../../games/domain/game_session_model.dart';
import '../../reminders/domain/reminder_model.dart';
import '../../wellbeing/domain/wellbeing_model.dart';
import '../../auth_profile/presentation/user_provider.dart';

class CaregiverDashboardState {
  final Map<String, dynamic> gameStats;
  final List<GameSessionModel> gameHistory;
  final List<ReminderModel> reminders;
  final List<WellbeingModel> wellbeing;
  final bool isLoading;

  CaregiverDashboardState({
    required this.gameStats,
    required this.gameHistory,
    required this.reminders,
    required this.wellbeing,
    this.isLoading = false,
  });

  factory CaregiverDashboardState.initial() => CaregiverDashboardState(
    gameStats: {},
    gameHistory: [],
    reminders: [],
    wellbeing: [],
    isLoading: true,
  );
}

class CaregiverDashboardNotifier extends StateNotifier<CaregiverDashboardState> {
  final Ref _ref;
  final String _userId;

  CaregiverDashboardNotifier(this._ref, this._userId) : super(CaregiverDashboardState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    final targetUserId = _ref.read(activeUserProvider).value?.id ?? _userId;

    state = CaregiverDashboardState(
      gameStats: state.gameStats,
      gameHistory: state.gameHistory,
      reminders: state.reminders,
      wellbeing: state.wellbeing,
      isLoading: true,
    );

    try {
      final gameRepo = _ref.read(gameSessionRepositoryProvider);
      final reminderRepo = _ref.read(reminderRepositoryProvider);
      final wellbeingRepo = _ref.read(wellbeingRepositoryProvider);

      final stats = await gameRepo.getAggregateStats(targetUserId);
      final history = await gameRepo.getSessionHistory(targetUserId, limit: 15);
      final reminders = await reminderRepo.getRemindersForUser(targetUserId);
      final wellbeing = await wellbeingRepo.getRecentCheckIns(targetUserId, limit: 10);

      state = CaregiverDashboardState(
        gameStats: stats,
        gameHistory: history,
        reminders: reminders,
        wellbeing: wellbeing,
        isLoading: false,
      );
    } catch (e) {
      state = CaregiverDashboardState(
        gameStats: state.gameStats,
        gameHistory: state.gameHistory,
        reminders: state.reminders,
        wellbeing: state.wellbeing,
        isLoading: false,
      );
    }
  }

  Future<void> toggleReminder(String reminderId) async {
    final reminderRepo = _ref.read(reminderRepositoryProvider);
    await reminderRepo.toggleStatus(reminderId);
    await loadData();
    _ref.read(remindersProvider.notifier).loadReminders();
    _ref.read(elderHomeProvider.notifier).loadData();
  }

  Future<void> addReminder(String title, String time, String type, {String priority = 'normal', String? description}) async {
    final targetUserId = _ref.read(activeUserProvider).value?.id ?? _userId;
    final reminderRepo = _ref.read(reminderRepositoryProvider);
    final reminder = ReminderModel(
      id: const Uuid().v4(),
      userId: targetUserId,
      title: title,
      description: description,
      type: type,
      time: time,
      priority: priority,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      hlcTimestamp: '',
    );
    await reminderRepo.saveReminder(reminder);
    await loadData();
    _ref.read(remindersProvider.notifier).loadReminders();
    _ref.read(elderHomeProvider.notifier).loadData();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final reminderRepo = _ref.read(reminderRepositoryProvider);
    await reminderRepo.saveReminder(reminder);
    await loadData();
    _ref.read(remindersProvider.notifier).loadReminders();
    _ref.read(elderHomeProvider.notifier).loadData();
  }

  Future<void> deleteReminder(String reminderId) async {
    final reminderRepo = _ref.read(reminderRepositoryProvider);
    await reminderRepo.deleteReminder(reminderId);
    await loadData();
    _ref.read(remindersProvider.notifier).loadReminders();
    _ref.read(elderHomeProvider.notifier).loadData();
  }
}

final caregiverDashboardProvider = StateNotifierProvider<CaregiverDashboardNotifier, CaregiverDashboardState>((ref) {
  final user = ref.watch(activeUserProvider).value;
  return CaregiverDashboardNotifier(ref, user?.id ?? 'patient_ner_001');
});
