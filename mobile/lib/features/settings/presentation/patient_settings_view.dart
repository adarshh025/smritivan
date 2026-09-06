// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../auth_profile/domain/user_model.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../auth_profile/presentation/edit_patient_profile_view.dart';
import '../../auth_profile/presentation/manage_caregivers_view.dart';
import '../../caregiver/presentation/caregiver_auth_view.dart';
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
      name: 'Bhaben Bora',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
                _buildSectionHeader("Account"),
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
                  subtitle: "Manage connected caregivers",
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
                const SizedBox(height: 24),
                _buildSectionHeader("Accessibility & Feedback"),
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
                    if (val) {
                      ref.read(audioServiceProvider).speakInstruction("Voice guidance enabled");
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
                _buildSectionHeader("Preferences"),
                _buildListTile(
                  context,
                  icon: Icons.language,
                  title: "Language",
                  subtitle: user.nativeLanguage.toUpperCase(),
                  onTap: () {
                    // Show language selection bottom sheet
                    final localeRef = ref;
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _LanguagePickerSheet(
                        currentCode: user.nativeLanguage,
                        onSelect: (code) {
                          localeRef.read(localeProvider.notifier).setLocale(code);
                          final updated = user.copyWith(nativeLanguage: code);
                          localeRef.read(activeUserProvider.notifier).updateUser(updated);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                _buildToggleTile(
                  context,
                  icon: Icons.notifications,
                  title: "Notifications",
                  value: user.notificationsEnabled,
                  onChanged: (val) {
                    final updated = user.copyWith(notificationsEnabled: val);
                    ref.read(activeUserProvider.notifier).updateUser(updated);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("About"),
                _buildListTile(
                  context,
                  icon: Icons.info,
                  title: "Version & Details",
                  subtitle: "1.0.0 (SIH 2026 Problem ID: 26003)",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutView()),
                    );
                  },
                ),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        borderColor: Colors.grey.shade300,
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF264653), size: 28),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 14)) : null,
          trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, {required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        borderColor: Colors.grey.shade300,
        child: SwitchListTile(
          secondary: Icon(icon, color: const Color(0xFF264653), size: 28),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFE76F51),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  final String currentCode;
  final void Function(String) onSelect;

  const _LanguagePickerSheet({required this.currentCode, required this.onSelect});

  static const _langs = [
    ('en', '🇬🇧', 'English'),
    ('hi', '🇮🇳', 'हिन्दी — Hindi'),
    ('as', '🇮🇳', 'অসমীয়া — Assamese'),
    ('bn', '🇮🇳', 'বাংলা — Bengali'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Language', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          for (final (code, flag, name) in _langs)
            ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 28)),
              title: Text(name, style: const TextStyle(fontSize: 20)),
              trailing: currentCode == code ? const Icon(Icons.check, color: Color(0xFF52796F)) : null,
              onTap: () => onSelect(code),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
