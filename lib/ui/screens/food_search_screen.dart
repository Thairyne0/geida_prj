import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../models/custom_meal.dart';
import '../../services/openfoodfacts_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/fade_edge_scroll.dart';
import '../widgets/food_item_tile.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_card.dart';
import 'barcode_scan_screen.dart';
import 'create_meal_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchController = TextEditingController();
  final _service = OpenFoodFactsService();
  List<FoodItem> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _service.searchProducts(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          if (results.isEmpty) {
            _errorMessage = 'Nessun risultato per "$query"';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Errore di rete. Riprova.';
        });
      }
    }
  }

  void _showAddDialog(FoodItem item) {
    final gramsController = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'AGGIUNGI',
          style: GoogleFonts.pressStart2p(fontSize: 10),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: GoogleFonts.vt323(fontSize: 22, color: AppColors.warmBlack),
            ),
            if (item.brand.isNotEmpty)
              Text(
                item.brand,
                style: GoogleFonts.vt323(fontSize: 18, color: AppColors.textTertiary),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '${item.kcalPer100g.toStringAsFixed(0)} kcal / 100g',
                style: GoogleFonts.pressStart2p(fontSize: 7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quantità (grammi):',
              style: GoogleFonts.vt323(fontSize: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: gramsController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.pressStart2p(fontSize: 14),
              decoration: const InputDecoration(
                suffixText: 'g',
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: gramsController,
              builder: (context2, value, child2) {
                final grams = double.tryParse(value.text) ?? 0;
                final kcal = (item.kcalPer100g * grams) / 100;
                return Text(
                  'Totale: ${kcal.toStringAsFixed(0)} kcal',
                  style: GoogleFonts.vt323(
                    fontSize: 22,
                    color: AppColors.warmBlack,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ANNULLA',
              style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textTertiary),
            ),
          ),
          GestureDetector(
            onTap: () {
              final grams = double.tryParse(gramsController.text) ?? 100;
              context.read<AppState>().addEntry(item, grams);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.warmBlack,
                  content: Text(
                    '${item.name} aggiunto!',
                    style: GoogleFonts.vt323(fontSize: 20, color: AppColors.offWhite),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.warmBlack, width: 2),
              ),
              child: Text(
                'AGGIUNGI',
                style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.warmBlack),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    if (result != null && mounted) {
      _showAddDialog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'CERCA CIBO',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: AppColors.warmBlack,
                  ),
                ),
              ],
            ),
          ),
          // Search bar + barcode button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _performSearch,
                    textInputAction: TextInputAction.search,
                    style: GoogleFonts.vt323(fontSize: 22),
                    decoration: InputDecoration(
                      hintText: 'Cerca un prodotto...',
                      hintStyle: GoogleFonts.vt323(
                        fontSize: 22,
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _results = [];
                                  _errorMessage = null;
                                });
                              },
                              child: const Icon(Icons.close,
                                  size: 18, color: AppColors.textTertiary),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _scanBarcode,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warmBlack, width: 2),
                      boxShadow: AppShadows.buttonShadow,
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppColors.warmBlack),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Results
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.accentGreen,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ricerca in corso...',
                          style: GoogleFonts.vt323(
                            fontSize: 20,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _results.isNotEmpty
                    ? FadeEdgeScrollWrapper(
                        fadeHeight: 28,
                        child: ListView.builder(
                          itemCount: _results.length,
                          padding: const EdgeInsets.only(bottom: 100),
                          itemBuilder: (context, index) {
                            return FoodItemTile(
                              foodItem: _results[index],
                              onTap: () => _showAddDialog(_results[index]),
                            );
                          },
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        // Errore o nessun risultato
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _errorMessage != null
                                      ? Icons.wifi_off_rounded
                                      : Icons.search_off,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage ??
                                      'Nessun risultato per "${_searchController.text}"',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.vt323(
                                    fontSize: 22,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 20),
                                  RetroButton(
                                    label: 'RIPROVA',
                                    icon: Icons.refresh,
                                    isAccent: true,
                                    onPressed: () =>
                                        _performSearch(_searchController.text),
                                  ),
                                ],
                              ],
                            ),
                          )
                        // Stato iniziale: mostra piatti salvati + azioni
                        : _buildHomeContent(),
          ),
         ],
       ),
     ),
    );
  }

  Widget _buildHomeContent() {
    final meals = context.watch<AppState>().customMeals;

    return FadeEdgeScrollWrapper(
      fadeHeight: 24,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const SizedBox(height: 8),
          // Azioni rapide
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _scanBarcode,
                    child: RetroCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_scanner,
                              size: 28, color: AppColors.warmBlack),
                          const SizedBox(height: 8),
                          Text('SCANSIONA',
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 7, color: AppColors.warmBlack)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openCreateMeal(),
                    child: RetroCard(
                      highlighted: true,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant_menu,
                              size: 28, color: AppColors.warmBlack),
                          const SizedBox(height: 8),
                          Text('CREA PIATTO',
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 7, color: AppColors.warmBlack)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sezione piatti salvati
          if (meals.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('I MIEI PIATTI',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 9, color: AppColors.warmBlack)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: Text('${meals.length}',
                        style: GoogleFonts.pressStart2p(
                            fontSize: 7, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...meals.map((meal) => _SavedMealTile(
                  meal: meal,
                  onTap: () => _quickAddMeal(meal),
                  onEdit: () => _openCreateMeal(existing: meal),
                  onDelete: () => _deleteMeal(meal),
                )),
          ] else ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Cerca un prodotto alimentare\no crea un piatto personalizzato',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(
                    fontSize: 20, color: AppColors.textTertiary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openCreateMeal({CustomMeal? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMealScreen(existingMeal: existing),
      ),
    );
    if (result == true && mounted) {
      setState(() {}); // Refresh
    }
  }

  void _quickAddMeal(CustomMeal meal) {
    context.read<AppState>().addCustomMealEntry(meal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.warmBlack,
        content: Text(
          '${meal.name} aggiunto al diario! (${meal.totalKcal.toStringAsFixed(0)} kcal)',
          style: GoogleFonts.vt323(fontSize: 20, color: AppColors.offWhite),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteMeal(CustomMeal meal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('ELIMINA', style: GoogleFonts.pressStart2p(fontSize: 10)),
        content: Text(
          'Eliminare "${meal.name}"?',
          style: GoogleFonts.vt323(fontSize: 22, color: AppColors.warmBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ANNULLA',
                style: GoogleFonts.pressStart2p(
                    fontSize: 8, color: AppColors.textTertiary)),
          ),
          GestureDetector(
            onTap: () {
              context.read<AppState>().removeCustomMeal(meal.id);
              Navigator.pop(ctx);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.red.shade400, width: 2),
              ),
              child: Text('ELIMINA',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 8, color: Colors.red.shade400)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Tile per un piatto salvato
// ─────────────────────────────────────────────────────────────────────

class _SavedMealTile extends StatelessWidget {
  final CustomMeal meal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavedMealTile({
    required this.meal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RetroCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icona piatto
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: const Icon(Icons.restaurant_menu,
                  size: 20, color: AppColors.warmBlack),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vt323(
                        fontSize: 20, color: AppColors.warmBlack),
                  ),
                  Text(
                    '${meal.ingredients.length} ingredienti · ${meal.totalGrams.toStringAsFixed(0)}g',
                    style: GoogleFonts.vt323(
                        fontSize: 16, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            // Kcal badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '${meal.totalKcal.toStringAsFixed(0)} kcal',
                style: GoogleFonts.pressStart2p(
                    fontSize: 7, color: AppColors.warmBlack),
              ),
            ),
            const SizedBox(width: 4),
            // Menu azioni
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'add') onTap();
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              icon: const Icon(Icons.more_vert,
                  size: 18, color: AppColors.textTertiary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: AppColors.cardWhite,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 18, color: AppColors.warmBlack),
                      const SizedBox(width: 8),
                      Text('Aggiungi al diario',
                          style: GoogleFonts.vt323(fontSize: 18)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.warmBlack),
                      const SizedBox(width: 8),
                      Text('Modifica', style: GoogleFonts.vt323(fontSize: 18)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Text('Elimina',
                          style: GoogleFonts.vt323(
                              fontSize: 18, color: Colors.red.shade400)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



