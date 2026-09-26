import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/product_grid.dart';
import '../../l10n/l10n.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final Stream<List<Product>> _catalog = DatabaseService().watchCatalog();

  void _addAllToCart(List<Product> products) {
    final cart = context.read<CartProvider>();
    var addedCount = 0;
    for (final product in products) {
      if (cart.addProduct(product)) addedCount++;
    }

    showAppSnackBar(
      context,
      addedCount == 0 ? context.l10n.favoritesNothingToAdd : context.l10n.favoritesAdded(addedCount),
      isError: addedCount == 0,
      floating: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<FavoriteProvider>().ids;

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
          context.l10n.favoritesTitle,
          style: TextStyle(color: AppPalette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CenteredMessage(context.l10n.favoritesLoadFailed, icon: Icons.cloud_off);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
          }

          final favorites = snapshot.data!.where((product) => favoriteIds.contains(product.id)).toList();
          if (favorites.isEmpty) {
            return CenteredMessage(context.l10n.favoritesEmpty);
          }

          return Stack(
            children: [
              ProductGrid(
                products: favorites,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                      ),
                      onPressed: () => _addAllToCart(favorites),
                      child: Text(
                        context.l10n.addAllToCart,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
