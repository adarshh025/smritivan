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
import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/ner_localization_config.dart';
import '../../auth_profile/domain/user_model.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../auth_profile/presentation/edit_patient_profile_view.dart';
import '../../auth_profile/presentation/manage_caregivers_view.dart';
import '../../caregiver/presentation/caregiver_auth_view.dart';
import '../../health_worker/presentation/health_worker_auth_view.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptic/haptic_service.dart';
import '../../home/application/elder_home_provider.dart';
import '../../about/presentation/about_view.dart';
import '../../../shared/widgets/app_card.dart';

class PatientSettingsView extends ConsumerWidget {
  const PatientSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(activeUserProvider);
    final user = userState.value ?? const UserModel(
      id: 'patient_ner_001',
      name: 'Bhaben Bora (ভবেন বৰা)',
      nativeLanguage: 'as',
      state: 'Assam',
      dementiaStage: 'Early-Stage (Mild Cognitive Impairment)',
      soundEffectsEnabled: true,
      voiceGuidanceEnabled: true,
      hapticFeedbackEnabled: true,
      notificationsEnabled: true,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      hlcTimestamp: '',
    );

    final currentStateInfo = NerLocalizationConfig.getStateByNameOrId(user.state);
    final currentLangInfo = NerLocalizationConfig.getLanguageCapability(user.nativeLanguage);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: AppColors.deepSageGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Regional Targeting (NER)"),
          _buildListTile(
            context,
            icon: Icons.location_on,
            title: "North Eastern State",
            subtitle: "${currentStateInfo.icon} ${currentStateInfo.name} (${currentStateInfo.nativeName})",
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => _StatePickerSheet(
                  currentState: user.state,
                  onSelect: (stateName) async {
                    final matchingState = NerLocalizationConfig.getStateByNameOrId(stateName);
                    final updated = user.copyWith(state: stateName);
                    await ref.read(activeUserProvider.notifier).updateUser(updated);
                    // Also auto-switch language if user wants primary state language
                    if (user.nativeLanguage == 'en' || user.nativeLanguage == 'as') {
                      ref.read(localeProvider.notifier).setLocale(matchingState.primaryLanguageCode);
                    }
                    ref.read(elderHomeProvider.notifier).loadData();
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.language,
            title: "Language",
            subtitle: "${currentLangInfo.flag} ${currentLangInfo.name} (${currentLangInfo.nativeName})",
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => _LanguagePickerSheet(
                  currentCode: user.nativeLanguage,
                  onSelect: (code) async {
                    await ref.read(localeProvider.notifier).setLocale(code);
                    final updated = user.copyWith(nativeLanguage: code);
                    await ref.read(activeUserProvider.notifier).updateUser(updated);
                    ref.read(elderHomeProvider.notifier).loadData();
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Account & Caregiver Access"),
          _buildListTile(
            context,
            icon: Icons.person,
            title: "My Profile",
            subtitle: user.name,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditPatientProfileView()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.people,
            title: "Caregiver Access",
            subtitle: "Manage connected family & caregivers",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageCaregiversView()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: "Caregiver PIN",
            subtitle: "Set or change Caregiver Mode PIN",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CaregiverAuthView(isResetMode: true)),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.medical_services_outlined,
            title: "Health Worker Space",
            subtitle: "Community health worker & clinical surveillance portal",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HealthWorkerAuthView()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.pin_outlined,
            title: "Health Worker PIN",
            subtitle: "Set or change Healthcare Professional PIN",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HealthWorkerAuthView(isResetMode: true)),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Accessibility & Audio Guidance"),
          _buildToggleTile(
            context,
            icon: Icons.music_note,
            title: "Sound Effects",
            value: user.soundEffectsEnabled,
            onChanged: (val) async {
              final updated = user.copyWith(soundEffectsEnabled: val);
              await ref.read(activeUserProvider.notifier).updateUser(updated);
              ref.read(elderHomeProvider.notifier).loadData();
              if (val) {
                ref.read(audioServiceProvider).playGentleSuccessChime();
              }
            },
          ),
          _buildToggleTile(
            context,
            icon: Icons.record_voice_over,
            title: "Voice Guidance",
            value: user.voiceGuidanceEnabled,
            onChanged: (val) async {
              final updated = user.copyWith(voiceGuidanceEnabled: val);
              await ref.read(activeUserProvider.notifier).updateUser(updated);
              ref.read(elderHomeProvider.notifier).loadData();
              if (val) {
                ref.read(audioServiceProvider).speakInstruction("Voice guidance enabled in ${currentLangInfo.name}");
              }
            },
          ),
          _buildToggleTile(
            context,
            icon: Icons.vibration,
            title: "Haptic Feedback",
            value: user.hapticFeedbackEnabled,
            onChanged: (val) async {
              final updated = user.copyWith(hapticFeedbackEnabled: val);
              await ref.read(activeUserProvider.notifier).updateUser(updated);
              if (val) {
                ref.read(hapticServiceProvider).success();
              }
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("System & Details"),
          _buildToggleTile(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            value: user.notificationsEnabled,
            onChanged: (val) async {
              final updated = user.copyWith(notificationsEnabled: val);
              await ref.read(activeUserProvider.notifier).updateUser(updated);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.info,
            title: "Version & Details",
            subtitle: "1.0.0 (SIH 2026 Problem Statement ID: 26003)",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutView()),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF52796F),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        borderColor: Colors.grey.shade300,
        onTap: onTap,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF264653).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF264653), size: 24),
          ),
          title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46))),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black87)) : null,
          trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, {required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        borderColor: Colors.grey.shade300,
        child: SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF264653).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF264653), size: 24),
          ),
          title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46))),
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2A9D8F),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
      ),
    );
  }
}

class _StatePickerSheet extends StatelessWidget {
  final String currentState;
  final void Function(String) onSelect;

  const _StatePickerSheet({required this.currentState, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select North Eastern State',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Covers all 8 states of the North Eastern Region of India',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: NerLocalizationConfig.allStates.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = NerLocalizationConfig.allStates[index];
                  final isSelected = currentState.toLowerCase() == s.name.toLowerCase();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    leading: Text(s.icon, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      "${s.name} (${s.nativeName})",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF2A9D8F) : const Color(0xFF2F3E46),
                      ),
                    ),
                    subtitle: Text("${s.capital} • ${s.culturalTagline}", style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF2A9D8F)) : null,
                    onTap: () => onSelect(s.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  final String currentCode;
  final void Function(String) onSelect;

  const _LanguagePickerSheet({required this.currentCode, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Spoken Language',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Powers UI localization, cognitive games, and voice guidance',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: NerLocalizationConfig.languages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lang = NerLocalizationConfig.languages[index];
                  final isSelected = currentCode.toLowerCase() == lang.code.toLowerCase();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    leading: Text(lang.flag, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      "${lang.nativeName} (${lang.name})",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF2A9D8F) : const Color(0xFF2F3E46),
                      ),
                    ),
                    subtitle: Text(lang.statusDescription, style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF2A9D8F)) : null,
                    onTap: () => onSelect(lang.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
