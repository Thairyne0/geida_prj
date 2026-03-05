import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/custom_meal.dart';
import '../../models/food_item.dart';
import '../../services/openfoodfacts_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/retro_card.dart';

/// Schermata per creare o modificare un piatto personalizzato.
class CreateMealScreen extends StatefulWidget {
  final CustomMeal? existingMeal;

  const CreateMealScreen({super.key, this.existingMeal});

  @override
  State<CreateMealScreen> createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  final _nameController = TextEditingController();
  final List<MealIngredient> _ingredients = [];

  bool get _isEditing => widget.existingMeal != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _nameController.text = widget.existingMeal!.name;
      _ingredients.addAll(widget.existingMeal!.ingredients);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double get _totalKcal =>
      _ingredients.fold(0.0, (s, i) => s + i.kcal);
  double get _totalProtein =>
      _ingredients.fold(0.0, (s, i) => s + i.protein);
  double get _totalCarbs =>
      _ingredients.fold(0.0, (s, i) => s + i.carbs);
  double get _totalFat =>
      _ingredients.fold(0.0, (s, i) => s + i.fat);
  double get _totalGrams =>
      _ingredients.fold(0.0, (s, i) => s + i.grams);

  void _addIngredient() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _IngredientSearchSheet(
        onAdd: (ingredient) {
          setState(() => _ingredients.add(ingredient));
        },
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _editIngredientGrams(int index) {
    final ingredient = _ingredients[index];
    final controller =
        TextEditingController(text: ingredient.grams.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('MODIFICA GRAMMI',
            style: GoogleFonts.pressStart2p(fontSize: 9)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ingredient.foodItem.name,
                style: GoogleFonts.vt323(
                    fontSize: 22, color: AppColors.warmBlack)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.pressStart2p(fontSize: 16),
              decoration: const InputDecoration(suffixText: 'g'),
            ),
          ],
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
              final grams = double.tryParse(controller.text);
              if (grams != null && grams > 0) {
                setState(() {
                  _ingredients[index] = MealIngredient(
                    foodItem: ingredient.foodItem,
                    grams: grams,
                  );
                });
              }
              Navigator.pop(ctx);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.warmBlack, width: 2),
              ),
              child: Text('SALVA',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 8, color: AppColors.warmBlack)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMeal() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text('Inserisci un nome per il piatto',
              style: GoogleFonts.vt323(fontSize: 20, color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text('Aggiungi almeno un ingrediente',
              style: GoogleFonts.vt323(fontSize: 20, color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final state = context.read<AppState>();

    if (_isEditing) {
      final updated = CustomMeal(
        id: widget.existingMeal!.id,
        name: name,
        ingredients: _ingredients,
        createdAt: widget.existingMeal!.createdAt,
      );
      await state.updateCustomMeal(updated);
    } else {
      final meal = CustomMeal(name: name, ingredients: _ingredients);
      await state.addCustomMeal(meal);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'MODIFICA PIATTO' : 'NUOVO PIATTO',
            style: GoogleFonts.pressStart2p(fontSize: 10),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Nome piatto
                  RetroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NOME DEL PIATTO',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          style: GoogleFonts.vt323(fontSize: 24),
                          decoration: InputDecoration(
                            hintText: 'Es. Pasta al pomodoro',
                            hintStyle: GoogleFonts.vt323(
                                fontSize: 24,
                                color: AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header ingredienti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('INGREDIENTI',
                          style: GoogleFonts.pressStart2p(
                              fontSize: 9, color: AppColors.warmBlack)),
                      GestureDetector(
                        onTap: _addIngredient,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: AppColors.warmBlack, width: 2),
                            boxShadow: AppShadows.buttonShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add,
                                  size: 14, color: AppColors.warmBlack),
                              const SizedBox(width: 6),
                              Text('AGGIUNGI',
                                  style: GoogleFonts.pressStart2p(
                                      fontSize: 7,
                                      color: AppColors.warmBlack)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista ingredienti
                  if (_ingredients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant,
                              size: 40, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            'Cerca e aggiungi ingredienti\nal tuo piatto',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.vt323(
                                fontSize: 20,
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_ingredients.length, (i) {
                      final ing = _ingredients[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RetroCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _editIngredientGrams(i),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ing.foodItem.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.vt323(
                                            fontSize: 20,
                                            color: AppColors.warmBlack),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            '${ing.grams.toStringAsFixed(0)}g',
                                            style: GoogleFonts.pressStart2p(
                                                fontSize: 7,
                                                color:
                                                    AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentGreen
                                                  .withValues(alpha: 0.25),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              '${ing.kcal.toStringAsFixed(0)} kcal',
                                              style:
                                                  GoogleFonts.pressStart2p(
                                                      fontSize: 6,
                                                      color: AppColors
                                                          .warmBlack),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeIngredient(i),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.close,
                                      size: 18,
                                      color: AppColors.textTertiary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Totali
                  if (_ingredients.isNotEmpty)
                    RetroCard(
                      highlighted: true,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('TOTALE PIATTO',
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 8,
                                  color: AppColors.warmBlack)),
                          const SizedBox(height: 16),
                          Text(
                            '${_totalKcal.toStringAsFixed(0)} KCAL',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 22, color: AppColors.warmBlack),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_totalGrams.toStringAsFixed(0)}g totali',
                            style: GoogleFonts.vt323(
                                fontSize: 20,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _MiniStat(
                                  label: 'PROT',
                                  value: _totalProtein),
                              _MiniStat(
                                  label: 'CARB',
                                  value: _totalCarbs),
                              _MiniStat(
                                  label: 'GRAS',
                                  value: _totalFat),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Bottone salva fisso in basso
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: const Border(
                  top: BorderSide(color: AppColors.subtleBorder),
                ),
              ),
              child: SafeArea(
                child: GestureDetector(
                  onTap: _saveMeal,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _ingredients.isNotEmpty
                          ? AppColors.accentGreen
                          : AppColors.offWhite,
                      borderRadius: BorderRadius.circular(50),
                      border:
                          Border.all(color: AppColors.warmBlack, width: 2),
                      boxShadow: _ingredients.isNotEmpty
                          ? AppShadows.buttonShadow
                          : null,
                    ),
                    child: Text(
                      _isEditing ? 'SALVA MODIFICHE' : 'SALVA PIATTO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: _ingredients.isNotEmpty
                            ? AppColors.warmBlack
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Mini stat per il riepilogo totali
// ─────────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.pressStart2p(
                fontSize: 6, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(0)}g',
            style: GoogleFonts.pressStart2p(
                fontSize: 10, color: AppColors.warmBlack)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Bottom sheet per cercare un ingrediente e aggiungerlo con grammi
// ─────────────────────────────────────────────────────────────────────

class _IngredientSearchSheet extends StatefulWidget {
  final ValueChanged<MealIngredient> onAdd;

  const _IngredientSearchSheet({required this.onAdd});

  @override
  State<_IngredientSearchSheet> createState() =>
      _IngredientSearchSheetState();
}

class _IngredientSearchSheetState extends State<_IngredientSearchSheet> {
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
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await _service.searchProducts(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  void _showGramsDialog(FoodItem item) {
    final controller = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('QUANTITÀ',
            style: GoogleFonts.pressStart2p(fontSize: 9)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name,
                style: GoogleFonts.vt323(
                    fontSize: 22, color: AppColors.warmBlack)),
            if (item.brand.isNotEmpty)
              Text(item.brand,
                  style: GoogleFonts.vt323(
                      fontSize: 18, color: AppColors.textTertiary)),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.pressStart2p(fontSize: 16),
              decoration: const InputDecoration(suffixText: 'g'),
            ),
          ],
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
              final grams = double.tryParse(controller.text);
              if (grams != null && grams > 0) {
                widget.onAdd(
                    MealIngredient(foodItem: item, grams: grams));
                Navigator.pop(ctx); // Chiudi dialog
                Navigator.pop(context); // Chiudi sheet
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.warmBlack, width: 2),
              ),
              child: Text('AGGIUNGI',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 8, color: AppColors.warmBlack)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.subtleBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('CERCA INGREDIENTE',
                    style: GoogleFonts.pressStart2p(
                        fontSize: 9, color: AppColors.warmBlack)),
              ),
              const SizedBox(height: 12),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _performSearch,
                  textInputAction: TextInputAction.search,
                  autofocus: true,
                  style: GoogleFonts.vt323(fontSize: 22),
                  decoration: InputDecoration(
                    hintText: 'Es. pasta, pomodoro...',
                    hintStyle: GoogleFonts.vt323(
                        fontSize: 22, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textTertiary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Results
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accentGreen, strokeWidth: 3))
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Cerca un ingrediente'
                                  : 'Nessun risultato',
                              style: GoogleFonts.vt323(
                                  fontSize: 20,
                                  color: AppColors.textTertiary),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _results.length,
                            padding: const EdgeInsets.only(bottom: 20),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return ListTile(
                                onTap: () => _showGramsDialog(item),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.offWhite,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.subtleBorder),
                                  ),
                                  child: item.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (c, e, s) =>
                                                    const Icon(
                                                        Icons.fastfood,
                                                        size: 18,
                                                        color: AppColors
                                                            .textTertiary),
                                          ),
                                        )
                                      : const Icon(Icons.fastfood,
                                          size: 18,
                                          color:
                                              AppColors.textTertiary),
                                ),
                                title: Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.vt323(
                                      fontSize: 20,
                                      color: AppColors.warmBlack),
                                ),
                                subtitle: item.brand.isNotEmpty
                                    ? Text(item.brand,
                                        style: GoogleFonts.vt323(
                                            fontSize: 16,
                                            color:
                                                AppColors.textTertiary))
                                    : null,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen
                                        .withValues(alpha: 0.25),
                                    borderRadius:
                                        BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    '${item.kcalPer100g.toStringAsFixed(0)}/100g',
                                    style: GoogleFonts.pressStart2p(
                                        fontSize: 6,
                                        color: AppColors.warmBlack),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

