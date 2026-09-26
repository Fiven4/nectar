import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../utils/app_palette.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text(context.l10n.menuHelp, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.l10n.faqTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildFaq(context.l10n.faqTrackQ, context.l10n.faqTrackA),
          _buildFaq(context.l10n.faqReturnQ, context.l10n.faqReturnA),
          _buildFaq(context.l10n.faqPaymentQ, context.l10n.faqPaymentA),
          _buildFaq(context.l10n.faqPromoQ, context.l10n.faqPromoA),
        ],
      ),
    );
  }

  Widget _buildFaq(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF181B19))),
        iconColor: AppPalette.primary,
        collapsedIconColor: const Color(0xFF181B19),
        childrenPadding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        children: [
          Text(answer, style: const TextStyle(color: AppPalette.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}