import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';
import '../../core/haptic/haptic_service.dart';

enum AppButtonType { primary, secondary, text, destructive }

class AppButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  const AppButton.primary({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : type = AppButtonType.primary,
        super(key: key);

  const AppButton.secondary({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : type = AppButtonType.secondary,
        super(key: key);

  const AppButton.text({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : type = AppButtonType.text,
        super(key: key);

  const AppButton.destructive({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : type = AppButtonType.destructive,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: text,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTargetSize,
          minWidth: double.infinity,
        ),
        child: _buildButton(context, ref),
      ),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref) {
    VoidCallback? handlePress = onPressed == null || isLoading
        ? null
        : () {
            ref.read(hapticServiceProvider).selection();
            onPressed!();
          };

    Widget child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: type == AppButtonType.primary || type == AppButtonType.destructive
                  ? Colors.white
                  : AppColors.softSageGreen,
              strokeWidth: 3,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTypography.buttonLabel,
                textAlign: TextAlign.center,
              ),
            ],
          );

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: handlePress,
          child: child,
        );
      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: handlePress,
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: handlePress,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.deepSageGreen,
            minimumSize: const Size(AppDimensions.minTouchTargetSize, AppDimensions.minTouchTargetSize),
            padding: AppDimensions.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.buttonBorderRadius,
            ),
          ),
          child: child,
        );
      case AppButtonType.destructive:
        return ElevatedButton(
          onPressed: handlePress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warmTerracotta,
            foregroundColor: Colors.white,
            elevation: 2,
            minimumSize: const Size(AppDimensions.minTouchTargetSize, AppDimensions.minTouchTargetSize),
            padding: AppDimensions.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.buttonBorderRadius,
            ),
          ),
          child: child,
        );
    }
  }
}
