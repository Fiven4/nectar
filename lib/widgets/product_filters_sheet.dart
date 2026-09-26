import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../utils/app_palette.dart';
import '../utils/product_filters.dart';
import '../l10n/l10n.dart';

Future<ProductFilters?> showProductFiltersSheet(
  BuildContext context, {
  required List<Product> products,
  required ProductFilters current,
}) {
  return showModalBottomSheet<ProductFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _ProductFiltersSheet(products: products, current: current),
  );
}

class _ProductFiltersSheet extends StatefulWidget {
  const _ProductFiltersSheet({required this.products, required this.current});

  final List<Product> products;
  final ProductFilters current;

  @override
  State<_ProductFiltersSheet> createState() => _ProductFiltersSheetState();
}

class _ProductFiltersSheetState extends State<_ProductFiltersSheet> {
  late final double _lowerBound;
  late final double _upperBound;
  late final List<String> _availableBrands;
  late RangeValues _range;
  late Set<String> _brands;
  late ProductSort _sort;

  @override
  void initState() {
    super.initState();
    final prices = widget.products.map((product) => product.price);
    _lowerBound = prices.isEmpty ? 0 : prices.reduce(math.min).floorToDouble();
    _upperBound = prices.isEmpty ? 1 : math.max(prices.reduce(math.max).ceilToDouble(), _lowerBound + 1);
    _availableBrands = widget.products.map((product) => product.brand).where((brand) => brand.isNotEmpty).toSet().toList()
      ..sort();

    _range = RangeValues(
      (widget.current.minPrice ?? _lowerBound).clamp(_lowerBound, _upperBound),
      (widget.current.maxPrice ?? _upperBound).clamp(_lowerBound, _upperBound),
    );
    _brands = {...widget.current.brands};
    _sort = widget.current.sort;
  }

  ProductFilters _buildFilters() {
    return ProductFilters(
      minPrice: _range.start > _lowerBound ? _range.start : null,
      maxPrice: _range.end < _upperBound ? _range.end : null,
      brands: _brands,
      sort: _sort,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.filtersTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.filterPrice(_range.start.round(), _range.end.round()),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              RangeSlider(
                values: _range,
                min: _lowerBound,
                max: _upperBound,
                activeColor: AppPalette.primary,
                labels: RangeLabels('${_range.start.round()} ₽', '${_range.end.round()} ₽'),
                onChanged: (values) => setState(() => _range = values),
              ),
              if (_availableBrands.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(context.l10n.filterBrand, style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final brand in _availableBrands)
                      FilterChip(
                        label: Text(brand),
                        selected: _brands.contains(brand),
                        selectedColor: AppPalette.lightPrimary,
                        onSelected: (selected) => setState(() {
                          selected ? _brands.add(brand) : _brands.remove(brand);
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(context.l10n.filterSort, style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final sort in ProductSort.values)
                    ChoiceChip(
                      label: Text(sort.label(context.l10n)),
                      selected: _sort == sort,
                      selectedColor: AppPalette.lightPrimary,
                      onSelected: (_) => setState(() => _sort = sort),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, const ProductFilters()),
                      child: Text(context.l10n.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context, _buildFilters()),
                      child: Text(context.l10n.apply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
