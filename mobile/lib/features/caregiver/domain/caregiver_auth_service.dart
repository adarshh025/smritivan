// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Caregiver PIN Authentication Guard to prevent accidental patient tampering
class CaregiverAuthService {
  static const String _pinStorageKey = 'caregiver_master_pin_code';
  static const String defaultPin = '2600'; // SIH 2026 Problem Statement ID 26003 Reference

  final FlutterSecureStorage _storage;

  CaregiverAuthService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _storage.read(key: _pinStorageKey) ?? defaultPin;
    return enteredPin.trim() == storedPin.trim();
  }

  Future<void> updatePin(String newPin) async {
    await _storage.write(key: _pinStorageKey, value: newPin.trim());
  }
}

