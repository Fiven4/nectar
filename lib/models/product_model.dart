import '../data/catalog_translations.dart';
import '../utils/parsers.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.qty,
    required this.description,
    required this.imageUrl,
    required this.categoryName,
    this.nameEn = '',
    this.descriptionEn = '',
    this.compositionEn = '',
    this.categoryNameEn = '',
    this.brand = '',
    this.country = '',
    this.composition = '',
    this.calories = 0,
    this.proteins = 0,
    this.fats = 0,
    this.carbs = 0,
    this.expiryDate,
    this.popularity = 0,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String qty;
  final String description;
  final String imageUrl;
  final String categoryName;
  final String nameEn;
  final String descriptionEn;
  final String compositionEn;
  final String categoryNameEn;
  final String brand;
  final String country;
  final String composition;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final DateTime? expiryDate;
  final int popularity;

  bool get hasNutrition => calories > 0 || proteins > 0 || fats > 0 || carbs > 0;

  bool get isOutOfStock => stock <= 0;

  String nameFor({required bool english}) => _pick(english, name, nameEn);

  String descriptionFor({required bool english}) => _pick(english, description, descriptionEn);

  String compositionFor({required bool english}) => _pick(english, composition, compositionEn);

  String categoryFor({required bool english}) => _pick(english, categoryName, categoryNameEn);

  String qtyFor({required bool english}) => localizeQty(qty, english: english);

  String countryFor({required bool english}) {
    return english ? (countryTranslations[country] ?? country) : country;
  }

  static String _pick(bool english, String russian, String englishValue) {
    return english && englishValue.trim().isNotEmpty ? englishValue : russian;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final categoryName = toStringValue(map['categoryName']).isNotEmpty
        ? toStringValue(map['categoryName'])
        : toStringValue(map['category']);
    final description = toStringValue(map['description']).isNotEmpty
        ? toStringValue(map['description'])
        : toStringValue(map['details']);

    final id = toStringValue(map['id']);
    // Для товаров стартового каталога английские тексты берутся из приложения,
    // если в базе их еще нет; значения из базы имеют приоритет.
    final builtIn = productTranslations[id];
    final builtInCategory = categoryTranslations[toStringValue(map['categoryId'])];
    String english(String field, String? fallback) {
      final stored = toStringValue(map[field]);
      return stored.isNotEmpty ? stored : (fallback ?? '');
    }

    return Product(
      id: id,
      name: toStringValue(map['name']),
      price: toDoubleValue(map['price']),
      stock: toIntValue(map['stockQuantity'] ?? map['stock']),
      qty: toStringValue(map['qty']),
      description: description,
      imageUrl: toStringValue(map['imageUrl']),
      categoryName: categoryName,
      nameEn: english('nameEn', builtIn?.name),
      descriptionEn: english('descriptionEn', builtIn?.description),
      compositionEn: english('compositionEn', builtIn?.composition),
      categoryNameEn: english('categoryNameEn', builtInCategory?.name),
      brand: toStringValue(map['manufacturerName']),
      country: toStringValue(map['country']),
      composition: toStringValue(map['composition']),
      calories: toDoubleValue(map['calories']),
      proteins: toDoubleValue(map['proteins']),
      fats: toDoubleValue(map['fats']),
      carbs: toDoubleValue(map['carbs']),
      expiryDate: map['expiryDate'] == null ? null : toDateTimeValue(map['expiryDate']),
      popularity: toIntValue(map['popularity']),
    );
  }

  static final RegExp _unitPattern = RegExp(
    r'(?<=\d)\s*(kg|ml|pcs|кг|мл|шт|g|l|г|л)(?![\p{L}])',
    caseSensitive: false,
    unicode: true,
  );

  static const Map<String, (String, String)> _units = {
    'kg': ('кг', 'kg'),
    'кг': ('кг', 'kg'),
    'g': ('г', 'g'),
    'г': ('г', 'g'),
    'ml': ('мл', 'ml'),
    'мл': ('мл', 'ml'),
    'l': ('л', 'l'),
    'л': ('л', 'l'),
    'pcs': ('шт', 'pcs'),
    'шт': ('шт', 'pcs'),
  };

  /// Приводит единицы измерения («1 kg», «500 г») к языку интерфейса.
  static String localizeQty(String value, {required bool english}) {
    return value.replaceAllMapped(_unitPattern, (match) {
      final unit = _units[match.group(1)!.toLowerCase()];
      if (unit == null) return match.group(0)!;
      return ' ${english ? unit.$2 : unit.$1}';
    });
  }
}
