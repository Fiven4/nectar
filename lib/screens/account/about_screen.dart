import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../utils/app_palette.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: Text(context.l10n.menuAbout, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.eco, color: AppPalette.primary, size: 80),
                SizedBox(height: 10),
                Text(context.l10n.splashBrand, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF181B19))),
                SizedBox(height: 5),
                Text(context.l10n.aboutVersion, style: TextStyle(color: AppPalette.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(thickness: 1, color: Color(0xFFE2E2E2)),
          _buildLinkTile(context.l10n.aboutTerms),
          _buildLinkTile(context.l10n.aboutPrivacy),
          _buildLinkTile(context.l10n.aboutLicenses),
        ],
      ),
    );
  }

  Widget _buildLinkTile(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF181B19))),
          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF181B19), size: 16),
          onTap: () {},
        ),
        const Divider(thickness: 1, color: Color(0xFFE2E2E2)),
      ],
    );
  }
}