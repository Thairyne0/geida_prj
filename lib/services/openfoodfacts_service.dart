import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  Future<List<FoodItem>> searchFood(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_baseUrl/search?search_terms=${Uri.encodeComponent(query)}'
      '&fields=product_name,product_name_it,brands,code,nutriments,image_front_small_url'
      '&page_size=20&page=$page&json=1',
    );

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'GeidaCalorieTracker/1.0 (Flutter)',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];
        return products
            .map((p) =>
                FoodItem.fromOpenFoodFacts(p as Map<String, dynamic>))
            .where((item) => item.name.isNotEmpty && item.kcalPer100g > 0)
            .toList();
      }
    } catch (e) {
      // Silently fail, return empty
    }
    return [];
  }

  Future<FoodItem?> getProductByBarcode(String barcode) async {
    final uri = Uri.parse('$_baseUrl/product/$barcode.json'
        '?fields=product_name,product_name_it,brands,code,nutriments,image_front_small_url');

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'GeidaCalorieTracker/1.0 (Flutter)',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1 && data['product'] != null) {
          return FoodItem.fromOpenFoodFacts(
              data['product'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }
}

