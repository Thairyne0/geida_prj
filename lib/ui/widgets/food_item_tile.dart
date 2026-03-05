import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/food_item.dart';
import '../../theme/app_theme.dart';

class FoodItemTile extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;
  final double? loggedGrams;
  final double? loggedKcal;
  final VoidCallback? onDelete;

  const FoodItemTile({
    super.key,
    required this.foodItem,
    required this.onTap,
    this.loggedGrams,
    this.loggedKcal,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.subtleBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food image or placeholder
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: foodItem.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        foodItem.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.fastfood, size: 20, color: AppColors.textTertiary),
                      ),
                    )
                  : const Icon(Icons.fastfood, size: 20, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vt323(
                      fontSize: 20,
                      color: AppColors.warmBlack,
                    ),
                  ),
                  if (foodItem.brand.isNotEmpty)
                    Text(
                      foodItem.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  if (loggedGrams != null)
                    Text(
                      '${loggedGrams!.toStringAsFixed(0)}g',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            // Kcal badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                loggedKcal != null
                    ? '${loggedKcal!.toStringAsFixed(0)} kcal'
                    : '${foodItem.kcalPer100g.toStringAsFixed(0)}/100g',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: AppColors.warmBlack,
                ),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 18, color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



