import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../utils/pricing.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.qty,
    this.stockQuantity,
    this.nameEn = '',
  });

  final String id;
  final String name;
  final String nameEn;
  final int quantity;
  final double price;
  final String imageUrl;
  final String qty;
  final int? stockQuantity;

  double get lineTotal => price * quantity;

  String nameFor({required bool english}) => english && nameEn.isNotEmpty ? nameEn : name;

  String qtyFor({required bool english}) => Product.localizeQty(qty, english: english);

  CartItem copyWith({int? quantity, int? stockQuantity}) {
    return CartItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      price: price,
      imageUrl: imageUrl,
      qty: qty,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      nameEn: nameEn,
    );
  }
}

class CartProvider with ChangeNotifier {
  static const int maxQuantityPerItem = 99;

  final Map<String, CartItem> _items = {};
  String? _appliedPromoCode;
  double _discountPercent = 0;

  Map<String, CartItem> get items => Map.unmodifiable(_items);

  String? get appliedPromoCode => _appliedPromoCode;

  double get discountPercent => _discountPercent;

  int get itemCount => _items.length;

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  double get subtotalAmount => _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get discountAmount => subtotalAmount * (_discountPercent / 100);

  double get amountAfterDiscount => math.max(0, subtotalAmount - discountAmount);

  double get deliveryAmount => calculateDeliveryFee(amountAfterDiscount);

  double get totalAmount => amountAfterDiscount + deliveryAmount;

  bool get hasPromoCode => _appliedPromoCode != null && _appliedPromoCode!.isNotEmpty;

  void applyPromoCode(String promoCode, double percent) {
    _appliedPromoCode = promoCode;
    _discountPercent = percent;
    notifyListeners();
  }

  void clearPromoCode() {
    _appliedPromoCode = null;
    _discountPercent = 0;
    notifyListeners();
  }

  /// Adds one unit of [product]. Returns false when the stock limit is reached.
  bool addProduct(Product product) {
    final existingItem = _items[product.id];
    final maxAllowed = math.min(product.stock, maxQuantityPerItem);
    final nextQuantity = (existingItem?.quantity ?? 0) + 1;

    if (product.isOutOfStock || nextQuantity > maxAllowed) {
      return false;
    }

    _items[product.id] = existingItem?.copyWith(
          quantity: nextQuantity,
          stockQuantity: product.stock,
        ) ??
        CartItem(
          id: product.id,
          name: product.name,
          quantity: nextQuantity,
          price: product.price,
          imageUrl: product.imageUrl,
          qty: product.qty,
          stockQuantity: product.stock,
          nameEn: product.nameEn,
        );
    notifyListeners();
    return true;
  }

  /// Adds one more unit of an item that is already in the cart.
  bool increment(String productId) {
    final item = _items[productId];
    if (item == null) return false;

    final maxAllowed = math.min(item.stockQuantity ?? maxQuantityPerItem, maxQuantityPerItem);
    if (item.quantity + 1 > maxAllowed) {
      return false;
    }

    _items[productId] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
    return true;
  }

  void decrement(String productId) {
    final item = _items[productId];
    if (item == null) return;

    if (item.quantity > 1) {
      _items[productId] = item.copyWith(quantity: item.quantity - 1);
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isEmpty && _appliedPromoCode == null) return;

    _items.clear();
    _appliedPromoCode = null;
    _discountPercent = 0;
    notifyListeners();
  }
}
