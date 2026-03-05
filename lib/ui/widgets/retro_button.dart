import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RetroButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isAccent;
  final IconData? icon;
  final bool isSmall;

  const RetroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isAccent = false,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 14 : 24,
          vertical: isSmall ? 8 : 14,
        ),
        decoration: BoxDecoration(
          color: isAccent ? AppColors.accentGreen : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.warmBlack, width: 2),
          boxShadow: AppShadows.buttonShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: isSmall ? 14 : 18, color: AppColors.warmBlack),
              SizedBox(width: isSmall ? 6 : 10),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: isSmall ? 8 : 10,
                color: AppColors.warmBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

