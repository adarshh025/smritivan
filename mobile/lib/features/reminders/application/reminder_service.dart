// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_provider.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder_model.dart';
import '../presentation/reminder_provider.dart';
import '../../auth_profile/presentation/user_provider.dart';

// Re-export reminderRepositoryProvider from presentation/reminder_provider.dart for backwards compatibility
export '../presentation/reminder_provider.dart' show reminderRepositoryProvider;

class ReminderService {
  final ReminderRepository _repo;
  final _uuid = const Uuid();

  ReminderService(this._repo);

  Future<List<ReminderModel>> getRemindersForUser(String userId) {
    return _repo.getRemindersForUser(userId);
  }

  Future<void> addReminder(String userId, String title, String time, String type, {String priority = 'normal', String? description}) async {
    final newReminder = ReminderModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      description: description,
      type: type,
      time: time,
      priority: priority,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      hlcTimestamp: '', // DB handles this
    );
    await _repo.saveReminder(newReminder);
  }

  Future<void> markAsDone(String id) async {
    await _repo.updateStatus(id, 'done');
  }

  Future<void> toggleReminder(String id) async {
    await _repo.toggleStatus(id);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _repo.saveReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _repo.deleteReminder(id);
  }
}

// Provides the Service
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref.watch(reminderRepositoryProvider));
});

// StateNotifier to hold the current list of reminders so the UI can be reactive
class RemindersNotifier extends StateNotifier<AsyncValue<List<ReminderModel>>> {
  final ReminderService _service;
  final String _userId;

  RemindersNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = const AsyncValue.loading();
    try {
      final list = await _service.getRemindersForUser(_userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReminder(String title, String time, String type, {String priority = 'normal', String? description}) async {
    final reminder = ReminderModel(
      id: const Uuid().v4(),
      userId: _userId,
      title: title,
      description: description,
      type: type,
      time: time,
      priority: priority,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      hlcTimestamp: '',
    );
    await _service._repo.saveReminder(reminder);
    await loadReminders();
  }

  Future<void> markAsDone(String id) async {
    await _service.markAsDone(id);
    await loadReminders();
  }

  Future<void> toggleReminder(String id) async {
    await _service.toggleReminder(id);
    await loadReminders();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _service.updateReminder(reminder);
    await loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _service.deleteReminder(id);
    await loadReminders();
  }
}

// The main provider the UI listens to. Defaulting to 'patient_ner_001' for hackathon MVP.
final remindersProvider = StateNotifierProvider<RemindersNotifier, AsyncValue<List<ReminderModel>>>((ref) {
  final service = ref.watch(reminderServiceProvider);
  final user = ref.watch(activeUserProvider).value;
  return RemindersNotifier(service, user?.id ?? 'patient_ner_001');
});
