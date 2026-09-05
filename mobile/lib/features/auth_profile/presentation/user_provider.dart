// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';
import '../domain/relationship_model.dart';

/// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return UserRepository(appDb);
});

class ActiveUserState {
  final UserModel? value;
  final List<CaregiverRelationshipModel> relationships;
  final bool isLoading;

  const ActiveUserState({
    this.value,
    this.relationships = const [],
    this.isLoading = false,
  });
}

/// Current Active Patient State Provider
final activeUserProvider = StateNotifierProvider<ActiveUserNotifier, ActiveUserState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return ActiveUserNotifier(repo);
});

class ActiveUserNotifier extends StateNotifier<ActiveUserState> {
  final UserRepository _repo;

  ActiveUserNotifier(this._repo) : super(const ActiveUserState(isLoading: true)) {
    loadActiveUser();
  }

  Future<void> loadActiveUser() async {
    state = const ActiveUserState(isLoading: true);
    try {
      var user = await _repo.getActivePatient();
      if (user == null) {
        const defaultUser = UserModel(
          id: 'patient_ner_001',
          name: 'Bhaben Bora (ভবেন বৰা)',
          nativeLanguage: 'as',
          dementiaStage: 'Early-Stage (Mild Cognitive Impairment)',
          soundEffectsEnabled: true,
          voiceGuidanceEnabled: true,
          hapticFeedbackEnabled: true,
          notificationsEnabled: true,
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          hlcTimestamp: '',
        );
        await _repo.savePatient(defaultUser);
        user = defaultUser;
      }
      List<CaregiverRelationshipModel> rels = [];
      if (user != null) {
        rels = await _repo.getRelationshipsForPatient(user.id);
      }
      if (mounted) {
        state = ActiveUserState(value: user, relationships: rels, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = const ActiveUserState(isLoading: false);
      }
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _repo.savePatient(user);
    await loadActiveUser();
  }

  Future<void> revokeCaregiverAccess(String relId) async {
    // Basic MVP revocation
    final user = state.value;
    if (user != null) {
      final rels = state.relationships;
      final target = rels.firstWhere((r) => r.relId == relId);
      final updated = target.copyWith(status: RelationshipStatus.revoked);
      await _repo.saveRelationship(updated);
      await loadActiveUser();
    }
  }

  Future<void> setLanguage(String langCode) async {
    final current = state.value;
    if (current != null) {
      await _repo.updateLanguage(current.id, langCode);
      await loadActiveUser();
    }
  }
}

