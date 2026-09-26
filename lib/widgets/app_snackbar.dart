import 'package:flutter/material.dart';

import '../utils/app_palette.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
  bool floating = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError ? AppPalette.danger : AppPalette.primary,
      duration: const Duration(seconds: 2),
      behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      shape: floating ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)) : null,
      margin: floating ? const EdgeInsets.only(bottom: 20, left: 20, right: 20) : null,
    ),
  );
}
