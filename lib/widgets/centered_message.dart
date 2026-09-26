import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class CenteredMessage extends StatelessWidget {
  const CenteredMessage(this.message, {super.key, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 56, color: const Color(0xFFB3B3B3)),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppPalette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
