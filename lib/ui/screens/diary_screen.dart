import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/fade_edge_scroll.dart';
import '../widgets/food_item_tile.dart';
import '../widgets/retro_card.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final dates = state.datesWithEntries;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'DIARIO',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${state.allEntries.length} TOTALI',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: AppColors.warmBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Lista giorni
              Expanded(
                child: dates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun pasto registrato',
                              style: GoogleFonts.vt323(
                                fontSize: 22,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : FadeEdgeScrollWrapper(
                        fadeHeight: 28,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: dates.length,
                          itemBuilder: (context, index) {
                            final date = dates[index];
                            return _DaySection(date: date);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sezione per un singolo giorno: header con data + kcal totali,
/// poi elenco dei cibi.
class _DaySection extends StatefulWidget {
  final DateTime date;

  const _DaySection({required this.date});

  @override
  State<_DaySection> createState() => _DaySectionState();
}

class _DaySectionState extends State<_DaySection> {
  bool _expanded = false;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isYesterday(DateTime d) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;
  }

  String _dateLabel(DateTime d) {
    if (_isToday(d)) return 'OGGI';
    if (_isYesterday(d)) return 'IERI';
    return DateFormat('dd MMM yyyy').format(d).toUpperCase();
  }

  String _weekday(DateTime d) {
    const days = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM'];
    return days[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = state.entriesForDate(widget.date);
    final totalKcal = entries.fold(0.0, (s, e) => s + e.totalKcal);
    final totalProtein = entries.fold(0.0, (s, e) => s + e.totalProtein);
    final totalCarbs = entries.fold(0.0, (s, e) => s + e.totalCarbs);
    final totalFat = entries.fold(0.0, (s, e) => s + e.totalFat);
    final goal = state.profile?.dailyKcalGoal ?? 2000;
    final isOver = totalKcal > goal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: RetroCard(
        highlighted: _isToday(widget.date),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header — tap per espandere/chiudere
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Giorno della settimana badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isToday(widget.date)
                            ? AppColors.accentGreen.withValues(alpha: 0.4)
                            : AppColors.offWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isToday(widget.date)
                              ? AppColors.warmBlack
                              : AppColors.subtleBorder,
                          width: _isToday(widget.date) ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _weekday(widget.date),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: AppColors.warmBlack,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Data + conteggio
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dateLabel(widget.date),
                            style: GoogleFonts.pressStart2p(
                              fontSize: 8,
                              color: AppColors.warmBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entries.length} ${entries.length == 1 ? 'alimento' : 'alimenti'}',
                            style: GoogleFonts.vt323(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Kcal totali del giorno
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOver
                            ? Colors.red.shade50
                            : AppColors.accentGreen.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${totalKcal.toStringAsFixed(0)} KCAL',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color:
                              isOver ? Colors.red.shade400 : AppColors.warmBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Contenuto espanso
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  // Mini macros row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _MiniMacro(label: 'PROT', value: totalProtein),
                        const SizedBox(width: 8),
                        _MiniMacro(label: 'CARB', value: totalCarbs),
                        const SizedBox(width: 8),
                        _MiniMacro(label: 'GRAS', value: totalFat),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                      height: 1, color: AppColors.subtleBorder, indent: 16, endIndent: 16),
                  // Lista cibi
                  ...entries.map((entry) => FoodItemTile(
                        foodItem: entry.foodItem,
                        loggedGrams: entry.grams,
                        loggedKcal: entry.totalKcal,
                        onTap: () {},
                        onDelete: () => state.removeEntryGlobal(entry),
                      )),
                  const SizedBox(height: 8),
                ],
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final double value;

  const _MiniMacro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 5,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${value.toStringAsFixed(0)}g',
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: AppColors.warmBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

