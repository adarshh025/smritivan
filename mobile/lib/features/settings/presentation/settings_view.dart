import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF52796F),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.languageQuestion,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
          ),
          const SizedBox(height: 16),
          _buildLangOption(ref, "en", l10n.english, currentLocale.languageCode),
          _buildLangOption(ref, "hi", l10n.hindi, currentLocale.languageCode),
          _buildLangOption(ref, "as", l10n.assamese, currentLocale.languageCode),
          _buildLangOption(ref, "bn", l10n.bengali, currentLocale.languageCode),
        ],
      ),
    );
  }

  Widget _buildLangOption(WidgetRef ref, String code, String label, String currentCode) {
    bool isSelected = code == currentCode;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? const Color(0xFF2A9D8F) : Colors.transparent, width: 2),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 18)),
        trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF2A9D8F)) : null,
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(code);
        },
      ),
    );
  }
}
