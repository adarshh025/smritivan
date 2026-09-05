// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../games/data/game_session_repository.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../../personalization/application/personalization_service.dart';
import '../../personalization/domain/personalization_models.dart';
import '../../auth_profile/domain/user_model.dart';
import '../domain/daily_plan_model.dart';

class DailyPlanService {
  final GameSessionRepository _gameRepo;
  final ReminderRepository _reminderRepo;
  final WellbeingRepository _wellbeingRepo;
  final PersonalizationService _personalizationService;
  final FlutterSecureStorage _storage;

  DailyPlanService(
    this._gameRepo,
    this._reminderRepo,
    this._wellbeingRepo,
    this._personalizationService,
    this._storage,
  );

  String get _todayKey => "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  /// Generates the deterministic Daily Plan merging Reminders, Games, and Wellbeing
  Future<List<DailyPlanItem>> getTodayPlan(UserModel user) async {
    final String userId = user.id;
    final List<DailyPlanItem> plan = [];

    // 1. Add Reminders
    final reminders = await _reminderRepo.getRemindersForUser(userId);
    final todayReminders = reminders.where((r) => r.createdAt.startsWith(_todayKey)).toList();
    
    for (var r in todayReminders) {
      final timeParts = r.time.split(':');
      DateTime dt = DateTime.now();
      if (timeParts.length == 2) {
        int hour = int.tryParse(timeParts[0]) ?? 9;
        int min = int.tryParse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        if (r.time.toLowerCase().contains('pm') && hour < 12) hour += 12;
        if (r.time.toLowerCase().contains('am') && hour == 12) hour = 0;
        dt = DateTime(dt.year, dt.month, dt.day, hour, min);
      }

      PlanItemStatus status = PlanItemStatus.upcoming;
      if (r.status == 'done') status = PlanItemStatus.completed;
      else if (dt.isBefore(DateTime.now())) status = PlanItemStatus.missed;

      plan.add(DailyPlanItem(
        id: r.id,
        type: PlanItemType.reminder,
        title: r.title,
        subtitle: r.description ?? "${r.type.toUpperCase()} Reminder",
        scheduledTime: dt,
        status: status,
      ));
    }

    // 2. Add Recommended Game
    final rec = await _personalizationService.getRecommendedActivity(userId);
    
    // Check local storage if it was skipped or swapped
    final overrideStr = await _storage.read(key: 'plan_override_${_todayKey}_$userId');
    String actualGame = rec.recommendedGameType;
    String actualReason = rec.reason;
    if (overrideStr != null) {
       actualGame = overrideStr;
       actualReason = "Alternative Activity Selected";
    }

    final skippedStr = await _storage.read(key: 'skipped_${_todayKey}_$userId');
    List<String> skippedGames = [];
    if (skippedStr != null) {
      skippedGames = List<String>.from(jsonDecode(skippedStr));
    }

    // Check game history to see if completed today
    final sessions = await _gameRepo.getSessionHistory(userId, limit: 100);
    final todaySessions = sessions.where((s) => s.timestamp.startsWith(_todayKey)).toList();
    
    bool isCompleted = todaySessions.any((s) => s.gameType == actualGame);
    double? lastScore;
    if (isCompleted) {
      lastScore = todaySessions.lastWhere((s) => s.gameType == actualGame).cvsScore;
    }

    PlanItemStatus gameStatus = PlanItemStatus.upcoming;
    if (isCompleted) gameStatus = PlanItemStatus.completed;
    else if (skippedGames.contains(actualGame)) gameStatus = PlanItemStatus.skipped;

    // Slot it around 11 AM if morning preferred, else 5 PM
    final profile = await _personalizationService.derivePatientActivityProfile(userId);
    String timePref = user.preferredActivityTime ?? profile.preferredActivityTime;
    
    DateTime gameTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0);
    if (timePref == 'Evening') gameTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0);
    if (timePref == 'Afternoon') gameTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0);

    plan.add(DailyPlanItem(
      id: "game_$actualGame",
      type: PlanItemType.game,
      title: CognitiveDomains.getGameName(actualGame),
      subtitle: isCompleted && lastScore != null ? "Completed! Score: ${lastScore.toInt()}%" : actualReason,
      scheduledTime: gameTime,
      status: gameStatus,
      associatedGameType: actualGame,
      gameLevel: rec.recommendedLevel,
    ));

    // 3. Add Evening Wellbeing Check-in
    final checkins = await _wellbeingRepo.getRecentCheckIns(userId, limit: 10);
    final todayCheckins = checkins.where((c) => c.timestamp.startsWith(_todayKey)).toList();

    PlanItemStatus wellbeingStatus = PlanItemStatus.upcoming;
    if (todayCheckins.isNotEmpty) wellbeingStatus = PlanItemStatus.completed;
    
    plan.add(DailyPlanItem(
      id: "wellbeing_evening",
      type: PlanItemType.wellbeing,
      title: "Evening Check-in",
      subtitle: todayCheckins.isNotEmpty ? "Feeling: ${todayCheckins.first.status.replaceAll('_', ' ')}" : "How are you feeling today?",
      scheduledTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 0),
      status: wellbeingStatus,
    ));

    // Sort chronologically
    plan.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return plan;
  }

  Future<void> markActivitySkipped(String userId, String gameType) async {
    final skippedStr = await _storage.read(key: 'skipped_${_todayKey}_$userId');
    List<String> skippedGames = [];
    if (skippedStr != null) {
      skippedGames = List<String>.from(jsonDecode(skippedStr));
    }
    if (!skippedGames.contains(gameType)) {
      skippedGames.add(gameType);
      await _storage.write(key: 'skipped_${_todayKey}_$userId', value: jsonEncode(skippedGames));
    }
  }

  Future<void> changeActivity(String userId, String currentGameType) async {
    // Find an alternative that hasn't been skipped and isn't the current one
    final skippedStr = await _storage.read(key: 'skipped_${_todayKey}_$userId');
    List<String> skippedGames = [];
    if (skippedStr != null) {
      skippedGames = List<String>.from(jsonDecode(skippedStr));
    }
    skippedGames.add(currentGameType); // Treat old one as skipped to avoid going back

    final allGames = CognitiveDomains.allGameTypes;
    final available = allGames.where((g) => !skippedGames.contains(g)).toList();
    
    if (available.isNotEmpty) {
      // Pick random alternative
      available.shuffle();
      await _storage.write(key: 'plan_override_${_todayKey}_$userId', value: available.first);
    }
  }
}
