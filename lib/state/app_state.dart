import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/food_log_entry.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  UserProfile? _profile;
  List<FoodLogEntry> _allEntries = [];
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  List<FoodLogEntry> get allEntries => _allEntries;

  List<FoodLogEntry> get todayEntries {
    final now = DateTime.now();
    return _allEntries
        .where((e) =>
            e.dateTime.year == now.year &&
            e.dateTime.month == now.month &&
            e.dateTime.day == now.day)
        .toList();
  }

  double get todayKcal =>
      todayEntries.fold(0.0, (sum, e) => sum + e.totalKcal);

  double get todayProtein =>
      todayEntries.fold(0.0, (sum, e) => sum + e.totalProtein);

  double get todayCarbs =>
      todayEntries.fold(0.0, (sum, e) => sum + e.totalCarbs);

  double get todayFat =>
      todayEntries.fold(0.0, (sum, e) => sum + e.totalFat);

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _storage.loadProfile();
    _allEntries = await _storage.loadFoodLog();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _storage.saveProfile(profile);
    notifyListeners();
  }

  Future<void> addEntry(FoodItem foodItem, double grams) async {
    final entry = FoodLogEntry(foodItem: foodItem, grams: grams);
    _allEntries.add(entry);
    await _storage.saveFoodLog(_allEntries);
    notifyListeners();
  }

  Future<void> removeEntry(int index) async {
    final todayList = todayEntries;
    if (index >= 0 && index < todayList.length) {
      final entryToRemove = todayList[index];
      _allEntries.remove(entryToRemove);
      await _storage.saveFoodLog(_allEntries);
      notifyListeners();
    }
  }

  /// Rimuove una entry specifica dalla lista globale.
  Future<void> removeEntryGlobal(FoodLogEntry entry) async {
    _allEntries.remove(entry);
    await _storage.saveFoodLog(_allEntries);
    notifyListeners();
  }

  /// Restituisce le entry per un giorno specifico.
  List<FoodLogEntry> entriesForDate(DateTime date) {
    return _allEntries
        .where((e) =>
            e.dateTime.year == date.year &&
            e.dateTime.month == date.month &&
            e.dateTime.day == date.day)
        .toList();
  }

  /// Restituisce la somma kcal per un giorno specifico.
  double kcalForDate(DateTime date) {
    return entriesForDate(date).fold(0.0, (sum, e) => sum + e.totalKcal);
  }

  /// Restituisce tutte le date (univoche) che hanno almeno una entry,
  /// ordinate dal più recente al più vecchio.
  List<DateTime> get datesWithEntries {
    final seen = <String>{};
    final dates = <DateTime>[];
    // Ordina prima per data decrescente
    final sorted = List<FoodLogEntry>.from(_allEntries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    for (final e in sorted) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month}-${e.dateTime.day}';
      if (seen.add(key)) {
        dates.add(DateTime(
            e.dateTime.year, e.dateTime.month, e.dateTime.day));
      }
    }
    return dates;
  }
}

