import 'food_item.dart';

/// Un singolo ingrediente dentro un piatto personalizzato.
class MealIngredient {
  final FoodItem foodItem;
  final double grams;

  MealIngredient({required this.foodItem, required this.grams});

  double get kcal => (foodItem.kcalPer100g * grams) / 100;
  double get protein => (foodItem.proteinPer100g * grams) / 100;
  double get carbs => (foodItem.carbsPer100g * grams) / 100;
  double get fat => (foodItem.fatPer100g * grams) / 100;

  Map<String, dynamic> toJson() => {
        'foodItem': foodItem.toJson(),
        'grams': grams,
      };

  factory MealIngredient.fromJson(Map<String, dynamic> json) =>
      MealIngredient(
        foodItem:
            FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
        grams: (json['grams'] as num).toDouble(),
      );
}

/// Un piatto personalizzato composto da più ingredienti.
/// Può essere salvato e riutilizzato velocemente.
class CustomMeal {
  final String id;
  final String name;
  final List<MealIngredient> ingredients;
  final DateTime createdAt;

  CustomMeal({
    String? id,
    required this.name,
    required this.ingredients,
    DateTime? createdAt,
  })  : id = id ?? '${DateTime.now().millisecondsSinceEpoch}',
        createdAt = createdAt ?? DateTime.now();

  double get totalKcal =>
      ingredients.fold(0.0, (sum, i) => sum + i.kcal);

  double get totalProtein =>
      ingredients.fold(0.0, (sum, i) => sum + i.protein);

  double get totalCarbs =>
      ingredients.fold(0.0, (sum, i) => sum + i.carbs);

  double get totalFat =>
      ingredients.fold(0.0, (sum, i) => sum + i.fat);

  double get totalGrams =>
      ingredients.fold(0.0, (sum, i) => sum + i.grams);

  /// Calorie per 100g del piatto completo.
  double get kcalPer100g =>
      totalGrams > 0 ? (totalKcal / totalGrams) * 100 : 0;

  /// Converte il piatto in un FoodItem "virtuale" per poterlo
  /// aggiungere al diario come se fosse un singolo alimento.
  FoodItem toFoodItem() => FoodItem(
        name: name,
        brand: '${ingredients.length} ingredienti',
        kcalPer100g: kcalPer100g,
        proteinPer100g:
            totalGrams > 0 ? (totalProtein / totalGrams) * 100 : 0,
        carbsPer100g:
            totalGrams > 0 ? (totalCarbs / totalGrams) * 100 : 0,
        fatPer100g:
            totalGrams > 0 ? (totalFat / totalGrams) * 100 : 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomMeal.fromJson(Map<String, dynamic> json) => CustomMeal(
        id: json['id'] as String?,
        name: json['name'] as String? ?? 'Piatto senza nome',
        ingredients: (json['ingredients'] as List<dynamic>? ?? [])
            .map((i) =>
                MealIngredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}

