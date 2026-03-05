import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/food_log_entry.dart';
import '../models/custom_meal.dart';

class StorageService {
  static const String _profileKey = 'user_profile';
  static const String _foodLogKey = 'food_log';
  static const String _customMealsKey = 'custom_meals';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data != null) {
      return UserProfile.fromJson(
          json.decode(data) as Map<String, dynamic>);
    }
    return null;
  }

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_profileKey);
  }

  Future<void> saveFoodLog(List<FoodLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_foodLogKey, json.encode(data));
  }

  Future<List<FoodLogEntry>> loadFoodLog() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_foodLogKey);
    if (data != null) {
      final list = json.decode(data) as List<dynamic>;
      return list
          .map((e) =>
              FoodLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> addFoodLogEntry(FoodLogEntry entry) async {
    final entries = await loadFoodLog();
    entries.add(entry);
    await saveFoodLog(entries);
  }

  Future<void> removeFoodLogEntry(int index) async {
    final entries = await loadFoodLog();
    if (index >= 0 && index < entries.length) {
      entries.removeAt(index);
      await saveFoodLog(entries);
    }
  }

  Future<List<FoodLogEntry>> getTodayEntries() async {
    final entries = await loadFoodLog();
    final now = DateTime.now();
    return entries
        .where((e) =>
            e.dateTime.year == now.year &&
            e.dateTime.month == now.month &&
            e.dateTime.day == now.day)
        .toList();
  }

  // ── Custom Meals ──────────────────────────────────────────────────

  Future<void> saveCustomMeals(List<CustomMeal> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final data = meals.map((m) => m.toJson()).toList();
    await prefs.setString(_customMealsKey, json.encode(data));
  }

  Future<List<CustomMeal>> loadCustomMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_customMealsKey);
    if (data != null) {
      final list = json.decode(data) as List<dynamic>;
      return list
          .map((m) => CustomMeal.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

