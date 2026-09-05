// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/services.dart';

/// Calibrated Gentle Haptic Feedback Service for Dementia Patients
/// Avoids aggressive buzzes that cause sensory alarm; provides soft tactile confirmation.
class HapticService {
  HapticService._();

  /// Soft touch acknowledgement for tile selections and buttons
  static Future<void> lightTouch() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Gentle success confirmation for completed game patterns
  static Future<void> successFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Low-frequency gentle notification for reminders
  static Future<void> reminderCue() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}

