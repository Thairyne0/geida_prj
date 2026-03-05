import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class OpenFoodFactsService {
  /// Endpoint in ordine di priorità. Se uno fallisce o va in timeout,
  /// prova il successivo.
  static const List<String> _searchBases = [
    'https://world.openfoodfacts.net/api/v2/search', // .net è il mirror più veloce
    'https://world.openfoodfacts.org/api/v2/search',
    'https://it.openfoodfacts.org/api/v2/search', // endpoint italiano
  ];

  static const List<String> _productBases = [
    'https://world.openfoodfacts.net/api/v2/product',
    'https://world.openfoodfacts.org/api/v2/product',
    'https://it.openfoodfacts.org/api/v2/product',
  ];

  static const _headers = {
    'User-Agent': 'GeidaCalorieTracker/1.0 (Flutter)',
    'Accept': 'application/json',
  };

  static const _searchFields =
      'product_name,product_name_it,product_name_en,generic_name,'
      'brands,code,nutriments,image_front_small_url,image_front_url';

  /// Cerca prodotti per testo. Prova più endpoint con fallback.
  Future<List<FoodItem>> searchFood(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    for (final base in _searchBases) {
      try {
        final uri = Uri.parse(base).replace(queryParameters: {
          'search_terms': query.trim(),
          'fields': _searchFields,
          'page_size': '25',
          'page': '$page',
          'json': 'true',
        });

        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 8));

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

          // Se abbiamo risultati, ritorna subito
          if (items.isNotEmpty) return items;
          // Se 200 ma 0 risultati, non riprovare su altro endpoint
          return [];
        }
        // Se status != 200 (es. 504, 502), prova il prossimo endpoint
      } on Exception catch (_) {
        // Timeout o errore di rete — prova il prossimo
      }
    }
    return [];
  }

  /// Cerca un prodotto per codice a barre.
  Future<FoodItem?> getProductByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;

    for (final base in _productBases) {
      try {
        final uri = Uri.parse('$base/$barcode')
            .replace(queryParameters: {'fields': _searchFields});

        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final rawStatus = data['status'];
          final isSuccess =
              rawStatus == 'success' || rawStatus == 1 || rawStatus == '1';
          if (isSuccess && data['product'] != null) {
            return FoodItem.fromOpenFoodFacts(
                data['product'] as Map<String, dynamic>);
          }
          // Prodotto non trovato — non riprovare
          return null;
        }
      } on Exception catch (_) {
        // Prova il prossimo
      }
    }
    return null;
  }
}

