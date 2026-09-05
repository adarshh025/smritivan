// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../auth_profile/presentation/user_provider.dart';
import '../../games/presentation/game_telemetry_provider.dart';
import '../../reminders/application/reminder_service.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../../personalization/application/personalization_provider.dart';
import '../domain/daily_plan_model.dart';
import 'daily_plan_service.dart';

final dailyPlanServiceProvider = Provider<DailyPlanService>((ref) {
  final gameRepo = ref.watch(gameSessionRepositoryProvider);
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final wellbeingRepo = ref.watch(wellbeingRepositoryProvider);
  final persService = ref.watch(personalizationServiceProvider);
  const storage = FlutterSecureStorage();

  return DailyPlanService(gameRepo, reminderRepo, wellbeingRepo, persService, storage);
});

class DailyPlanState {
  final List<DailyPlanItem> items;
  final bool isLoading;

  const DailyPlanState({
    required this.items,
    this.isLoading = false,
  });
}

class DailyPlanNotifier extends StateNotifier<DailyPlanState> {
  final Ref _ref;

  DailyPlanNotifier(this._ref) : super(const DailyPlanState(items: [], isLoading: true)) {
    loadPlan();
  }

  Future<void> loadPlan() async {
    final user = _ref.read(activeUserProvider).value;
    if (user == null) {
      state = const DailyPlanState(items: [], isLoading: false);
      return;
    }

    state = DailyPlanState(items: state.items, isLoading: true);
    
    final service = _ref.read(dailyPlanServiceProvider);
    try {
      final items = await service.getTodayPlan(user);
      if (mounted) {
        state = DailyPlanState(items: items, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = DailyPlanState(items: state.items, isLoading: false);
      }
    }
  }

  Future<void> skipActivity(String gameType) async {
    final user = _ref.read(activeUserProvider).value;
    if (user == null) return;

    final service = _ref.read(dailyPlanServiceProvider);
    await service.markActivitySkipped(user.id, gameType);
    await loadPlan();
  }

  Future<void> changeActivity(String currentGameType) async {
    final user = _ref.read(activeUserProvider).value;
    if (user == null) return;

    final service = _ref.read(dailyPlanServiceProvider);
    await service.changeActivity(user.id, currentGameType);
    await loadPlan();
  }
}

final dailyPlanProvider = StateNotifierProvider<DailyPlanNotifier, DailyPlanState>((ref) {
  return DailyPlanNotifier(ref);
});
