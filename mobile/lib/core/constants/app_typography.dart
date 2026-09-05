// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Dementia-Friendly Typography Rules:
/// 1. Base size >= 18sp to prevent visual strain.
/// 2. Dyslexia-conscious letter and line spacing (1.4+ line-height multiplier).
/// 3. Clear sans-serif glyph differentiation (Lexend / Open Sans / Inter fallback).
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Lexend';

  // Base TextStyle helper with dyslexia-friendly characteristics
  static TextStyle get _baseStyle => GoogleFonts.lexend(
        color: AppColors.textCharcoal,
        letterSpacing: 0.5,
        height: 1.45,
      );

  // Dementia Hero / Large Banner Display
  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  // Screen Title / Key Prompt Headers
  static TextStyle get titleLarge => _baseStyle.copyWith(
        fontSize: 26.0,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  // Section Headers / Sub-headers
  static TextStyle get titleMedium => _baseStyle.copyWith(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Standard Dementia Primary Body Text (Strictly >= 18sp)
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  // Secondary Body / Supporting Instructions (Strictly >= 18sp for patient accessibility)
  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  // Interactive Button Labels (Clear, bold, high contrast against button fill)
  static TextStyle get buttonLabel => _baseStyle.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  // Voice Prompt / Spoken Instruction Subtitles
  static TextStyle get voiceSubtitle => _baseStyle.copyWith(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: AppColors.deepSageGreen,
        fontStyle: FontStyle.italic,
      );

  // Clinical & Caregiver Metric Badges
  static TextStyle get metricLabel => _baseStyle.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );
}

