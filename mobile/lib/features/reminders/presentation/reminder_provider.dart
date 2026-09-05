// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (স্মৃতিवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/audio/haptic_service.dart';
import '../../../core/database/database_provider.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder_model.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return ReminderRepository(appDb);
});

final remindersListProvider = StateNotifierProvider<RemindersNotifier, AsyncValue<List<ReminderModel>>>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  final user = ref.watch(activeUserProvider).value;
  return RemindersNotifier(repo, user?.id ?? 'patient_ner_001', ref);
});

class RemindersNotifier extends StateNotifier<AsyncValue<List<ReminderModel>>> {
  final ReminderRepository _repo;
  final String _userId;
  final Ref _ref;

  RemindersNotifier(this._repo, this._userId, this._ref) : super(const AsyncValue.loading()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getRemindersForUser(_userId);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acknowledgeReminder(String reminderId) async {
    await HapticService.successFeedback();
    await _repo.updateStatus(reminderId, 'acknowledged');
    await loadReminders();
  }

  Future<void> addReminder({
    required String title,
    required String type,
    required String time,
    String? assetUrl,
    String? priority,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final appDb = _ref.read(appDatabaseProvider);
    final hlc = appDb.generateNextHlc().toCanonicalString();

    final newReminder = ReminderModel(
      id: const Uuid().v4(),
      userId: _userId,
      title: title,
      type: type,
      time: time,
      priority: priority ?? 'normal',
      assetUrl: assetUrl,
      status: 'pending',
      createdAt: nowIso,
      updatedAt: nowIso,
      hlcTimestamp: hlc,
    );

    await _repo.saveReminder(newReminder);
    await loadReminders();
  }

  Future<void> removeReminder(String reminderId) async {
    await _repo.deleteReminder(reminderId);
    await loadReminders();
  }
}

