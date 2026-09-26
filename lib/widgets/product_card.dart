import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../screens/shop/product_detail_screen.dart';
import '../utils/app_palette.dart';
import 'app_snackbar.dart';
import 'product_image.dart';
import '../l10n/l10n.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.width, this.addButtonSize = 45});

  final Product product;
  final double? width;
  final double addButtonSize;

  void _addToCart(BuildContext context) {
    FocusScope.of(context).unfocus();
    final added = context.read<CartProvider>().addProduct(product);
    showAppSnackBar(
      context,
      added ? context.l10n.addedToCart(product.nameFor(english: context.isEnglish)) : context.l10n.noMoreStockNamed(product.nameFor(english: context.isEnglish)),
      icon: added ? Icons.shopping_bag : Icons.info_outline,
      isError: !added,
      floating: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;
    final isFavorite = context.select<FavoriteProvider, bool>((favorites) => favorites.isFavorite(product.id));
    final titleColor = isOutOfStock ? Colors.grey : AppPalette.textPrimary;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(child: ProductImage(url: product.imageUrl, dimmed: isOutOfStock)),
                  if (isOutOfStock)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.l10n.outOfStock,
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (isFavorite)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.favorite, color: AppPalette.primary, size: 20),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              product.nameFor(english: context.isEnglish),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              product.qtyFor(english: context.isEnglish),
              style: const TextStyle(fontSize: 14, color: AppPalette.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${product.price.toStringAsFixed(0)} ₽',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: isOutOfStock ? null : () => _addToCart(context),
                  child: Container(
                    width: addButtonSize,
                    height: addButtonSize,
                    decoration: BoxDecoration(
                      color: isOutOfStock ? const Color(0xFFE2E2E2) : AppPalette.primary,
                      borderRadius: BorderRadius.circular(addButtonSize * 0.38),
                    ),
                    child: Icon(Icons.add, color: isOutOfStock ? Colors.grey : Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
