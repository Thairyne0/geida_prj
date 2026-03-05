import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/calorie_counter_display.dart';
import '../widgets/food_item_tile.dart';
import '../widgets/retro_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final profile = state.profile;
        final todayEntries = state.todayEntries;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'GEIDA',
                style: GoogleFonts.pressStart2p(fontSize: 14),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      DateFormat('dd MMM').format(DateTime.now()).toUpperCase(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: AppColors.warmBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // User info strip
                    if (profile != null)
                      _UserInfoStrip(profile: profile),
                    const SizedBox(height: 16),
                    // Calorie counter
                    CalorieCounterDisplay(
                      currentKcal: state.todayKcal,
                      goalKcal: profile?.dailyKcalGoal ?? 2000,
                    ),
                    const SizedBox(height: 16),
                    // Macros row
                    _MacrosRow(
                      protein: state.todayProtein,
                      carbs: state.todayCarbs,
                      fat: state.todayFat,
                    ),
                    const SizedBox(height: 24),
                    // Today's log header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DIARIO DI OGGI',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: AppColors.warmBlack,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: AppColors.subtleBorder),
                          ),
                          child: Text(
                            '${todayEntries.length} VOCI',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (todayEntries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant_menu, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        'Nessun pasto registrato oggi',
                        style: GoogleFonts.vt323(
                          fontSize: 22,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vai alla sezione CERCA per aggiungere cibi',
                        style: GoogleFonts.vt323(
                          fontSize: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = todayEntries[index];
                    return FoodItemTile(
                      foodItem: entry.foodItem,
                      loggedGrams: entry.grams,
                      loggedKcal: entry.totalKcal,
                      onTap: () {},
                      onDelete: () => state.removeEntry(index),
                    );
                  },
                  childCount: todayEntries.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

class _UserInfoStrip extends StatelessWidget {
  final dynamic profile;

  const _UserInfoStrip({required this.profile});

  @override
  Widget build(BuildContext context) {
    return RetroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warmBlack, width: 1.5),
            ),
            child: const Icon(Icons.person, size: 20, color: AppColors.warmBlack),
          ),
          const SizedBox(width: 12),
          if (profile.name.isNotEmpty) ...[
            Text(
              profile.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.warmBlack),
            ),
            const Spacer(),
          ] else
            const Spacer(),
          _InfoChip(label: '${profile.weight.toStringAsFixed(0)} KG'),
          const SizedBox(width: 8),
          _InfoChip(label: '${profile.height.toStringAsFixed(0)} CM'),
          const SizedBox(width: 8),
          _InfoChip(
            label: 'BMI ${profile.bmi.toStringAsFixed(1)}',
            highlighted: true,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _InfoChip({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.accentGreen.withValues(alpha: 0.3)
            : AppColors.offWhite,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: GoogleFonts.pressStart2p(
          fontSize: 6,
          color: AppColors.warmBlack,
        ),
      ),
    );
  }
}

class _MacrosRow extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const _MacrosRow({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroCard(label: 'PROTEINE', value: protein, unit: 'g')),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'CARBO', value: carbs, unit: 'g')),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'GRASSI', value: fat, unit: 'g')),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 6,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(0),
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: AppColors.warmBlack,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.vt323(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


