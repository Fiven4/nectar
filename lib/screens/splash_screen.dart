import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../utils/app_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.primary,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/1147/1147805.png',
              color: Colors.white,
              width: 55,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, color: Colors.white, size: 55),
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.splashBrand,
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
                ),
                Text(
                  context.l10n.splashTagline,
                  style: TextStyle(fontSize: 14, color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
