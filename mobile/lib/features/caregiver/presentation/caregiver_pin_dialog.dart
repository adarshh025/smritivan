// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import '../../../core/audio/haptic_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../domain/caregiver_auth_service.dart';

/// Caregiver PIN Entry Modal with Large Accessible Numpad
class CaregiverPinDialog extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const CaregiverPinDialog({super.key, required this.onAuthenticated});

  @override
  State<CaregiverPinDialog> createState() => _CaregiverPinDialogState();
}

class _CaregiverPinDialogState extends State<CaregiverPinDialog> {
  final CaregiverAuthService _authService = CaregiverAuthService();
  String _enteredPin = '';
  String? _errorMessage;

  void _onDigitPressed(String digit) async {
    if (_enteredPin.length < 4) {
      await HapticService.lightTouch();
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        final isValid = await _authService.verifyPin(_enteredPin);
        if (isValid) {
          await HapticService.successFeedback();
          if (mounted) {
            Navigator.of(context).pop();
            widget.onAuthenticated();
          }
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'Incorrect PIN. Default is 2600.';
          });
        }
      }
    }
  }

  void _onDeletePressed() async {
    if (_enteredPin.isNotEmpty) {
      await HapticService.lightTouch();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.softCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        side: const BorderSide(color: AppColors.paleParchment, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_person_outlined, size: 48, color: AppColors.deepSageGreen),
            const SizedBox(height: 12),
            Text('Caregiver Security PIN', style: AppTypography.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Enter 4-digit PIN to access clinical analytics & sync (Default: 2600)',
              style: AppTypography.metricLabel,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // PIN Dots Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.deepSageGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.deepSageGreen, width: 2),
                  ),
                );
              }),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTypography.metricLabel.copyWith(color: AppColors.warmTerracotta, fontWeight: FontWeight.bold),
              ),
            ],

            const SizedBox(height: 24),

            // Numpad Grid
            Column(
              children: [
                _buildNumpadRow(['1', '2', '3']),
                const SizedBox(height: 12),
                _buildNumpadRow(['4', '5', '6']),
                const SizedBox(height: 12),
                _buildNumpadRow(['7', '8', '9']),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 64, height: 64),
                    _buildNumpadButton('0'),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 28, color: AppColors.textCharcoal),
                        onPressed: _onDeletePressed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumpadButton(d)).toList(),
    );
  }

  Widget _buildNumpadButton(String digit) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.paleParchment, width: 1.5),
      ),
      child: InkWell(
        onTap: () => _onDigitPressed(digit),
        customBorder: const CircleBorder(),
        child: Center(
          child: Text(
            digit,
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

