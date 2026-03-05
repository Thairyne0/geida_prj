class FoodItem {
  final String name;
  final String brand;
  final String barcode;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String? imageUrl;

  FoodItem({
    required this.name,
    this.brand = '',
    this.barcode = '',
    required this.kcalPer100g,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatPer100g = 0,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'brand': brand,
        'barcode': barcode,
        'kcalPer100g': kcalPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
        'imageUrl': imageUrl,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'] as String? ?? 'Sconosciuto',
        brand: json['brand'] as String? ?? '',
        barcode: json['barcode'] as String? ?? '',
        kcalPer100g: (json['kcalPer100g'] as num?)?.toDouble() ?? 0,
        proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0,
        carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0,
        fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0,
        imageUrl: json['imageUrl'] as String?,
      );

  factory FoodItem.fromOpenFoodFacts(Map<String, dynamic> product) {
    final nutrients = product['nutriments'] as Map<String, dynamic>? ?? {};

    // Catena di fallback per il nome del prodotto
    String name = '';
    for (final key in [
      'product_name_it',
      'product_name',
      'product_name_en',
      'generic_name',
    ]) {
      final val = product[key] as String?;
      if (val != null && val.trim().isNotEmpty) {
        name = val.trim();
        break;
      }
    }
    if (name.isEmpty) name = 'Prodotto sconosciuto';

    // Fallback immagine
    final imageUrl = product['image_front_small_url'] as String? ??
        product['image_front_url'] as String?;

    // kcal: prova vari campi
    final kcalDirect = (nutrients['energy-kcal_100g'] as num?)?.toDouble();
    final energyKj = (nutrients['energy_100g'] as num?)?.toDouble();
    final kcal = kcalDirect ?? (energyKj != null ? energyKj / 4.184 : 0.0);

    return FoodItem(
      name: name,
      brand: (product['brands'] as String? ?? '').trim(),
      barcode: product['code'] as String? ?? '',
      kcalPer100g: kcal,
      proteinPer100g:
          (nutrients['proteins_100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g:
          (nutrients['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (nutrients['fat_100g'] as num?)?.toDouble() ?? 0,
      imageUrl: imageUrl,
    );
  }
}

