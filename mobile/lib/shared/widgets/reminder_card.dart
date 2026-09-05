import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'app_card.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color themeColor;
  final bool isDone;
  final VoidCallback onMarkDone;
  final String doneLabel;
  final String markDoneLabel;

  const ReminderCard({
    Key? key,
    required this.title,
    required this.time,
    required this.icon,
    required this.themeColor,
    required this.isDone,
    required this.onMarkDone,
    required this.doneLabel,
    required this.markDoneLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderColor: isDone ? AppColors.paleParchment : themeColor.withAlpha(128),
      backgroundColor: isDone ? AppColors.softCream : Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 300;
          
          Widget statusWidget = isDone
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, color: AppColors.successSage, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      doneLabel,
                      style: AppTypography.buttonLabel.copyWith(color: AppColors.successSage),
                    ),
                  ],
                )
              : SizedBox(
                  width: isNarrow ? double.infinity : null,
                  child: ElevatedButton(
                    onPressed: onMarkDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      markDoneLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.paleParchment : themeColor.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: isDone ? AppColors.textMuted : themeColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDone ? AppColors.textMuted : AppColors.textCharcoal,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                statusWidget,
              ],
            );
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.paleParchment : themeColor.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isDone ? AppColors.textMuted : themeColor, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDone ? AppColors.textMuted : AppColors.textCharcoal,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      time,
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              statusWidget,
            ],
          );
        },
      ),
    );
  }
}
