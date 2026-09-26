import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/pricing.dart';
import '../../widgets/app_snackbar.dart';
import '../account/promo_code_screen.dart';
import '../../l10n/l10n.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  static const String _paymentOnline = 'Онлайн';
  static const String _paymentCash = 'Наличными';

  final DatabaseService _databaseService = DatabaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late final Stream<Map<String, dynamic>?>? _profileStream =
      _currentUser == null ? null : _databaseService.watchUserProfile(_currentUser.uid);

  String? _selectedAddress;
  String _selectedSlot = deliverySlots.first;
  String _selectedPaymentMethod = _paymentOnline;
  String? _selectedCard;
  bool _isProcessing = false;

  Future<void> _placeOrder(CartProvider cartProvider) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      _showMessage(context.l10n.checkoutSignInRequired, isError: true);
      return;
    }

    final address = _selectedAddress?.trim() ?? '';
    if (address.isEmpty) {
      _showMessage(context.l10n.checkoutSelectAddress, isError: true);
      return;
    }

    final card = _selectedCard;
    if (_selectedPaymentMethod == _paymentOnline && (card == null || card.isEmpty)) {
      _showMessage(context.l10n.checkoutSelectCard, isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    try {
      Map<String, dynamic>? promoCodeData;
      final appliedPromoCode = cartProvider.appliedPromoCode;
      if (cartProvider.hasPromoCode && appliedPromoCode != null) {
        promoCodeData = await _databaseService.validatePromoCode(appliedPromoCode);
      }

      final orderData = await _databaseService.placeOrder(
        userId: currentUser.uid,
        orderItems: cartProvider.items.values.map((cartItem) {
          return {
            'id': cartItem.id,
            'name': cartItem.name,
            'price': cartItem.price,
            'quantity': cartItem.quantity,
            'imageUrl': cartItem.imageUrl,
          };
        }).toList(),
        deliveryAddress: address,
        paymentMethod: _selectedPaymentMethod,
        paymentCard: _selectedPaymentMethod == _paymentOnline ? card : null,
        deliverySlot: _selectedSlot,
        promoCode: promoCodeData,
      );

      cartProvider.clear();

      if (!mounted) {
        return;
      }

      final navigator = Navigator.of(context);
      final orderNumber = orderData['number']?.toString() ?? orderData['id'].toString();

      // Закрываем шторку, а диалог показываем в контексте навигатора: контекст
      // этого State после pop использовать нельзя.
      navigator.pop();
      await showDialog<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (dialogContext) => _OrderSuccessDialog(orderNumber: orderNumber),
      );
    } on DatabaseOperationException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      debugPrint('Order placement error: $error');
      _showMessage(AppLocale.strings.checkoutFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    showAppSnackBar(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.checkoutTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Unbounded',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<Map<String, dynamic>?>(
              stream: _profileStream,
              builder: (context, snapshot) {
                final addresses = List<String>.from(snapshot.data?['addresses'] ?? const []);
                final cards = List<String>.from(snapshot.data?['cards'] ?? const []);

                if (_selectedAddress == null && addresses.isNotEmpty) {
                  _selectedAddress = addresses.first;
                }
                if (_selectedCard == null && cards.isNotEmpty) {
                  _selectedCard = cards.first;
                }
                if (_selectedAddress != null && !addresses.contains(_selectedAddress)) {
                  _selectedAddress = addresses.isEmpty ? null : addresses.first;
                }
                if (_selectedCard != null && !cards.contains(_selectedCard)) {
                  _selectedCard = cards.isEmpty ? null : cards.first;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    _buildDropdownRow(
                      title: context.l10n.menuDeliveryAddress,
                      items: addresses,
                      selectedValue: _selectedAddress,
                      emptyMessage: context.l10n.addAddressInProfile,
                      onChanged: (value) => setState(() => _selectedAddress = value),
                    ),
                    const Divider(),
                    _buildDropdownRow(
                      title: context.l10n.deliveryTime,
                      items: deliverySlots,
                      selectedValue: _selectedSlot,
                      emptyMessage: '',
                      labelOf: (slot) => deliverySlotLabel(slot, context.l10n),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedSlot = value);
                      },
                    ),
                    const Divider(),
                    Text(
                      context.l10n.paymentMethodTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    RadioGroup<String>(
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedPaymentMethod = value);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: _paymentOnline,
                            title: Text(context.l10n.paymentOnline),
                          ),
                          if (_selectedPaymentMethod == _paymentOnline)
                            _buildDropdownRow(
                              title: context.l10n.cardLabel,
                              items: cards,
                              selectedValue: _selectedCard,
                              emptyMessage: context.l10n.addCardInProfile,
                              onChanged: (value) => setState(() => _selectedCard = value),
                            ),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: _paymentCash,
                            title: Text(context.l10n.paymentCash),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.promoCodeLabel),
              subtitle: Text(
                cartProvider.hasPromoCode
                    ? '${cartProvider.appliedPromoCode} (${cartProvider.discountPercent.toStringAsFixed(0)}%)'
                    : context.l10n.promoNotSelected,
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PromoCodeScreen()),
                  );
                },
                child: Text(context.l10n.choose),
              ),
            ),
            const Divider(),
            _buildSummaryRow(context.l10n.summaryItemsTotal, '₽${cartProvider.subtotalAmount.toStringAsFixed(2)}'),
            _buildSummaryRow(context.l10n.summaryDiscount, '−₽${cartProvider.discountAmount.toStringAsFixed(2)}'),
            _buildSummaryRow(
              context.l10n.summaryDelivery,
              cartProvider.deliveryAmount == 0 ? context.l10n.free : '₽${cartProvider.deliveryAmount.toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              context.l10n.total,
              '₽${cartProvider.totalAmount.toStringAsFixed(2)}',
              emphasize: true,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator(color: AppPalette.primary))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _placeOrder(cartProvider),
                      child: Text(context.l10n.placeOrder),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required String emptyMessage,
    required ValueChanged<String?> onChanged,
    String Function(String)? labelOf,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: items.isEmpty
                ? Text(
                    emptyMessage,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppPalette.danger),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedValue,
                      items: items.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            labelOf?.call(item) ?? item,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppPalette.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 18 : 16,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
              color: AppPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSuccessDialog extends StatelessWidget {
  const _OrderSuccessDialog({required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Icon(Icons.check_circle, color: AppPalette.primary, size: 72),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.orderSuccessTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Unbounded'),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.orderSuccessBody(orderNumber),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppPalette.textSecondary, height: 1.5),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(context.l10n.backToShop),
          ),
        ),
      ],
    );
  }
}
