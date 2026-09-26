import 'package:flutter/material.dart';

import '../../data/catalog_translations.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/parsers.dart';
import '../../utils/product_filters.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/product_filters_sheet.dart';
import '../../widgets/product_image.dart';
import '../../widgets/product_grid.dart';
import '../shop/category_screen.dart';
import '../../l10n/l10n.dart';

class _TileColors {
  const _TileColors(this.background, this.border);

  final Color background;
  final Color border;
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const List<_TileColors> _palette = [
    _TileColors(Color(0x1A53B175), AppPalette.primary),
    _TileColors(Color(0x1AF8A44C), Color(0xFFF8A44C)),
    _TileColors(Color(0x1AF7A593), Color(0xFFF7A593)),
    _TileColors(Color(0x1AD3B0E0), Color(0xFFD3B0E0)),
    _TileColors(Color(0x1AFDE598), Color(0xFFFDE598)),
    _TileColors(Color(0x1AB7DFF5), Color(0xFFB7DFF5)),
  ];

  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _database = DatabaseService();
  late final Stream<List<Product>> _catalog = _database.watchCatalog();
  late final Stream<List<Map<String, dynamic>>> _categories = _database.watchCategories();
  String _searchQuery = '';
  ProductFilters _filters = const ProductFilters();
  List<Product> _searchMatches = const [];

  Future<void> _openFilters() async {
    final result = await showProductFiltersSheet(context, products: _searchMatches, current: _filters);
    if (result != null && mounted) setState(() => _filters = result);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          context.l10n.navCatalog,
          style: TextStyle(color: AppPalette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: context.l10n.filtersTitle,
                              icon: Icon(
                                _filters.isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
                                color: _filters.isActive ? AppPalette.primary : AppPalette.textSecondary,
                              ),
                              onPressed: _openFilters,
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, color: AppPalette.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filters = const ProductFilters();
                                });
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ],
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty ? _buildTiles() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTiles() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _categories,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenteredMessage(context.l10n.categoriesLoadFailed, icon: Icons.cloud_off);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
        }

        final categories = snapshot.data!;
        if (categories.isEmpty) {
          return CenteredMessage(context.l10n.categoriesEmpty);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final name = toStringValue(category['name']);
            final displayName = pickLocalized(
              english: context.isEnglish,
              russian: name,
              englishValue: category['nameEn']?.toString() ?? categoryTranslations[category['id']]?.name,
            );
            final imageUrl = toStringValue(category['imageUrl']);
            final colors = _palette[index % _palette.length];

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(title: displayName, categoryNames: [name]),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.background,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 70, child: ProductImage(url: imageUrl, iconSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Product>>(
      stream: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenteredMessage(context.l10n.searchFailed, icon: Icons.cloud_off);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
        }

        final query = _searchQuery.toLowerCase();
        _searchMatches = snapshot.data!.where((product) {
          return product.name.toLowerCase().contains(query) || product.categoryName.toLowerCase().contains(query);
        }).toList();

        if (_searchMatches.isEmpty) {
          return CenteredMessage(context.l10n.nothingFound);
        }

        final results = _filters.apply(_searchMatches);
        if (results.isEmpty) {
          return CenteredMessage(context.l10n.noProductsForFilters);
        }
        return ProductGrid(products: results);
      },
    );
  }
}
