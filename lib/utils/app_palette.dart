import 'package:flutter/material.dart';

/// Палитра бренда. Все сочетания «текст на фоне» подобраны по контрасту WCAG AA
/// (не ниже 4.5:1): белый текст допустим только на [primary], [primaryDark],
/// [danger] и [warning], а на светлых поверхностях используется [textPrimary]
/// или [textSecondary].
class AppPalette {
  static const Color background = Color(0xFFF5F3EF);
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE0E0E0);
  static const Color navigation = Color(0xFF636380);
  static const Color warning = Color(0xFFC2410C);
  static const Color danger = Color(0xFFC62828);
  static const Color addAction = Color(0xFF94FF66);
  static const Color editAction = Color(0xFFFFC466);

  static const Color lightPrimary = Color(0xFFE8F5E9);
  static const Color disabledBackground = Color(0xFFE0E0E0);
  static const Color disabledForeground = Color(0xFF616161);
}
