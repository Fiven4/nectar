import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/product_filters.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/product_filters_sheet.dart';
import '../../widgets/product_grid.dart';
import '../../l10n/l10n.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.title,
    required this.categoryNames,
  });

  final String title;
  final List<String> categoryNames;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final Stream<List<Product>> _catalog = DatabaseService().watchCatalog();
  ProductFilters _filters = const ProductFilters();
  List<Product> _categoryProducts = const [];

  Future<void> _openFilters() async {
    final result = await showProductFiltersSheet(context, products: _categoryProducts, current: _filters);
    if (result != null && mounted) setState(() => _filters = result);
  }

  bool _matches(Product product) {
    final category = product.categoryName.toLowerCase();
    return widget.categoryNames.any((name) => name.toLowerCase() == category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: AppPalette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.filtersTitle,
            onPressed: _openFilters,
            icon: Icon(
              _filters.isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _filters.isActive ? AppPalette.primary : Colors.black,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CenteredMessage(context.l10n.productsLoadFailedLater, icon: Icons.cloud_off);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
          }

          _categoryProducts = snapshot.data!.where(_matches).toList();
          if (_categoryProducts.isEmpty) {
            return CenteredMessage(context.l10n.categoryEmpty);
          }

          final products = _filters.apply(_categoryProducts);
          if (products.isEmpty) {
            return CenteredMessage(context.l10n.noProductsForFilters);
          }

          return ProductGrid(products: products, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10));
        },
      ),
    );
  }
}
