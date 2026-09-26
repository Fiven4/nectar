import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../utils/pricing.dart';
import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../l10n/l10n.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  Future<void> _confirmAndReseed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.reseedTitle),
        content: Text(context.l10n.reseedBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.reseedConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    messenger.showSnackBar(SnackBar(content: Text(l10n.reseedLoading)));
    try {
      await _dbService.reseedCatalog();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reseedDone)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.reseedFailed),
        backgroundColor: AppPalette.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.eco, color: AppPalette.primary, size: 40),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: AppPalette.danger),
                    onPressed: () => AuthService().logout(),
                    tooltip: context.l10n.logout,
                  ),
                ),
              ),
            ),
            selectedIconTheme: const IconThemeData(color: AppPalette.primary),
            selectedLabelTextStyle: TextStyle(color: AppPalette.primary, fontWeight: FontWeight.bold),
            unselectedIconTheme: IconThemeData(color: AppPalette.textSecondary),
            unselectedLabelTextStyle: TextStyle(color: AppPalette.textSecondary),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text(context.l10n.adminHome)),
              NavigationRailDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: Text(context.l10n.menuOrders)),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppPalette.border),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) return _buildDashboardTab();
    if (_selectedIndex == 1) return _buildOrdersTab();
    return Center(child: Text(context.l10n.sectionInDevelopment));
  }

  Widget _buildDashboardTab() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.adminDashboardTitle, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppPalette.textPrimary)),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildStatCard(context.l10n.adminNewOrders, context.l10n.adminActive, Icons.shopping_basket, AppPalette.primary),
              const SizedBox(width: 20),
              _buildStatCard(context.l10n.adminProducts, context.l10n.adminInCatalog, Icons.inventory, AppPalette.warning),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppPalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.adminQuickActions, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: _confirmAndReseed,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.adminReseedButton),
                ),
                const SizedBox(height: 10),
                Text(context.l10n.adminReseedHint, style: TextStyle(color: AppPalette.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.adminOrdersTitle, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppPalette.textPrimary)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dbService.watchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) return Center(child: Text(context.l10n.adminNoOrders, style: TextStyle(fontSize: 18, color: AppPalette.textSecondary)));

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderAdminCard(order: order, dbService: _dbService);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppPalette.textSecondary, fontSize: 16)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: AppPalette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderAdminCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final DatabaseService dbService;

  const _OrderAdminCard({required this.order, required this.dbService});

  @override
  State<_OrderAdminCard> createState() => _OrderAdminCardState();
}

class _OrderAdminCardState extends State<_OrderAdminCard> {
  List<Map<String, dynamic>> _couriers = [];
  String? _selectedCourierId;
  String? _selectedStatusId;

  @override
  void initState() {
    super.initState();
    _selectedCourierId = widget.order['courierId'];
    _selectedStatusId = widget.order['statusId'];
    _loadCouriers();
  }

  Future<void> _loadCouriers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'courier').get();
      if (!mounted) return;
      setState(() {
        _couriers = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc.data()['displayName'] ?? context.l10n.adminNoName}).toList();
      });
    } catch (_) {
      // Список курьеров останется пустым; назначение можно повторить после перезагрузки.
    }
  }

  Future<void> _saveChanges() async {
    if ((_selectedStatusId == 'delivering' || _selectedStatusId == 'delivered') && _selectedCourierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminCourierRequired),
          backgroundColor: AppPalette.danger,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_selectedStatusId == 'new' && _selectedCourierId != null) {
      _selectedStatusId = 'assigned';
    }

    try {
      await widget.dbService.updateOrder(
        orderId: widget.order['id'],
        statusId: _selectedStatusId ?? 'new',
        courierId: _selectedCourierId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.adminOrderUpdated), backgroundColor: AppPalette.primary)
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.adminOrderUpdateFailed), backgroundColor: AppPalette.danger)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.order['number'] ?? context.l10n.courierOrderDefault, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(context.l10n.adminCustomer('${widget.order['customerName'] ?? ''}')),
                  Text(context.l10n.adminAddress('${widget.order['address'] ?? ''}')),
                  if ((widget.order['customerPhone']?.toString() ?? '').isNotEmpty)
                    Text(context.l10n.adminPhone('${widget.order['customerPhone'] ?? ''}')),
                  if ((widget.order['deliverySlot']?.toString() ?? '').isNotEmpty)
                    Text(context.l10n.adminDeliverySlot(deliverySlotLabel(widget.order['deliverySlot'].toString(), context.l10n))),
                  Text(context.l10n.adminAmount('${widget.order['totalAmount'] ?? ''}'), style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.primaryDark)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.adminCourierLabel, style: TextStyle(fontSize: 12, color: AppPalette.textSecondary)),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text(context.l10n.notAssigned),
                    value: _selectedCourierId,
                    items: [
                      DropdownMenuItem(value: null, child: Text(context.l10n.notAssigned)),
                      ..._couriers.map((c) => DropdownMenuItem(value: c['id'] as String, child: Text(c['name'] as String))),
                    ],
                    onChanged: (val) => setState(() => _selectedCourierId = val),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.adminStatusLabel, style: TextStyle(fontSize: 12, color: AppPalette.textSecondary)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedStatusId,
                    items: [
                      DropdownMenuItem(value: 'new', child: Text(context.l10n.statusNew)),
                      DropdownMenuItem(value: 'processing', child: Text(context.l10n.statusProcessing)),
                      DropdownMenuItem(value: 'assigned', child: Text(context.l10n.statusAssigned)),
                      DropdownMenuItem(value: 'delivering', child: Text(context.l10n.statusDelivering)),
                      DropdownMenuItem(value: 'delivered', child: Text(context.l10n.statusDelivered)),
                      DropdownMenuItem(value: 'cancelled', child: Text(context.l10n.statusCancelled)),
                    ],
                    onChanged: (val) => setState(() => _selectedStatusId = val),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
              onPressed: _saveChanges,
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}