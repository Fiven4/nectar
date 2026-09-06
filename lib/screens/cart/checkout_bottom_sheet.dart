import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../account/promo_code_screen.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({
    super.key,
    required this.totalAmount,
  });

  final double totalAmount;

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  final DatabaseService _databaseService = DatabaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String? _selectedAddress;
  String _selectedPaymentMethod = 'Онлайн';
  String? _selectedCard;
  bool _isProcessing = false;

  Future<void> _placeOrder(CartProvider cartProvider) async {
    if (_currentUser == null) {
      _showMessage('Необходимо войти в систему.', isError: true);
      return;
    }

    if (_selectedAddress == null || _selectedAddress!.trim().isEmpty) {
      _showMessage('Выберите адрес доставки.', isError: true);
      return;
    }

    if (_selectedPaymentMethod == 'Онлайн' && (_selectedCard == null || _selectedCard!.isEmpty)) {
      _showMessage('Для онлайн-оплаты выберите сохраненную карту.', isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    try {
      Map<String, dynamic>? promoCodeData;
      if (cartProvider.hasPromoCode && cartProvider.appliedPromoCode != null) {
        promoCodeData = await _databaseService.validatePromoCode(cartProvider.appliedPromoCode!);
      }

      final orderData = await _databaseService.placeOrder(
        userId: _currentUser!.uid,
        orderItems: cartProvider.items.values.map((cartItem) {
          return {
            'id': cartItem.id,
            'name': cartItem.name,
            'price': cartItem.price,
            'quantity': cartItem.quantity,
            'imageUrl': cartItem.imageUrl,
          };
        }).toList(),
        deliveryAddress: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod,
        paymentCard: _selectedPaymentMethod == 'Онлайн' ? _selectedCard : null,
        promoCode: promoCodeData,
      );

      cartProvider.clear();

      if (!mounted) {
        return;
      }

      final navigator = Navigator.of(context);
      final orderNumber =
          orderData['number']?.toString() ?? orderData['id'].toString();

      // Close the sheet first, then present the dialog on the still-mounted
      // navigator context — never reuse this State's context after pop.
      navigator.pop();
      await showDialog<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle, color: AppPalette.primary, size: 72),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Заказ успешно оформлен!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Unbounded',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Номер заказа: $orderNumber\n'
                  'История заказа и дальнейшие уведомления будут доступны в профиле.',
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
                  onPressed: () => Navigator.of(dialogContext).popUntil((route) => route.isFirst),
                  child: const Text('Вернуться в магазин'),
                ),
              ),
            ],
          );
        },
      );
    } on DatabaseOperationException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (e) {
      debugPrint('Order placement error: $e');
      _showMessage('Не удалось оформить заказ.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppPalette.danger : AppPalette.primary,
      ),
    );
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
                const Text(
                  'Оформление заказа',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Unbounded',
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
              stream: _currentUser == null
                  ? const Stream.empty()
                  : _databaseService.watchUserProfile(_currentUser!.uid),
              builder: (context, snapshot) {
                final addresses = List<String>.from(snapshot.data?['addresses'] ?? []);
                final cards = List<String>.from(snapshot.data?['cards'] ?? []);

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
                      title: 'Адрес доставки',
                      items: addresses,
                      selectedValue: _selectedAddress,
                      emptyMessage: 'Добавьте адрес в профиле',
                      onChanged: (value) => setState(() => _selectedAddress = value),
                    ),
                    const Divider(),
                    const Text(
                      'Способ оплаты',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'Онлайн',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      title: const Text('Онлайн'),
                    ),
                    if (_selectedPaymentMethod == 'Онлайн')
                      _buildDropdownRow(
                        title: 'Карта',
                        items: cards,
                        selectedValue: _selectedCard,
                        emptyMessage: 'Добавьте карту в профиле',
                        onChanged: (value) => setState(() => _selectedCard = value),
                      ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'Наличными',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      title: const Text('Наличными'),
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Промокод'),
              subtitle: Text(
                cartProvider.hasPromoCode
                    ? '${cartProvider.appliedPromoCode} (${cartProvider.discountPercent.toStringAsFixed(0)}%)'
                    : 'Не выбран',
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PromoCodeScreen()),
                  );
                },
                child: const Text('Выбрать'),
              ),
            ),
            const Divider(),
            _buildSummaryRow('Сумма товаров', '₽${cartProvider.subtotalAmount.toStringAsFixed(2)}'),
            _buildSummaryRow('Скидка', '₽${cartProvider.discountAmount.toStringAsFixed(2)}'),
            _buildSummaryRow(
              'Итого',
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
                      child: const Text('Разместить заказ'),
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
                            item,
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
