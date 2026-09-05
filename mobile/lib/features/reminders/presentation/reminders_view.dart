// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/reminder_service.dart';
import '../domain/reminder_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class RemindersView extends ConsumerWidget {
  const RemindersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(l10n.todaysReminders, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: remindersAsync.when(
          data: (reminders) {
            if (reminders.isEmpty) {
              return Center(
                child: Text(
                  l10n.noRemindersToday, 
                  style: const TextStyle(fontSize: 24, color: Colors.grey)
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final r = reminders[index];
                final isDone = r.status == 'done';
                return _buildElderFriendlyCard(context, ref, r, isDone, l10n);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }

  Widget _buildElderFriendlyCard(BuildContext context, WidgetRef ref, ReminderModel reminder, bool isDone, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        backgroundColor: Colors.white,
        borderColor: isDone ? Colors.grey[300]! : reminder.accentColor.withOpacity(0.5),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDone ? Colors.grey[200] : reminder.accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(reminder.icon, color: isDone ? Colors.grey : reminder.accentColor, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title, // Title comes from DB, might need localization later based on category
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.grey : const Color(0xFF2F3E46),
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                      Text(
                        reminder.description!,
                        style: TextStyle(fontSize: 18, color: isDone ? Colors.grey : Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      reminder.time,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDone ? Colors.grey : const Color(0xFF2F3E46),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              text: isDone ? l10n.done : l10n.markDone,
              icon: isDone ? Icons.check_circle : Icons.check,
              onPressed: isDone ? null : () {
                ref.read(remindersProvider.notifier).markAsDone(reminder.id);
              },
            ),
          )
        ],
      ),
    ),
  );
}
}
