// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/encryption_service.dart';
import 'app_database.dart';

/// Provider for hardware-backed AES-256 Encryption Service
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Provider for encrypted AppDatabase singleton
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  final db = AppDatabase(encryptionService: encryptionService);
  ref.onDispose(() {
    db.close();
  });
  return db;
});

