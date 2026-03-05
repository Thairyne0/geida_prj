import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RetroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool highlighted;

  const RetroCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.accentGreen.withValues(alpha: 0.2)
            : (backgroundColor ?? AppColors.cardWhite),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? AppColors.accentGreen : AppColors.subtleBorder,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: child,
    );
  }
}

