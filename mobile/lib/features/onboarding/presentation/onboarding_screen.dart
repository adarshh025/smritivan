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
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../caregiver/presentation/caregiver_auth_view.dart';
import '../../home/presentation/elder_home_view.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedState = 'Assam';
  String _selectedLanguage = 'as';

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final userState = ref.read(activeUserProvider);
    final user = userState.value;
    if (user != null) {
      final updated = user.copyWith(
        state: _selectedState,
        nativeLanguage: _selectedLanguage,
      );
      await ref.read(activeUserProvider.notifier).updateUser(updated);
    }
    await ref.read(localeProvider.notifier).setLocale(_selectedLanguage);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ElderHomeView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.warmSand,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildWelcomePage(l10n),
            _buildLanguagePage(l10n),
            _buildRegionPage(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.softSageGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Text('🧠', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 32),
          const Text(
            "Smritivan • স্মৃতিবন",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.deepSageGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.welcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.textCharcoal,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 48),
          AppButton(
            text: l10n.startBtn,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            text: l10n.caregiverSetupBtn,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaregiverAuthView()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.languageQuestion,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Select your primary spoken language for voice guidance & text",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildLanguageOption('as', 'অসমীয়া (Assamese)', '🇮🇳', 'Full Regional UI & Voice Assistance'),
                _buildLanguageOption('bn', 'বাংলা (Bengali)', '🇮🇳', 'Full Regional UI & Native TTS Voice'),
                _buildLanguageOption('hi', 'हिन्दी (Hindi)', '🇮🇳', 'Full UI & Native TTS Voice'),
                _buildLanguageOption('ne', 'नेपाली (Nepali)', '🇳🇵', 'Full UI (Sikkim / Gorkha) & Voice'),
                _buildLanguageOption('en', 'English (India)', '🇬🇧', 'Full UI & Voice Guidance'),
                _buildLanguageOption('mni', 'মৈতৈলোন্ (Manipuri)', '🇮🇳', 'Manipur Regional Support (Text Fallback)'),
                _buildLanguageOption('kha', 'Khasi / Garo', '🇮🇳', 'Meghalaya Regional Support (Text Fallback)'),
                _buildLanguageOption('mzo', 'Mizo ṭawng', '🇮🇳', 'Mizoram Regional Support (Text Fallback)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: "Continue ➔",
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale(_selectedLanguage);
              _nextPage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String title, String flag, String sub) {
    final isSelected = _selectedLanguage == code;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
        borderColor: isSelected ? AppColors.deepSageGreen : AppColors.paleParchment,
        onTap: () {
          setState(() {
            _selectedLanguage = code;
          });
          ref.read(localeProvider.notifier).setLocale(code);
        },
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.deepSageGreen : AppColors.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.deepSageGreen, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.regionQuestion,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Select your North Eastern State for localized culture and routines",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: NerLocalizationConfig.allStates.length,
              itemBuilder: (context, index) {
                final stateInfo = NerLocalizationConfig.allStates[index];
                final isSelected = _selectedState == stateInfo.name;

                return AppCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                  borderColor: isSelected ? AppColors.deepSageGreen : AppColors.paleParchment,
                  onTap: () {
                    setState(() {
                      _selectedState = stateInfo.name;
                      // Auto-recommend state's primary language if user didn't explicitly customize
                      if (_selectedLanguage == 'en' || _selectedLanguage == 'as') {
                        _selectedLanguage = stateInfo.primaryLanguageCode;
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stateInfo.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      Text(
                        stateInfo.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.deepSageGreen : AppColors.textCharcoal,
                        ),
                      ),
                      Text(
                        "${stateInfo.nativeName} • ${stateInfo.capital}",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: "Let's Begin (सुरु गरौँ) ➔",
            onPressed: _finishOnboarding,
          ),
        ],
      ),
    );
  }
}
