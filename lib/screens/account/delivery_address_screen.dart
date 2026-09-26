import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/validators.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/input_dialog.dart';
import '../../l10n/l10n.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final DatabaseService _databaseService = DatabaseService();

  void _showAddAddressDialog() {
    final userId = user?.uid;
    if (userId == null) return;

    showInputDialog(
      context,
      title: context.l10n.addAddressTitle,
      hint: context.l10n.addAddressHint,
      maxLines: 2,
      maxLength: 300,
      validator: (value) => Validators.validateRequiredText(value, fieldName: context.l10n.labelAddress, maxLength: 300),
      onSubmit: (value) => _databaseService.addDeliveryAddress(userId: userId, address: value),
    );
  }

  Future<void> _removeAddress(String address) async {
    final userId = user?.uid;
    if (userId == null) return;

    try {
      await _databaseService.removeDeliveryAddress(userId: userId, address: address);
    } catch (_) {
      if (mounted) showAppSnackBar(context, context.l10n.addressRemoveFailed, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.l10n.menuDeliveryAddress),
      ),
      body: user == null
          ? Center(child: Text(context.l10n.addressesSignIn))
          : StreamBuilder<Map<String, dynamic>?>(
        stream: _databaseService.watchUserProfile(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
          }

          final addresses = List<String>.from(snapshot.data?['addresses'] ?? []);

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 80, color: AppPalette.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),
                  Text(context.l10n.addressesEmptyTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181B19))),
                  const SizedBox(height: 10),
                  Text(context.l10n.addressesEmptyBody, style: TextStyle(color: AppPalette.textSecondary), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppPalette.primary),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(address, style: const TextStyle(fontSize: 16)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeAddress(address),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppPalette.primary,
        onPressed: _showAddAddressDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(context.l10n.add, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
