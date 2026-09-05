import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  static BorderRadius get _defaultRadius => BorderRadius.circular(AppDimensions.radiusMD);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Extract borderRadius safely
    BorderRadius radius = _defaultRadius;
    if (theme.cardTheme.shape is RoundedRectangleBorder) {
      final br = (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius;
      if (br is BorderRadius) radius = br;
    }

    Widget cardContent = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: cardContent,
      );
    }

    return Card(
      color: backgroundColor ?? theme.cardTheme.color ?? Colors.white,
      shape: borderColor != null
          ? RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: borderColor!, width: 2),
            )
          : theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: radius),
      child: cardContent,
    );
  }
}

