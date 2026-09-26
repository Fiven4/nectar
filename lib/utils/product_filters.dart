import '../l10n/l10n.dart';
import '../models/product_model.dart';

enum ProductSort {
  none,
  freshFirst,
  priceDescending,
  priceAscending;

  String label(AppLocalizations l10n) {
    switch (this) {
      case ProductSort.none:
        return l10n.sortDefault;
      case ProductSort.freshFirst:
        return l10n.sortFreshFirst;
      case ProductSort.priceDescending:
        return l10n.sortPriceDesc;
      case ProductSort.priceAscending:
        return l10n.sortPriceAsc;
    }
  }
}

class ProductFilters {
  const ProductFilters({
    this.minPrice,
    this.maxPrice,
    this.brands = const {},
    this.sort = ProductSort.none,
  });

  final double? minPrice;
  final double? maxPrice;
  final Set<String> brands;
  final ProductSort sort;

  bool get isActive => minPrice != null || maxPrice != null || brands.isNotEmpty || sort != ProductSort.none;

  List<Product> apply(List<Product> products) {
    final filtered = products.where((product) {
      if (minPrice != null && product.price < minPrice!) return false;
      if (maxPrice != null && product.price > maxPrice!) return false;
      if (brands.isNotEmpty && !brands.contains(product.brand)) return false;
      return true;
    }).toList();

    switch (sort) {
      case ProductSort.none:
        break;
      case ProductSort.priceAscending:
        filtered.sort((left, right) => left.price.compareTo(right.price));
      case ProductSort.priceDescending:
        filtered.sort((left, right) => right.price.compareTo(left.price));
      case ProductSort.freshFirst:
        final unknownDate = DateTime.fromMillisecondsSinceEpoch(0);
        filtered.sort((left, right) {
          return (right.expiryDate ?? unknownDate).compareTo(left.expiryDate ?? unknownDate);
        });
    }
    return filtered;
  }
}
