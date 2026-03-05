import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

/// Servizio per interagire con l'API di Open Food Facts.
///
/// Endpoint base: https://world.openfoodfacts.org
///
/// Rate limits:
/// - Product (barcode): max 100 req/min
/// - Search: max 10 req/min
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  static const _headers = {
    'User-Agent': 'GeidaCalorieTracker/1.0 (Flutter)',
    'Accept': 'application/json',
  };

  // ── Cache in memoria ──────────────────────────────────────────────
  final Map<String, FoodItem> _barcodeCache = {};
  final Map<String, List<FoodItem>> _searchCache = {};

  // ── SEARCH ────────────────────────────────────────────────────────
  /// GET /cgi/search.pl
  ///
  /// Parametri obbligatori: search_terms, search_simple=1, action=process, json=1
  /// Parametri opzionali: page, page_size, fields
  Future<List<FoodItem>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    // Controlla cache
    final cacheKey = '${query.trim().toLowerCase()}|$page';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final uri = Uri.parse('$_baseUrl/cgi/search.pl').replace(
      queryParameters: {
        'search_terms': query.trim(),
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '$pageSize',
        'page': '$page',
      },
    );

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];

        final items = products
            .map((p) =>
                FoodItem.fromOpenFoodFacts(p as Map<String, dynamic>))
            .where((item) =>
                item.name.isNotEmpty &&
                item.name != 'Prodotto sconosciuto')
            .toList();

        // Salva in cache
        _searchCache[cacheKey] = items;
        return items;
      }
    } on Exception catch (_) {
      // Errore di rete / timeout
    }
    return [];
  }

  // ── GET PRODUCT BY BARCODE ────────────────────────────────────────
  /// GET /api/v0/product/{barcode}.json
  ///
  /// Se status == 0 → prodotto non trovato.
  Future<FoodItem?> getProductByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;

    // Controlla cache
    if (_barcodeCache.containsKey(barcode)) {
      return _barcodeCache[barcode];
    }

    final uri = Uri.parse('$_baseUrl/api/v0/product/$barcode.json');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // status == 0 → prodotto non trovato
        if (data['status'] == 0) return null;

        if (data['product'] != null) {
          final item = FoodItem.fromOpenFoodFacts(
              data['product'] as Map<String, dynamic>);
          // Salva in cache
          _barcodeCache[barcode] = item;
          return item;
        }
      }
    } on Exception catch (_) {
      // Errore di rete / timeout
    }
    return null;
  }

  /// Pulisce la cache (utile per test o refresh forzato).
  void clearCache() {
    _barcodeCache.clear();
    _searchCache.clear();
  }
}
