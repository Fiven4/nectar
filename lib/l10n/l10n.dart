import 'package:flutter/material.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';
}

/// Текущий язык для кода без BuildContext (сервисы, валидаторы).
/// Обновляется провайдером [LocaleProvider].
class AppLocale {
  const AppLocale._();

  static const Locale russian = Locale('ru');
  static const Locale english = Locale('en');

  static Locale current = russian;

  static bool get isEnglish => current.languageCode == 'en';

  static AppLocalizations get strings => lookupAppLocalizations(current);
}

/// Выбирает значение для языка: английский вариант, если он задан и язык английский.
String pickLocalized({required bool english, required String russian, String? englishValue}) {
  if (english && englishValue != null && englishValue.trim().isNotEmpty) {
    return englishValue;
  }
  return russian;
}
