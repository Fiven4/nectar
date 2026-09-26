import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/app_palette.dart';
import '../../utils/parsers.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/product_image.dart';
import '../../l10n/l10n.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get product => widget.product;

  int get _maxQuantity => product.stock.clamp(1, CartProvider.maxQuantityPerItem);

  void _share() {
    final shareText = context.l10n.shareMessage(
      product.nameFor(english: context.isEnglish),
      product.price.toStringAsFixed(0),
      'https://nectar.app/product/${product.id}',
    );
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    var addedCount = 0;
    for (var i = 0; i < _quantity; i++) {
      if (cart.addProduct(product)) addedCount++;
    }

    showAppSnackBar(
      context,
      addedCount == 0
          ? context.l10n.notEnoughStock
          : addedCount < _quantity
              ? context.l10n.addedPartial(addedCount)
              : context.l10n.addedQuantityToCart(product.nameFor(english: context.isEnglish), addedCount),
      icon: addedCount > 0 ? Icons.shopping_bag : Icons.info_outline,
      isError: addedCount == 0,
      floating: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F3F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: _share,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F3F2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: InteractiveViewer(minScale: 1, maxScale: 4, child: ProductImage(url: product.imageUrl, iconSize: 100)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.nameFor(english: context.isEnglish),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
                          ),
                        ),
                        Consumer<FavoriteProvider>(
                          builder: (context, favorites, child) {
                            final isFavorite = favorites.isFavorite(product.id);
                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? AppPalette.primary : AppPalette.textSecondary,
                                size: 28,
                              ),
                              onPressed: () => favorites.toggle(product.id),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.qtyFor(english: context.isEnglish),
                          style: const TextStyle(fontSize: 16, color: AppPalette.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOutOfStock ? const Color(0xFFFDECEA) : AppPalette.lightPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isOutOfStock ? context.l10n.outOfStock : context.l10n.stockLeft(product.stock),
                            style: TextStyle(
                              color: isOutOfStock ? AppPalette.danger : AppPalette.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '${product.price.toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
                    ),
                    const SizedBox(height: 30),
                    const Divider(thickness: 1, color: Color(0xFFE2E2E2)),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        iconColor: AppPalette.textPrimary,
                        collapsedIconColor: AppPalette.textPrimary,
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          context.l10n.productDescriptionTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product.descriptionFor(english: context.isEnglish).isEmpty
                                  ? context.l10n.noDescription
                                  : product.descriptionFor(english: context.isEnglish),
                              style: const TextStyle(fontSize: 14, color: AppPalette.textSecondary, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, color: Color(0xFFE2E2E2)),
                    _ProductFacts(product: product),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  if (!isOutOfStock) ...[
                    _QuantitySelector(
                      quantity: _quantity,
                      onDecrement: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      onIncrement: _quantity < _maxQuantity ? () => setState(() => _quantity++) : null,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.primary,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                        ),
                        onPressed: isOutOfStock ? null : _addToCart,
                        child: Text(
                          isOutOfStock ? context.l10n.soldOut : context.l10n.addToCartWithPrice((product.price * _quantity).toStringAsFixed(0)),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.quantity, this.onDecrement, this.onIncrement});

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove)),
          SizedBox(
            width: 28,
            child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          IconButton(onPressed: onIncrement, icon: const Icon(Icons.add, color: AppPalette.primary)),
        ],
      ),
    );
  }
}

class _ProductFacts extends StatelessWidget {
  const _ProductFacts({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (product.brand.isNotEmpty) MapEntry(context.l10n.factManufacturer, product.brand),
      if (product.country.isNotEmpty) MapEntry(context.l10n.factCountry, product.countryFor(english: context.isEnglish)),
      if (product.expiryDate != null) MapEntry(context.l10n.factBestBefore, formatDate(product.expiryDate!)),
      if (product.compositionFor(english: context.isEnglish).isNotEmpty) MapEntry(context.l10n.factComposition, product.compositionFor(english: context.isEnglish)),
    ];

    if (rows.isEmpty && !product.hasNutrition) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          context.l10n.productFactsTitle,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
        ),
        const SizedBox(height: 8),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: Text(row.key, style: const TextStyle(color: AppPalette.textSecondary))),
                Expanded(flex: 6, child: Text(row.value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        if (product.hasNutrition) ...[
          const SizedBox(height: 16),
          Text(
            context.l10n.nutritionTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _NutritionCell(label: context.l10n.nutritionCalories, value: product.calories),
              _NutritionCell(label: context.l10n.nutritionProteins, value: product.proteins),
              _NutritionCell(label: context.l10n.nutritionFats, value: product.fats),
              _NutritionCell(label: context.l10n.nutritionCarbs, value: product.carbs),
            ],
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _NutritionCell extends StatelessWidget {
  const _NutritionCell({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppPalette.lightPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.primaryDark),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
          ],
        ),
      ),
    );
  }
}
