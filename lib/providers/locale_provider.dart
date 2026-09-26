import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';

/// Хранит выбранный язык приложения (русский по умолчанию, английский вторым).
class LocaleProvider with ChangeNotifier {
  static const String _storageKey = 'app_language';

  Locale _locale = AppLocale.russian;

  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';

  /// Загружает сохраненный язык. Если он не выбран, берется язык устройства
  /// (только русский или английский), иначе русский.
  Future<void> load() async {
    String? stored;
    try {
      stored = (await SharedPreferences.getInstance()).getString(_storageKey);
    } catch (_) {
      stored = null;
    }

    final code = stored ?? ui.PlatformDispatcher.instance.locale.languageCode;
    _apply(code == 'en' ? AppLocale.english : AppLocale.russian);
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;

    _apply(locale);
    try {
      await (await SharedPreferences.getInstance()).setString(_storageKey, locale.languageCode);
    } catch (_) {
      // Язык применится, но не запомнится до следующего запуска.
    }
  }

  void _apply(Locale locale) {
    _locale = locale;
    AppLocale.current = locale;
    notifyListeners();
  }
}
