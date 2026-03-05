import 'food_item.dart';

class FoodLogEntry {
  final FoodItem foodItem;
  final double grams;
  final DateTime dateTime;

  FoodLogEntry({
    required this.foodItem,
    required this.grams,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  double get totalKcal => (foodItem.kcalPer100g * grams) / 100;
  double get totalProtein => (foodItem.proteinPer100g * grams) / 100;
  double get totalCarbs => (foodItem.carbsPer100g * grams) / 100;
  double get totalFat => (foodItem.fatPer100g * grams) / 100;

  Map<String, dynamic> toJson() => {
        'foodItem': foodItem.toJson(),
        'grams': grams,
        'dateTime': dateTime.toIso8601String(),
      };

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) => FoodLogEntry(
        foodItem:
            FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
        grams: (json['grams'] as num).toDouble(),
        dateTime: DateTime.parse(json['dateTime'] as String),
      );
}

