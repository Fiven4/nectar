import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database_service.dart';
import '../../utils/app_palette.dart';
import '../../utils/validators.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/input_dialog.dart';
import '../../l10n/l10n.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final DatabaseService _databaseService = DatabaseService();

  void _showAddCardDialog() {
    final userId = user?.uid;
    if (userId == null) return;

    showInputDialog(
      context,
      title: context.l10n.addCardTitle,
      hint: context.l10n.addCardHint,
      keyboardType: TextInputType.number,
      maxLength: 16,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: Validators.validateCardNumber,
      onSubmit: (value) => _databaseService.addPaymentCard(userId: userId, cardNumber: value),
    );
  }

  Future<void> _removeCard(String card) async {
    final userId = user?.uid;
    if (userId == null) return;

    try {
      await _databaseService.removePaymentCard(userId: userId, maskedCardNumber: card);
    } catch (_) {
      if (mounted) showAppSnackBar(context, context.l10n.cardRemoveFailed, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.l10n.menuPaymentMethods),
      ),
      body: user == null
          ? Center(child: Text(context.l10n.cardsSignIn))
          : StreamBuilder<Map<String, dynamic>?>(
        stream: _databaseService.watchUserProfile(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppPalette.primary));
          }

          final cards = List<String>.from(snapshot.data?['cards'] ?? []);

          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined, size: 80, color: AppPalette.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),
                  Text(context.l10n.cardsEmptyTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181B19))),
                  const SizedBox(height: 10),
                  Text(context.l10n.cardsEmptyBody, style: TextStyle(color: AppPalette.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, size: 40, color: Color(0xFF181B19)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(card, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeCard(card),
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
        onPressed: _showAddCardDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(context.l10n.addCardTitle, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}