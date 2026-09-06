// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../application/health_worker_provider.dart';
import 'health_worker_dashboard_view.dart';

class HealthWorkerAuthView extends ConsumerStatefulWidget {
  final bool isResetMode;
  const HealthWorkerAuthView({Key? key, this.isResetMode = false}) : super(key: key);

  @override
  ConsumerState<HealthWorkerAuthView> createState() => _HealthWorkerAuthViewState();
}

class _HealthWorkerAuthViewState extends ConsumerState<HealthWorkerAuthView> {
  String _pin = '';
  String _tempPin = '';
  String _setupStep = 'enter'; // 'enter', 'set', 'confirm'
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    if (widget.isResetMode) {
      _setupStep = 'set';
    }
  }

  void _addNumber(String num) {
    if (_pin.length < 4) {
      setState(() {
        _pin += num;
        _errorMsg = null;
      });
      if (_pin.length == 4) {
        _processPin();
      }
    }
  }

  void _removeLastNumber() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMsg = null;
      });
    }
  }

  void _clearPin() {
    setState(() {
      _pin = '';
      _errorMsg = null;
    });
  }

  Future<void> _processPin() async {
    if (_setupStep == 'set') {
      setState(() {
        _tempPin = _pin;
        _pin = '';
        _setupStep = 'confirm';
      });
    } else if (_setupStep == 'confirm') {
      if (_pin == _tempPin) {
        await ref.read(healthWorkerAuthProvider.notifier).updatePin(_pin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Health Worker PIN updated successfully'),
              backgroundColor: Color(0xFF2A9D8F),
            ),
          );
          if (widget.isResetMode) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HealthWorkerDashboardView()),
            );
          }
        }
      } else {
        setState(() {
          _pin = '';
          _tempPin = '';
          _setupStep = 'set';
          _errorMsg = 'PINs did not match. Please try setting again.';
        });
      }
    } else {
      // Enter mode
      final success = await ref.read(healthWorkerAuthProvider.notifier).authenticate(_pin);
      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HealthWorkerDashboardView()),
          );
        }
      } else {
        setState(() {
          _pin = '';
          _errorMsg = 'Incorrect Health Worker PIN. (Default: 1234)';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(healthWorkerAuthProvider);
    final worker = authState.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          widget.isResetMode ? "Set Health Worker PIN" : "Healthcare Professional Access",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.deepSageGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Header Card
              AppCard(
                padding: const EdgeInsets.all(20.0),
                backgroundColor: Colors.white,
                borderColor: AppColors.paleParchment,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.softSageGreen.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 40,
                        color: AppColors.deepSageGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _setupStep == 'set'
                          ? "Set New Health Worker PIN"
                          : _setupStep == 'confirm'
                              ? "Confirm New 4-Digit PIN"
                              : "Healthcare Worker Authorization",
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textCharcoal,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _setupStep == 'enter'
                          ? "Enter your 4-digit PIN to access patient cognitive monitoring, longitudinal trends, and clinical observation summaries."
                          : "Create a memorable 4-digit PIN for authorized healthcare access.",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (worker != null && _setupStep == 'enter') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user, size: 16, color: Color(0xFF1D3557)),
                            const SizedBox(width: 6),
                            Text(
                              "${worker.name} (${worker.designation})",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D3557),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.deepSageGreen : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.deepSageGreen : AppColors.textSecondary.withValues(alpha: 0.5),
                        width: 2.5,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Custom Keypad
              _buildKeypad(),

              const SizedBox(height: 20),

              if (!widget.isResetMode && _setupStep == 'enter')
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _setupStep = 'set';
                      _pin = '';
                      _tempPin = '';
                      _errorMsg = null;
                    });
                  },
                  icon: const Icon(Icons.lock_reset, size: 18, color: AppColors.deepSageGreen),
                  label: const Text(
                    "Reset Health Worker PIN",
                    style: TextStyle(color: AppColors.deepSageGreen, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 14),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 14),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton(
                icon: Icons.clear,
                onTap: _clearPin,
                backgroundColor: Colors.transparent,
                iconColor: AppColors.textSecondary,
              ),
              _buildNumberButton('0'),
              _buildKeypadButton(
                icon: Icons.backspace_outlined,
                onTap: _removeLastNumber,
                backgroundColor: Colors.transparent,
                iconColor: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String num) {
    return InkWell(
      onTap: () => _addNumber(num),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.paleParchment),
        ),
        alignment: Alignment.center,
        child: Text(
          num,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textCharcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: Icon(icon, size: 28, color: iconColor),
      ),
    );
  }
}
