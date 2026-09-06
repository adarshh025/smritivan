// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../games/presentation/game_telemetry_provider.dart';
import '../../reminders/application/reminder_service.dart';
import '../../wellbeing/data/wellbeing_repository.dart';
import '../../games/core/game_progression_service.dart';
import '../../auth_profile/domain/user_model.dart';
import '../domain/health_worker_model.dart';
import '../data/health_worker_repository.dart';

/// Provider for HealthWorkerRepository singleton
final healthWorkerRepositoryProvider = Provider<HealthWorkerRepository>((ref) {
  return HealthWorkerRepository(
    userRepo: ref.watch(userRepositoryProvider),
    gameSessionRepo: ref.watch(gameSessionRepositoryProvider),
    reminderRepo: ref.watch(reminderRepositoryProvider),
    wellbeingRepo: ref.watch(wellbeingRepositoryProvider),
    progressionService: ref.watch(gameProgressionProvider),
  );
});

/// Auth State for Health Worker / Healthcare Professional Space
class HealthWorkerAuthState {
  final bool isAuthorized;
  final HealthWorkerProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const HealthWorkerAuthState({
    this.isAuthorized = false,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  HealthWorkerAuthState copyWith({
    bool? isAuthorized,
    HealthWorkerProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HealthWorkerAuthState(
      isAuthorized: isAuthorized ?? this.isAuthorized,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HealthWorkerAuthNotifier extends StateNotifier<HealthWorkerAuthState> {
  final HealthWorkerRepository _repo;

  HealthWorkerAuthNotifier(this._repo) : super(const HealthWorkerAuthState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true);
    final prof = await _repo.getProfile();
    state = state.copyWith(profile: prof, isLoading: false);
  }

  Future<bool> authenticate(String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final isValid = await _repo.verifyPin(pin);
    if (isValid) {
      final prof = await _repo.getProfile();
      state = state.copyWith(isAuthorized: true, profile: prof, isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isAuthorized: false,
        isLoading: false,
        errorMessage: 'Invalid Health Worker PIN. Please try again.',
      );
      return false;
    }
  }

  Future<void> updatePin(String newPin) async {
    await _repo.setPin(newPin);
  }

  Future<void> updateProfile(HealthWorkerProfile updated) async {
    await _repo.saveProfile(updated);
    state = state.copyWith(profile: updated);
  }

  void logout() {
    state = state.copyWith(isAuthorized: false, errorMessage: null);
  }
}

final healthWorkerAuthProvider = StateNotifierProvider<HealthWorkerAuthNotifier, HealthWorkerAuthState>((ref) {
  final repo = ref.watch(healthWorkerRepositoryProvider);
  return HealthWorkerAuthNotifier(repo);
});

/// State for Multi-Patient Monitoring List
class HealthWorkerPatientsState {
  final List<UserModel> allPatients;
  final String searchQuery;
  final String stateFilter; // 'All' or specific NER state
  final bool isLoading;

  const HealthWorkerPatientsState({
    this.allPatients = const [],
    this.searchQuery = '',
    this.stateFilter = 'All',
    this.isLoading = false,
  });

  List<UserModel> get filteredPatients {
    return allPatients.where((p) {
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.id.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesState = stateFilter == 'All' || p.state == stateFilter;
      return matchesSearch && matchesState;
    }).toList();
  }

  HealthWorkerPatientsState copyWith({
    List<UserModel>? allPatients,
    String? searchQuery,
    String? stateFilter,
    bool? isLoading,
  }) {
    return HealthWorkerPatientsState(
      allPatients: allPatients ?? this.allPatients,
      searchQuery: searchQuery ?? this.searchQuery,
      stateFilter: stateFilter ?? this.stateFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HealthWorkerPatientsNotifier extends StateNotifier<HealthWorkerPatientsState> {
  final HealthWorkerRepository _repo;

  HealthWorkerPatientsNotifier(this._repo) : super(const HealthWorkerPatientsState()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true);
    final patients = await _repo.getAllPatients();
    state = state.copyWith(allPatients: patients, isLoading: false);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStateFilter(String stateName) {
    state = state.copyWith(stateFilter: stateName);
  }
}

final healthWorkerPatientsProvider = StateNotifierProvider<HealthWorkerPatientsNotifier, HealthWorkerPatientsState>((ref) {
  final repo = ref.watch(healthWorkerRepositoryProvider);
  return HealthWorkerPatientsNotifier(repo);
});

/// Provider for selected Patient Clinical & Longitudinal Summary
final patientClinicalDetailProvider = FutureProvider.family<PatientClinicalSummary, String>((ref, patientId) async {
  final repo = ref.watch(healthWorkerRepositoryProvider);
  return await repo.getPatientClinicalSummary(patientId);
});
