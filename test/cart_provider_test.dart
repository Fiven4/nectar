import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/models/product_model.dart';
import 'package:nectar/providers/cart_provider.dart';
import 'package:nectar/utils/pricing.dart';

Product _product({String id = 'p1', double price = 100, int stock = 5}) {
  return Product(
    id: id,
    name: 'Товар $id',
    price: price,
    stock: stock,
    qty: '1 kg',
    description: '',
    imageUrl: '',
    categoryName: 'Фрукты',
  );
}

void main() {
  test('adding the same product increases its quantity', () {
    final cart = CartProvider();
    final product = _product();

    expect(cart.addProduct(product), isTrue);
    expect(cart.addProduct(product), isTrue);

    expect(cart.itemCount, 1);
    expect(cart.items['p1']!.quantity, 2);
    expect(cart.totalQuantity, 2);
    expect(cart.subtotalAmount, 200);
  });

  test('stock limits are enforced', () {
    final cart = CartProvider();
    final product = _product(stock: 2);

    expect(cart.addProduct(product), isTrue);
    expect(cart.addProduct(product), isTrue);
    expect(cart.addProduct(product), isFalse);
    expect(cart.increment('p1'), isFalse);
    expect(cart.items['p1']!.quantity, 2);
  });

  test('out-of-stock products cannot be added', () {
    final cart = CartProvider();
    expect(cart.addProduct(_product(stock: 0)), isFalse);
    expect(cart.isEmpty, isTrue);
  });

  test('decrement removes the item at quantity one', () {
    final cart = CartProvider()..addProduct(_product());

    cart.decrement('p1');

    expect(cart.isEmpty, isTrue);
  });

  test('promo code discount is applied to the total', () {
    final cart = CartProvider()
      ..addProduct(_product(price: 200))
      ..applyPromoCode('NECTAR20', 20);

    expect(cart.hasPromoCode, isTrue);
    expect(cart.discountAmount, 40);
    expect(cart.amountAfterDiscount, 160);
    expect(cart.deliveryAmount, standardDeliveryFee);
    expect(cart.totalAmount, 160 + standardDeliveryFee);
  });

  test('delivery is free above the threshold', () {
    final cart = CartProvider()..addProduct(_product(price: 800, stock: 5));
    cart.addProduct(_product(price: 800, stock: 5));

    expect(cart.subtotalAmount, 1600);
    expect(cart.deliveryAmount, 0);
    expect(cart.totalAmount, 1600);
  });

  test('clear resets items and promo code and notifies once', () {
    final cart = CartProvider()
      ..addProduct(_product())
      ..applyPromoCode('NECTAR20', 20);
    var notifications = 0;
    cart.addListener(() => notifications++);

    cart.clear();
    cart.clear();

    expect(cart.isEmpty, isTrue);
    expect(cart.hasPromoCode, isFalse);
    expect(cart.totalAmount, 0);
    expect(notifications, 1);
  });

  test('exposed items map cannot be modified from outside', () {
    final cart = CartProvider()..addProduct(_product());
    expect(() => cart.items.remove('p1'), throwsUnsupportedError);
  });
}
