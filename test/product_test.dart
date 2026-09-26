import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/models/product_model.dart';

Product _product(Map<String, dynamic> map) => Product.fromMap({'id': 'p', 'name': 'Товар', ...map});

void main() {
  group('Product.fromMap', () {
    test('reads modern admin-created fields', () {
      final product = _product({
        'name': ' Молоко ',
        'price': 89,
        'stockQuantity': 12.0,
        'qty': '1 l',
        'description': 'Свежее',
        'imageUrl': 'https://example.com/m.png',
        'categoryName': 'Молочные продукты',
      });

      expect(product.name, 'Молоко');
      expect(product.price, 89.0);
      expect(product.stock, 12);
      expect(product.categoryName, 'Молочные продукты');
      expect(product.qtyFor(english: false), '1 л');
      expect(product.isOutOfStock, isFalse);
    });

    test('falls back to legacy fields and survives missing data', () {
      final product = _product({
        'category': 'Фрукты',
        'stock': 0,
        'details': 'Хрустящее',
      });

      expect(product.categoryName, 'Фрукты');
      expect(product.description, 'Хрустящее');
      expect(product.price, 0);
      expect(product.imageUrl, '');
      expect(product.isOutOfStock, isTrue);
    });
  });

  group('English content', () {
    final product = _product({
      'name': 'Молоко',
      'nameEn': 'Milk',
      'description': 'Свежее',
      'descriptionEn': 'Fresh',
      'composition': 'Молоко',
      'compositionEn': 'Milk',
      'categoryName': 'Молочные продукты',
      'categoryNameEn': 'Dairy',
      'country': 'Россия',
      'qty': '1 л',
    });

    test('is used when the interface is English', () {
      expect(product.nameFor(english: true), 'Milk');
      expect(product.descriptionFor(english: true), 'Fresh');
      expect(product.compositionFor(english: true), 'Milk');
      expect(product.categoryFor(english: true), 'Dairy');
      expect(product.countryFor(english: true), 'Russia');
      expect(product.qtyFor(english: true), '1 l');
    });

    test('Russian content stays when the interface is Russian', () {
      expect(product.nameFor(english: false), 'Молоко');
      expect(product.categoryFor(english: false), 'Молочные продукты');
      expect(product.countryFor(english: false), 'Россия');
    });

    test('falls back to Russian when there is no translation', () {
      final untranslated = _product({'name': 'Хлеб', 'country': 'Неизвестно'});
      expect(untranslated.nameFor(english: true), 'Хлеб');
      expect(untranslated.countryFor(english: true), 'Неизвестно');
    });
  });

  group('Product.localizeQty', () {
    test('translates units in both directions', () {
      expect(Product.localizeQty('1 kg', english: false), '1 кг');
      expect(Product.localizeQty('500g', english: false), '500 г');
      expect(Product.localizeQty('250 ml', english: false), '250 мл');
      expect(Product.localizeQty('2 pcs', english: false), '2 шт');
      expect(Product.localizeQty('1 кг', english: true), '1 kg');
      expect(Product.localizeQty('10 шт', english: true), '10 pcs');
      expect(Product.localizeQty('1.5 л', english: true), '1.5 l');
    });

    test('does not touch words that merely contain unit letters', () {
      expect(Product.localizeQty('Large pack', english: true), 'Large pack');
      expect(Product.localizeQty('2 литра', english: true), '2 литра');
    });
  });
}
