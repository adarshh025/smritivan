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
import '../domain/personalization_models.dart';
import 'personalization_service.dart';

/// Provides the core PersonalizationService initialized with required repositories
final personalizationServiceProvider = Provider<PersonalizationService>((ref) {
  final gameRepo = ref.watch(gameSessionRepositoryProvider);
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final wellbeingRepo = ref.watch(wellbeingRepositoryProvider);
  
  return PersonalizationService(gameRepo, reminderRepo, wellbeingRepo);
});

/// A combined state for the UI to consume easily
class PersonalizationState {
  final PatientActivityProfile profile;
  final PersonalizationRecommendation recommendation;
  final bool isLoading;

  const PersonalizationState({
    required this.profile,
    required this.recommendation,
    this.isLoading = false,
  });
}

class PersonalizationNotifier extends StateNotifier<PersonalizationState> {
  final Ref _ref;

  PersonalizationNotifier(this._ref)
      : super(PersonalizationState(
          profile: PatientActivityProfile.empty(),
          recommendation: const PersonalizationRecommendation(
            recommendedGameType: 'memory_match',
            recommendedLevel: 1.0,
            reason: 'Loading...',
            estimatedMinutes: 5,
            isColdStart: true,
          ),
          isLoading: true,
        )) {
    loadPersonalization();
  }

  Future<void> loadPersonalization() async {
    final user = _ref.read(activeUserProvider).value;
    if (user == null) {
      state = PersonalizationState(
        profile: PatientActivityProfile.empty(),
        recommendation: state.recommendation,
        isLoading: false,
      );
      return;
    }

    final service = _ref.read(personalizationServiceProvider);
    
    try {
      var profile = await service.derivePatientActivityProfile(user.id);
      
      // Override inferred activity time with explicit user preference if set
      if (user.preferredActivityTime != null && user.preferredActivityTime!.isNotEmpty) {
        profile = profile.copyWith(preferredActivityTime: user.preferredActivityTime!);
      }

      final recommendation = await service.getRecommendedActivity(user.id);

      if (mounted) {
        state = PersonalizationState(
          profile: profile,
          recommendation: recommendation,
          isLoading: false,
        );
      }
    } catch (e) {
      // Fallback in case of errors
      if (mounted) {
        state = PersonalizationState(
          profile: PatientActivityProfile.empty(),
          recommendation: state.recommendation,
          isLoading: false,
        );
      }
    }
  }
}

/// The main provider the UI widgets should listen to
final personalizationStateProvider = StateNotifierProvider<PersonalizationNotifier, PersonalizationState>((ref) {
  final notifier = PersonalizationNotifier(ref);
  
  ref.listen(activeUserProvider, (previous, next) {
    if (next.value?.id != previous?.value?.id || (!next.isLoading && previous?.isLoading == true)) {
      notifier.loadPersonalization();
    }
  });

  return notifier;
});
