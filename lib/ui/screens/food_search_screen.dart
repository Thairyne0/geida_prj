import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../services/openfoodfacts_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/food_item_tile.dart';
import '../widgets/retro_button.dart';
import 'barcode_scan_screen.dart';

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
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await _service.searchFood(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
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
    return SafeArea(
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
                    style: GoogleFonts.vt323(fontSize: 22),
                    decoration: InputDecoration(
                      hintText: 'Cerca un prodotto...',
                      hintStyle: GoogleFonts.vt323(
                        fontSize: 22,
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
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
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Cerca un prodotto alimentare\no scansiona un codice a barre'
                                  : 'Nessun risultato trovato',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.vt323(
                                fontSize: 22,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 24),
                              RetroButton(
                                label: 'SCANSIONA BARCODE',
                                icon: Icons.qr_code_scanner,
                                isAccent: true,
                                onPressed: _scanBarcode,
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        padding: const EdgeInsets.only(bottom: 100),
                        itemBuilder: (context, index) {
                          return FoodItemTile(
                            foodItem: _results[index],
                            onTap: () => _showAddDialog(_results[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}



