import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/parsers.dart';
import '../../utils/validators.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/l10n.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _promoController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  bool _isApplying = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo(String promoCode) async {
    final formError = Validators.validatePromoCode(promoCode);
    if (formError != null) {
      _showMessage(formError, isError: true);
      return;
    }

    setState(() => _isApplying = true);
    try {
      final promoData = await _databaseService.validatePromoCode(promoCode);
      if (!mounted) {
        return;
      }

      context.read<CartProvider>().applyPromoCode(
            promoData['code'].toString(),
            toDoubleValue(promoData['discountPercent']),
          );
      _promoController.clear();
      _showMessage(
        context.l10n.promoApplied('${promoData['code']}', '${promoData['discountPercent']}'),
      );
    } on DatabaseOperationException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage(context.l10n.promoCheckFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
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

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(context.l10n.menuPromoCodes),
        actions: [
          if (cartProvider.hasPromoCode)
            TextButton(
              onPressed: () {
                cartProvider.clearPromoCode();
                _showMessage(context.l10n.promoRemoved);
              },
              child: Text(context.l10n.reset),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cartProvider.hasPromoCode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppPalette.lightPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  context.l10n.promoCurrentlyApplied(cartProvider.appliedPromoCode ?? '', cartProvider.discountPercent.toStringAsFixed(0)),
                  style: const TextStyle(
                    color: AppPalette.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: context.l10n.valPromoRequired,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppPalette.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: _isApplying
                      ? const Center(child: CircularProgressIndicator(color: AppPalette.primary))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _applyPromo(_promoController.text),
                          child: Text(context.l10n.apply),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.promoAvailableTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPalette.textPrimary,
                fontFamily: 'Unbounded',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _databaseService.watchPromoCodes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppPalette.primary),
                    );
                  }

                  final currentDate = DateTime.now();
                  final activePromoCodes = (snapshot.data ?? []).where((promoCode) {
                    final expirationDate = toDateTimeValue(promoCode['expiresAt']);
                    return promoCode['isActive'] != false && expirationDate.isAfter(currentDate);
                  }).toList();

                  if (activePromoCodes.isEmpty) {
                    return Center(
                      child: Text(context.l10n.promoNoneActive),
                    );
                  }

                  return ListView.separated(
                    itemCount: activePromoCodes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final promoCode = activePromoCodes[index];
                      final expirationDate = toDateTimeValue(promoCode['expiresAt']);
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppPalette.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppPalette.lightPrimary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.local_offer_outlined, color: AppPalette.primaryDark),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promoCode['code'].toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.l10n.promoDiscountUntil('${promoCode['discountPercent']}', formatDate(expirationDate)),
                                    style: const TextStyle(color: AppPalette.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _applyPromo(promoCode['code'].toString()),
                              child: Text(context.l10n.choose),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
