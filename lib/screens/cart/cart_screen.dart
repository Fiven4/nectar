import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../utils/app_palette.dart';
import '../../utils/pricing.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/product_image.dart';
import 'checkout_bottom_sheet.dart';
import '../../l10n/l10n.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(title: Text(context.l10n.cartTitle)),
      body: Column(
        children: [
          const Divider(thickness: 1, height: 1, color: Color(0xFFE2E2E2)),
          Expanded(
            child: cartItems.isEmpty
                ? CenteredMessage(context.l10n.cartEmpty, icon: Icons.shopping_cart_outlined)
                : ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) =>
                        const Divider(thickness: 1, color: Color(0xFFE2E2E2), indent: 20, endIndent: 20),
                    itemBuilder: (context, index) => _CartRow(item: cartItems[index]),
                  ),
          ),
          if (cartItems.isNotEmpty) _CheckoutPanel(cart: cart),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: ProductImage(url: item.imageUrl, iconSize: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.nameFor(english: context.isEnglish),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFB3B3B3)),
                      onPressed: () => cart.removeItem(item.id),
                    ),
                  ],
                ),
                Text(item.qtyFor(english: context.isEnglish), style: const TextStyle(fontSize: 14, color: AppPalette.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _QuantityButton(icon: Icons.remove, onTap: () => cart.decrement(item.id)),
                        const SizedBox(width: 15),
                        Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 15),
                        _QuantityButton(
                          icon: Icons.add,
                          color: AppPalette.primary,
                          onTap: () {
                            if (!cart.increment(item.id)) {
                              showAppSnackBar(context, context.l10n.notEnoughStock, isError: true);
                            }
                          },
                        ),
                      ],
                    ),
                    Text(
                      '₽${item.lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFFB3B3B3),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (cart.hasPromoCode)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppPalette.lightPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                context.l10n.cartPromoApplied(cart.appliedPromoCode ?? '', cart.discountPercent.toStringAsFixed(0), formatMoney(cart.discountAmount)),
                style: const TextStyle(color: AppPalette.primaryDark, fontWeight: FontWeight.w600),
              ),
            ),
          _SummaryLine(context.l10n.summarySubtotal, formatMoney(cart.subtotalAmount)),
          if (cart.hasPromoCode) _SummaryLine(context.l10n.summaryDiscount, '−${formatMoney(cart.discountAmount)}'),
          _SummaryLine(
            context.l10n.summaryDelivery,
            cart.deliveryAmount == 0
                ? context.l10n.free
                : context.l10n.deliveryFeeWithThreshold(formatMoney(cart.deliveryAmount), freeDeliveryThreshold.toStringAsFixed(0)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
              ),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const CheckoutBottomSheet(),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.checkout,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppPalette.primaryDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '₽${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.textSecondary)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
