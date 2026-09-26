import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_grid.dart';
import '../favorites/favorites_screen.dart';
import 'category_screen.dart';
import '../../l10n/l10n.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const List<String> _preferredCategoryOrder = [
    'Фрукты',
    'Овощи',
    'Молочные продукты',
    'Мясо',
    'Напитки',
    'Бакалея',
  ];

  static const Map<String, String> _sectionTitles = {
    'Фрукты': 'Свежие фрукты',
  };

  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<Product>> _catalog = DatabaseService().watchCatalog();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final grouped = <String, List<Product>>{};
    for (final product in products) {
      final category = product.categoryName.isEmpty ? context.l10n.categoryOther : product.categoryName;
      grouped.putIfAbsent(category, () => []).add(product);
    }

    final orderedKeys = grouped.keys.toList()
      ..sort((left, right) {
        final leftIndex = _preferredCategoryOrder.indexOf(left);
        final rightIndex = _preferredCategoryOrder.indexOf(right);
        if (leftIndex != -1 && rightIndex != -1) return leftIndex.compareTo(rightIndex);
        if (leftIndex != -1) return -1;
        if (rightIndex != -1) return 1;
        return left.compareTo(right);
      });

    return {for (final key in orderedKeys) key: grouped[key]!};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.l10n.navShop,
          style: TextStyle(color: AppPalette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, color: AppPalette.primary, size: 32),
              SizedBox(width: 8),
              Text(context.l10n.splashBrand, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppPalette.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppPalette.textSecondary, size: 20),
              SizedBox(width: 5),
              Text(context.l10n.shopLocation, style: TextStyle(fontSize: 15, color: AppPalette.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
                decoration: InputDecoration(
                  hintText: context.l10n.searchHint,
                  hintStyle: const TextStyle(color: AppPalette.textSecondary, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppPalette.textPrimary),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, color: AppPalette.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            FocusScope.of(context).unfocus();
                          },
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _catalog,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return CenteredMessage(context.l10n.productsLoadFailedConnection, icon: Icons.cloud_off);
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
                }

                final products = snapshot.data!;
                if (products.isEmpty) {
                  return CenteredMessage(context.l10n.noProductsInDatabase);
                }

                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  final results = products.where((product) => product.name.toLowerCase().contains(query)).toList();
                  if (results.isEmpty) {
                    return CenteredMessage(context.l10n.nothingFound);
                  }
                  return ProductGrid(products: results);
                }

                return _buildCatalog(products);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog(List<Product> products) {
    final sections = _groupByCategory(products).entries.toList();
    final popularProducts = (products.where((product) => product.popularity > 0 && !product.isOutOfStock).toList()
          ..sort((left, right) => right.popularity.compareTo(left.popularity)))
        .take(10)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 115,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [AppPalette.primaryDark, AppPalette.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.promoBannerTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.promoBannerCode,
                  style: const TextStyle(color: AppPalette.addAction, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (popularProducts.isNotEmpty)
          _ProductCarousel(title: context.l10n.popular, products: popularProducts),
        for (final section in sections)
          _CategorySection(
            title: context.isEnglish
                ? section.value.first.categoryFor(english: true)
                : (_sectionTitles[section.key] ?? section.key),
            categoryName: section.key,
            products: section.value,
          ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.categoryName,
    required this.products,
  });

  final String title;
  final String categoryName;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return _ProductCarousel(
      title: title,
      products: products,
      onSeeAll: () {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(title: title, categoryNames: [categoryName]),
          ),
        );
      },
    );
  }
}

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({required this.title, required this.products, this.onSeeAll});

  final String title;
  final List<Product> products;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSeeAll,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
                  ),
                ),
                if (onSeeAll != null)
                  Text(context.l10n.seeAll, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppPalette.primary)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: products.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ProductCard(product: products[index], width: 173),
            ),
          ),
        ),
      ],
    );
  }
}
