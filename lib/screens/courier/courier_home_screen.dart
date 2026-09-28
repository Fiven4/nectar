import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/courier_orders.dart';
import '../../utils/order_status.dart';
import '../../utils/parsers.dart';
import '../../utils/pricing.dart';
import '../../widgets/app_snackbar.dart';
import '../account/account_screen.dart';
import '../../l10n/l10n.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final Set<String> _busyOrderIds = {};
  late final Stream<List<Map<String, dynamic>>>? _assignedOrders = FirebaseAuth.instance.currentUser == null
      ? null
      : _databaseService.watchAssignedOrders(FirebaseAuth.instance.currentUser!.uid);
  late final Stream<List<Map<String, dynamic>>> _availableOrders = _databaseService.watchAvailableOrders();

  Future<void> _changeStatus(String orderId, String statusId, String courierId) async {
    setState(() => _busyOrderIds.add(orderId));
    try {
      await _databaseService.updateOrder(orderId: orderId, statusId: statusId, courierId: courierId);
    } catch (_) {
      if (mounted) showAppSnackBar(context, context.l10n.courierUpdateFailed, isError: true);
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(orderId));
    }
  }

  /// Завершение доставки необратимо (заказ закрывается), поэтому просим подтверждение.
  Future<void> _confirmComplete(Map<String, dynamic> order, String courierId) async {
    final l10n = context.l10n;
    final number = order['number']?.toString() ?? order['id'].toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.courierConfirmTitle),
        content: Text(l10n.courierConfirmBody(number)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.courierComplete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _changeStatus(order['id'].toString(), 'delivered', courierId);
    }
  }

  Future<void> _claim(String orderId, String courierId) async {
    setState(() => _busyOrderIds.add(orderId));
    try {
      await _databaseService.claimOrder(orderId: orderId, courierId: courierId);
      if (mounted) showAppSnackBar(context, context.l10n.courierClaimed);
    } on DatabaseOperationException catch (error) {
      if (mounted) showAppSnackBar(context, error.message, isError: true);
    } catch (_) {
      if (mounted) showAppSnackBar(context, context.l10n.courierUpdateFailed, isError: true);
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(orderId));
    }
  }

  Future<void> _confirmRelease(Map<String, dynamic> order, String courierId) async {
    final l10n = context.l10n;
    final orderId = order['id'].toString();
    final number = order['number']?.toString() ?? orderId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.courierReleaseTitle),
        content: Text(l10n.courierReleaseBody(number)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.warning, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.courierRelease),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyOrderIds.add(orderId));
    try {
      await _databaseService.releaseOrder(orderId: orderId, courierId: courierId);
      if (mounted) showAppSnackBar(context, l10n.courierReleased);
    } on DatabaseOperationException catch (error) {
      if (mounted) showAppSnackBar(context, error.message, isError: true);
    } catch (_) {
      if (mounted) showAppSnackBar(context, l10n.courierUpdateFailed, isError: true);
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(orderId));
    }
  }

  Future<void> _copyPhone(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) showAppSnackBar(context, context.l10n.courierPhoneCopied);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(body: Center(child: Text(context.l10n.courierNotSignedIn)));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppPalette.background,
        appBar: AppBar(
          title: Text(context.l10n.courierTitle),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
              },
              icon: const Icon(Icons.person_outline),
            ),
          ],
          bottom: TabBar(
            labelColor: AppPalette.primary,
            indicatorColor: AppPalette.primary,
            tabs: [
              Tab(text: context.l10n.courierTabMine),
              Tab(text: context.l10n.courierTabAvailable),
            ],
          ),
        ),
        body: TabBarView(children: [_buildMineTab(currentUser.uid), _buildAvailableTab(currentUser.uid)]),
      ),
    );
  }

  Widget _buildMineTab(String courierId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _assignedOrders,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.ordersLoadFailed));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
        }

        final assignedOrders = snapshot.data!;
        if (assignedOrders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.courierNoOrders, textAlign: TextAlign.center),
            ),
          );
        }

        final groups = groupCourierOrders(assignedOrders);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(context.l10n.courierActiveTitle),
            if (groups.active.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(context.l10n.courierNoActive, style: const TextStyle(color: AppPalette.textSecondary)),
              ),
            for (final order in groups.active) ...[_buildOrderCard(order, courierId), const SizedBox(height: 12)],
            if (groups.history.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionTitle(context.l10n.courierHistoryTitle),
              for (final order in groups.history) ...[_buildOrderCard(order, courierId), const SizedBox(height: 12)],
            ],
          ],
        );
      },
    );
  }

  Widget _buildAvailableTab(String courierId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _availableOrders,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.ordersLoadFailed));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
        }

        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.courierNoAvailable, textAlign: TextAlign.center),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final order in orders) ...[
              _buildOrderCard(order, courierId, isPool: true),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String courierId, {bool isPool = false}) {
    final l10n = context.l10n;
    final statusId = order['statusId']?.toString() ?? 'new';
    final statusName = orderStatusLabel(statusId, order['statusName']?.toString(), l10n);
    final orderId = order['id'].toString();
    final isBusy = _busyOrderIds.contains(orderId);
    final phone = order['customerPhone']?.toString() ?? '';
    final items = List<Map<String, dynamic>>.from(order['items'] ?? const []);
    final totalAmount = toDoubleValue(order['totalAmount']);
    final isCash = (order['paymentMethod']?.toString() ?? '') == 'Наличными';
    final isFinished = isFinishedOrder(statusId);

    return Opacity(
      opacity: isFinished ? 0.75 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['number']?.toString() ?? l10n.courierOrderDefault,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              order['address']?.toString() ?? l10n.courierAddressMissing,
              style: const TextStyle(color: AppPalette.textSecondary),
            ),
            if ((order['deliverySlot']?.toString() ?? '').isNotEmpty)
              Text(
                l10n.courierSlot(deliverySlotLabel(order['deliverySlot'].toString(), l10n)),
                style: const TextStyle(color: AppPalette.textSecondary),
              ),
            const SizedBox(height: 8),
            if (!isPool)
              Text(
                l10n.courierCustomer(order['customerName']?.toString() ?? '—', ''),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            if (phone.isNotEmpty && !isPool)
              InkWell(
                onTap: () => _copyPhone(phone),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined, size: 18, color: AppPalette.primary),
                      const SizedBox(width: 6),
                      Text(
                        phone,
                        style: const TextStyle(color: AppPalette.primary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy, size: 14, color: AppPalette.textSecondary),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            for (final item in items)
              Text(
                '• ${pickLocalized(english: context.isEnglish, russian: item['name']?.toString() ?? '', englishValue: item['nameEn']?.toString())} × ${item['quantity']}',
                style: const TextStyle(color: AppPalette.textSecondary),
              ),
            const SizedBox(height: 8),
            Text(
              l10n.courierPayment(paymentMethodLabel(order['paymentMethod']?.toString(), l10n)),
              style: const TextStyle(color: AppPalette.textSecondary),
            ),
            Text(l10n.courierTotal(formatMoney(totalAmount)), style: const TextStyle(fontWeight: FontWeight.w600)),
            if (isCash && !isFinished) ...[
              const SizedBox(height: 8),
              Text(
                l10n.courierCashDue(formatMoney(totalAmount)),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppPalette.warning),
              ),
            ],
            const SizedBox(height: 8),
            if (!isPool)
              Text(
                l10n.courierStatus(statusName),
                style: TextStyle(
                  color: statusId == 'cancelled' ? AppPalette.danger : AppPalette.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (statusId == 'cancelled')
              Text(l10n.courierCancelledNote, style: const TextStyle(color: AppPalette.textSecondary)),
            if (isPool) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white),
                onPressed: isBusy ? null : () => _claim(orderId, courierId),
                icon: const Icon(Icons.add_task),
                label: Text(l10n.courierClaim),
              ),
            ] else if (!isFinished) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (canStartDelivery(statusId))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.warning,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isBusy ? null : () => _changeStatus(orderId, 'delivering', courierId),
                      child: Text(l10n.courierStart),
                    ),
                  if (canCompleteDelivery(statusId))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isBusy ? null : () => _confirmComplete(order, courierId),
                      child: Text(l10n.courierComplete),
                    ),
                  if (statusId == 'assigned')
                    OutlinedButton(
                      onPressed: isBusy ? null : () => _confirmRelease(order, courierId),
                      child: Text(l10n.courierRelease),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
      ),
    );
  }
}
