// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';

/// Clinical Interaction & Dimension Metrics for Motor-Impaired & Tremor-Prone Elderly Patients
class AppDimensions {
  AppDimensions._();

  // Accessibility Rule: Minimum 64x64 dp touch target size
  static const double minTouchTargetSize = 64.0;
  static const double largeTouchTargetSize = 80.0;
  static const double gameTileSize = 100.0;
  static const double heroTileSize = 120.0;

  // Touch Target Box Constraints
  static const BoxConstraints minTouchConstraints = BoxConstraints(
    minWidth: minTouchTargetSize,
    minHeight: minTouchTargetSize,
  );

  static const BoxConstraints largeTouchConstraints = BoxConstraints(
    minWidth: largeTouchTargetSize,
    minHeight: largeTouchTargetSize,
  );

  // Spacing & Padding
  static const double spaceXS = 8.0;
  static const double spaceSM = 16.0;
  static const double spaceMD = 24.0;
  static const double spaceLG = 32.0;
  static const double spaceXL = 48.0;

  // Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 20.0,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 28.0,
    vertical: 18.0,
  );

  // Corner Radii (Soft, non-aggressive rounded geometries)
  static const double radiusSM = 12.0;
  static const double radiusMD = 18.0;
  static const double radiusLG = 24.0;
  static const double radiusPill = 999.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(radiusMD);
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(radiusLG);

  // High-Legibility Stroke Widths
  static const double focusBorderWidth = 3.0;
  static const double cardBorderWidth = 1.5;
}

