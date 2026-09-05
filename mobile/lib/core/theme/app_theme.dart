// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_dimensions.dart';

/// Single Centralized Design System Theme
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.softSageGreen,
      scaffoldBackgroundColor: AppColors.warmSand,
      canvasColor: AppColors.softCream,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.softSageGreen,
        onPrimary: AppColors.textCharcoal,
        primaryContainer: AppColors.deepSageGreen,
        onPrimaryContainer: AppColors.softCream,
        secondary: AppColors.mutedTeal,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.lightTeal,
        onSecondaryContainer: AppColors.textCharcoal,
        surface: AppColors.softCream,
        onSurface: AppColors.textCharcoal,
        error: AppColors.warmTerracotta,
        onError: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelLarge: AppTypography.buttonLabel,
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.cardBorderRadius,
          side: const BorderSide(
            color: AppColors.paleParchment,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.softSageGreen,
          foregroundColor: AppColors.textCharcoal,
          elevation: 2,
          shadowColor: AppColors.deepSageGreen.withAlpha(50),
          minimumSize: const Size(AppDimensions.minTouchTargetSize, AppDimensions.minTouchTargetSize),
          padding: AppDimensions.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
            side: const BorderSide(
              color: AppColors.deepSageGreen,
              width: 1.5,
            ),
          ),
          textStyle: AppTypography.buttonLabel,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textCharcoal,
          minimumSize: const Size(AppDimensions.minTouchTargetSize, AppDimensions.minTouchTargetSize),
          padding: AppDimensions.buttonPadding,
          side: const BorderSide(
            color: AppColors.mutedTeal,
            width: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          textStyle: AppTypography.buttonLabel,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.warmSand,
        foregroundColor: AppColors.textCharcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textCharcoal,
          size: 32.0,
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.deepSageGreen,
        size: 36.0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.softCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: AppColors.paleParchment, width: 2),
        ),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyLarge,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.cardBorderRadius,
          borderSide: const BorderSide(color: AppColors.paleParchment, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.cardBorderRadius,
          borderSide: const BorderSide(color: AppColors.paleParchment, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.cardBorderRadius,
          borderSide: const BorderSide(color: AppColors.focusRing, width: 3),
        ),
        labelStyle: AppTypography.bodyMedium,
      ),
    );
  }
}
