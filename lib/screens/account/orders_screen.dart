import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/parsers.dart';
import '../../utils/pricing.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/l10n.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _itemName(Map<String, dynamic> item, BuildContext context) {
    return pickLocalized(
      english: context.isEnglish,
      russian: item['name']?.toString() ?? context.l10n.itemDefaultName,
      englishValue: item['nameEn']?.toString(),
    );
  }

  int _getStep(String statusId) {
    switch (statusId) {
      case 'new':
      case 'processing':
        return 0;
      case 'assigned':
      case 'delivering':
        return 1;
      case 'delivered':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(title: Text(context.l10n.myOrders)),
      body: user == null
          ? Center(child: Text(context.l10n.ordersSignInRequired))
          : StreamBuilder<List<Map<String, dynamic>>>(
        stream: databaseService.watchOrdersForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.ordersLoadFailed));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
          }

          final orders = snapshot.data!.where((order) => order['hiddenByUser'] != true).toList();
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: AppPalette.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),
                  Text(context.l10n.ordersEmptyTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181B19))),
                  const SizedBox(height: 10),
                  Text(context.l10n.ordersEmptyBody, style: TextStyle(color: AppPalette.textSecondary)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(context.l10n.startShopping, style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E2E2), thickness: 1, height: 30),
            itemBuilder: (context, index) {
              final orderData = orders[index];
              final totalAmount = (orderData['totalAmount'] as num?)?.toDouble() ?? 0;
              final statusId = orderData['statusId']?.toString() ?? 'new';
              final isCancelled = statusId == 'cancelled';
              final currentStep = _getStep(statusId);
              final orderItems = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
              final createdAt = orderData['createdAt'];
              final createdAtDate = createdAt == null ? null : toDateTimeValue(createdAt);
              final userConfirmed = orderData['userConfirmed'] == true;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppPalette.border),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  title: Text(
                    orderData['number']?.toString() ??
                        context.l10n.orderNumberFallback((orderData['id']?.toString() ?? '000000').padRight(6, '0').substring(0, 6).toUpperCase()),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      if (isCancelled)
                        Text(context.l10n.orderCancelled, style: TextStyle(color: AppPalette.danger, fontWeight: FontWeight.bold))
                      else
                        Row(
                          children: [
                            _buildStepItem(context.l10n.stepCreated, currentStep >= 0),
                            _buildLine(currentStep >= 1),
                            _buildStepItem(context.l10n.stepWithCourier, currentStep >= 1),
                            _buildLine(currentStep >= 2),
                            _buildStepItem(context.l10n.stepDelivered, currentStep >= 2),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (createdAtDate != null)
                        Text(
                          formatDate(createdAtDate),
                          style: const TextStyle(color: AppPalette.textSecondary),
                        ),
                    ],
                  ),
                  children: [
                    const Divider(),
                    _OrderInfoRow(label: context.l10n.labelAddress, value: orderData['address']?.toString() ?? context.l10n.notSpecified),
                    if ((orderData['deliverySlot']?.toString() ?? '').isNotEmpty)
                      _OrderInfoRow(label: context.l10n.deliveryTime, value: orderData['deliverySlot'].toString()),
                    _OrderInfoRow(label: context.l10n.orderInfoPayment, value: paymentMethodLabel(orderData['paymentMethod']?.toString(), context.l10n)),
                    if ((orderData['courierName']?.toString() ?? '').isNotEmpty)
                      _OrderInfoRow(label: context.l10n.orderInfoCourier, value: orderData['courierName'].toString()),
                    if ((orderData['courierPhone']?.toString() ?? '').isNotEmpty)
                      _OrderInfoRow(label: context.l10n.orderInfoCourierPhone, value: orderData['courierPhone'].toString()),
                    if (toDoubleValue(orderData['deliveryAmount']) > 0)
                      _OrderInfoRow(label: context.l10n.summaryDelivery, value: formatMoney(toDoubleValue(orderData['deliveryAmount']))),
                    if (toDoubleValue(orderData['discountAmount']) > 0)
                      _OrderInfoRow(label: context.l10n.summaryDiscount, value: '−${formatMoney(toDoubleValue(orderData['discountAmount']))}'),
                    _OrderInfoRow(label: context.l10n.total, value: '₽${totalAmount.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    ...orderItems.map((orderItem) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_itemName(orderItem, context)),
                        subtitle: Text(context.l10n.quantityLabel('${orderItem['quantity'] ?? 0}')),
                        trailing: Text('₽${((orderItem['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}'),
                      );
                    }),
                    if (isCancelled || currentStep >= 2)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            try {
                              await databaseService.hideOrderForUser(orderData['id'].toString());
                            } catch (_) {
                              if (context.mounted) {
                                showAppSnackBar(context, context.l10n.hideOrderFailed, isError: true);
                              }
                            }
                          },
                          icon: const Icon(Icons.archive_outlined),
                          label: Text(context.l10n.hideOrder),
                        ),
                      ),
                    if (!isCancelled && currentStep >= 1 && currentStep < 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: userConfirmed
                              ? Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppPalette.lightPrimary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.l10n.orderConfirmedWaiting,
                              style: TextStyle(color: AppPalette.primaryDark, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              try {
                                await databaseService.confirmOrderReceived(orderData['id'].toString());
                                if (context.mounted) {
                                  showAppSnackBar(context, context.l10n.orderConfirmedToast);
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  showAppSnackBar(context, context.l10n.orderConfirmFailed, isError: true);
                                }
                              }
                            },
                            child: Text(context.l10n.orderConfirmButton),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStepItem(String title, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? AppPalette.primary : const Color(0xFFE2E2E2),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? AppPalette.textPrimary : const Color(0xFFB3B3B3),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        height: 3,
        color: isActive ? AppPalette.primary : const Color(0xFFE2E2E2),
      ),
    );
  }

}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.textSecondary)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}