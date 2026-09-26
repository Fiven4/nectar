import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/data/product_catalog.dart';
import 'package:nectar/models/product_model.dart';
import 'package:nectar/utils/pricing.dart';
import 'package:nectar/utils/product_filters.dart';

void main() {
  group('product catalog', () {
    test('has unique ids and names', () {
      final ids = catalogProducts.map((product) => product.id).toList();
      final names = catalogProducts.map((product) => product.name.toLowerCase()).toList();

      expect(ids.toSet().length, ids.length);
      expect(names.toSet().length, names.length);
    });

    test('references only existing categories and manufacturers', () {
      final categoryIds = catalogCategories.map((category) => category.id).toSet();
      final manufacturerIds = catalogManufacturers.map((manufacturer) => manufacturer.id).toSet();

      for (final product in catalogProducts) {
        expect(categoryIds, contains(product.categoryId), reason: product.id);
        expect(manufacturerIds, contains(product.manufacturerId), reason: product.id);
      }
    });

    test('every category has at least three products', () {
      for (final category in catalogCategories) {
        final count = catalogProducts.where((product) => product.categoryId == category.id).length;
        expect(count, greaterThanOrEqualTo(3), reason: category.name);
      }
    });

    test('products have sane prices, stock and images', () {
      for (final product in catalogProducts) {
        expect(product.price, greaterThan(0), reason: product.id);
        expect(product.stock, greaterThanOrEqualTo(0), reason: product.id);
        expect(product.imageUrl, startsWith('https://'), reason: product.id);
        expect(product.qty.split(' ').length, 2, reason: product.id);
      }
    });
  });

  group('pricing', () {
    test('delivery fee depends on the amount', () {
      expect(calculateDeliveryFee(0), 0);
      expect(calculateDeliveryFee(500), standardDeliveryFee);
      expect(calculateDeliveryFee(freeDeliveryThreshold), 0);
    });

    test('order total applies discount before delivery', () {
      expect(calculateOrderTotal(subtotal: 1000, discountPercent: 20), 800 + standardDeliveryFee);
      expect(calculateOrderTotal(subtotal: 2000, discountPercent: 20), 1600);
    });
  });

  group('product filters', () {
    Product product(String id, double price, String brand, DateTime? expiry) => Product(
          id: id,
          name: id,
          price: price,
          stock: 5,
          qty: '1 шт',
          description: '',
          imageUrl: '',
          categoryName: 'Тест',
          brand: brand,
          expiryDate: expiry,
        );

    final products = [
      product('a', 100, 'X', DateTime(2030, 1, 1)),
      product('b', 300, 'Y', DateTime(2031, 1, 1)),
      product('c', 200, 'X', null),
    ];

    test('filters by price range and brand', () {
      final filtered = const ProductFilters(minPrice: 150, brands: {'X'}).apply(products);
      expect(filtered.map((item) => item.id), ['c']);
    });

    test('sorts by price and freshness', () {
      expect(
        const ProductFilters(sort: ProductSort.priceDescending).apply(products).map((item) => item.id),
        ['b', 'c', 'a'],
      );
      expect(
        const ProductFilters(sort: ProductSort.freshFirst).apply(products).map((item) => item.id),
        ['b', 'a', 'c'],
      );
    });

    test('default filters keep everything', () {
      expect(const ProductFilters().isActive, isFalse);
      expect(const ProductFilters().apply(products), hasLength(3));
    });
  });
}
