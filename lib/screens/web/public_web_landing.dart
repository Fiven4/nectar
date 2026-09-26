import 'package:flutter/material.dart';
import '../../utils/app_palette.dart';
import '../../utils/auth_target.dart';
import '../auth/login_screen.dart';
import '../../l10n/l10n.dart';

class PublicWebLandingScreen extends StatelessWidget {
  const PublicWebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Шапка сайта (Header)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppPalette.border, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: AppPalette.primary, size: 36),
                const SizedBox(width: 12),
                const Text(
                  'Nectar',
                  style: TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Unbounded',
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(context.l10n.landingForCustomers, style: TextStyle(color: AppPalette.textPrimary, fontSize: 16)),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {},
                  child: Text(context.l10n.landingAbout, style: TextStyle(color: AppPalette.textPrimary, fontSize: 16)),
                ),
                const SizedBox(width: 30),
                // Вход для сотрудников
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.primary,
                    side: const BorderSide(color: AppPalette.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(
                          authFlowTarget: AuthFlowTarget.adminPanel,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: Text(context.l10n.landingStaffLogin, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Основной контент (Hero Section)
          Expanded(
            child: Container(
              color: AppPalette.background,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    children: [
                      // Текстовая часть
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppPalette.lightPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  context.l10n.landingBadge,
                                  style: TextStyle(color: AppPalette.primaryDark, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                context.l10n.landingHeadline,
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: AppPalette.textPrimary,
                                  height: 1.1,
                                  fontFamily: 'Unbounded',
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                context.l10n.landingBody,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppPalette.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                context.l10n.landingDownload,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildStoreButton(context, Icons.apple, 'App Store', Colors.black),
                                  const SizedBox(width: 16),
                                  _buildStoreButton(context, Icons.android, 'Google Play', AppPalette.primaryDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Визуальная часть (Картинка телефона)
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 400,
                              height: 400,
                              decoration: const BoxDecoration(
                                color: AppPalette.lightPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Icon(Icons.phone_iphone, size: 300, color: AppPalette.primary),
                            Positioned(
                              bottom: 120,
                              right: 120,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: AppPalette.primary, size: 30),
                                    SizedBox(width: 10),
                                    Text(context.l10n.landingFreshOnly, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.landingDownloadIn, style: TextStyle(color: Colors.white70, fontSize: 10)),
              Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}