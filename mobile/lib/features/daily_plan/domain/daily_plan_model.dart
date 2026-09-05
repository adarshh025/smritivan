// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

enum PlanItemType {
  reminder,
  game,
  wellbeing,
}

enum PlanItemStatus {
  upcoming,
  completed,
  skipped,
  missed,
}

/// Unified timeline element to merge Reminders, Games, and Wellbeing Check-ins
class DailyPlanItem {
  final String id;
  final PlanItemType type;
  final String title;
  final String subtitle;
  final DateTime scheduledTime;
  final PlanItemStatus status;
  final String? associatedGameType; // Non-null if type == PlanItemType.game
  final double? gameLevel;
  final String? icon;

  const DailyPlanItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.scheduledTime,
    required this.status,
    this.associatedGameType,
    this.gameLevel,
    this.icon,
  });

  DailyPlanItem copyWith({
    String? id,
    PlanItemType? type,
    String? title,
    String? subtitle,
    DateTime? scheduledTime,
    PlanItemStatus? status,
    String? associatedGameType,
    double? gameLevel,
    String? icon,
  }) {
    return DailyPlanItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      associatedGameType: associatedGameType ?? this.associatedGameType,
      gameLevel: gameLevel ?? this.gameLevel,
      icon: icon ?? this.icon,
    );
  }
}
