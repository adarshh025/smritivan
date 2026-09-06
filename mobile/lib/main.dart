// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SmritivanApp()));
}

class SmritivanApp extends ConsumerWidget {
  const SmritivanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Smritivan',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('as'),
        Locale('bn'),
        Locale('ne'),
      ],
    );
  }
}
