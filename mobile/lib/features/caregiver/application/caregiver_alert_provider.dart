// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../data/caregiver_alert_repository.dart';
import '../domain/caregiver_alert.dart';

class CaregiverAlertState {
  final List<CaregiverAlert> alerts;
  final bool isLoading;

  const CaregiverAlertState({
    required this.alerts,
    this.isLoading = false,
  });
}

class CaregiverAlertNotifier extends StateNotifier<CaregiverAlertState> {
  final Ref _ref;

  CaregiverAlertNotifier(this._ref) : super(const CaregiverAlertState(alerts: [], isLoading: true)) {
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    final user = _ref.read(activeUserProvider).value;
    if (user == null || user.caregiverId == null) {
      state = const CaregiverAlertState(alerts: [], isLoading: false);
      return; // Not logged in or not a patient with a caregiver
    }

    state = CaregiverAlertState(alerts: state.alerts, isLoading: true);
    
    final repo = _ref.read(caregiverAlertRepositoryProvider);
    try {
      final alerts = await repo.getAlerts(user.id);
      if (mounted) {
        state = CaregiverAlertState(alerts: alerts, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = CaregiverAlertState(alerts: state.alerts, isLoading: false);
      }
    }
  }

  Future<void> dismissAlert(String alertId) async {
    final repo = _ref.read(caregiverAlertRepositoryProvider);
    await repo.updateAlertStatus(alertId, AlertStatus.dismissed);
    await loadAlerts();
  }
}

final caregiverAlertsProvider = StateNotifierProvider<CaregiverAlertNotifier, CaregiverAlertState>((ref) {
  return CaregiverAlertNotifier(ref);
});
