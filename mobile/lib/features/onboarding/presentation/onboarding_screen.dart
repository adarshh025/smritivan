// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_button.dart';
import '../../home/presentation/elder_home_view.dart';
import '../../caregiver/presentation/caregiver_auth_view.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  void _nextPage() {
    if (_currentPage < 2) { 
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Last page reached, go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ElderHomeView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
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
            _buildWelcomePage(l10n!),
            _buildLanguagePage(l10n),
            _buildRegionPage(l10n), 
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 100, color: Color(0xFF84A98C)),
          const SizedBox(height: 40),
          Text(
            l10n.welcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 60),
          AppButton(text: l10n.startBtn, onPressed: _nextPage),
          const SizedBox(height: 16),
          AppButton.secondary(
            text: l10n.caregiverSetupBtn, 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverAuthView()));
            }, 
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.languageQuestion,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          AppButton(text: l10n.english, onPressed: () {
            ref.read(localeProvider.notifier).setLocale('en');
            _nextPage();
          }),
          const SizedBox(height: 16),
          AppButton(text: l10n.hindi, onPressed: () {
            ref.read(localeProvider.notifier).setLocale('hi');
            _nextPage();
          }),
          const SizedBox(height: 16),
          AppButton(text: l10n.assamese, onPressed: () {
            ref.read(localeProvider.notifier).setLocale('as');
            _nextPage();
          }),
          const SizedBox(height: 16),
          AppButton(text: l10n.bengali, onPressed: () {
            ref.read(localeProvider.notifier).setLocale('bn');
            _nextPage();
          }),
        ],
      ),
    );
  }

  Widget _buildRegionPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.regionQuestion,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          AppButton(text: "Assam", onPressed: _nextPage),
          const SizedBox(height: 16),
          AppButton(text: "Nagaland", onPressed: _nextPage),
          const SizedBox(height: 16),
          AppButton(text: "Meghalaya", onPressed: _nextPage),
        ],
      ),
    );
  }
}
