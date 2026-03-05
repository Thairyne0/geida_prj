import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class CalorieCounterDisplay extends StatelessWidget {
  final double currentKcal;
  final double goalKcal;

  const CalorieCounterDisplay({
    super.key,
    required this.currentKcal,
    required this.goalKcal,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = goalKcal > 0 ? (currentKcal / goalKcal).clamp(0.0, 1.5) : 0.0;
    final remaining = (goalKcal - currentKcal).clamp(0, goalKcal);
    final isOver = currentKcal > goalKcal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOver ? Colors.red.shade300 : AppColors.subtleBorder,
          width: isOver ? 2 : 1,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'KCAL OGGI',
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentKcal.toStringAsFixed(0),
            style: GoogleFonts.pressStart2p(
              fontSize: 36,
              color: isOver ? Colors.red.shade400 : AppColors.warmBlack,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '/ ${goalKcal.toStringAsFixed(0)}',
            style: GoogleFonts.vt323(
              fontSize: 22,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: AppColors.offWhite,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? Colors.red.shade300 : AppColors.accentGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOver
                  ? Colors.red.shade50
                  : AppColors.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              isOver
                  ? '⚠ SUPERATO DI ${(currentKcal - goalKcal).toStringAsFixed(0)} KCAL'
                  : '${remaining.toStringAsFixed(0)} KCAL RIMANENTI',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: isOver ? Colors.red.shade400 : AppColors.warmBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

