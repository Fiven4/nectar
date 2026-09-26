import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/data/catalog_translations.dart';
import 'package:nectar/data/product_catalog.dart';
import 'package:nectar/l10n/l10n.dart';
import 'package:nectar/utils/order_status.dart';
import 'package:nectar/utils/role_utils.dart';
import 'package:nectar/utils/validators.dart';

Map<String, dynamic> _readArb(String locale) {
  return jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  tearDown(() => AppLocale.current = AppLocale.russian);

  group('ARB files', () {
    final ru = _readArb('ru');
    final en = _readArb('en');
    final ruKeys = ru.keys.where((key) => !key.startsWith('@')).toSet();
    final enKeys = en.keys.where((key) => !key.startsWith('@')).toSet();

    test('contain the same keys', () {
      expect(enKeys.difference(ruKeys), isEmpty, reason: 'only in English');
      expect(ruKeys.difference(enKeys), isEmpty, reason: 'only in Russian');
    });

    test('have no empty translations', () {
      for (final key in ruKeys) {
        expect((ru[key] as String).trim(), isNotEmpty, reason: 'ru: $key');
        expect((en[key] as String).trim(), isNotEmpty, reason: 'en: $key');
      }
    });

    test('English texts contain no Cyrillic letters', () {
      final cyrillic = RegExp('[А-Яа-яЁё]');
      for (final key in enKeys) {
        expect(cyrillic.hasMatch(en[key] as String), isFalse, reason: key);
      }
    });

    test('Russian texts are actually Russian (except brand names)', () {
      const allowedLatin = {'appTitle', 'languageEnglish', 'currencyRub', 'labelEmail'};
      final cyrillic = RegExp('[А-Яа-яЁё]');
      for (final key in ruKeys) {
        final text = ru[key] as String;
        if (allowedLatin.contains(key) || !RegExp('[A-Za-z]{4,}').hasMatch(text)) continue;
        expect(cyrillic.hasMatch(text), isTrue, reason: key);
      }
    });
  });

  group('service messages follow the selected language', () {
    test('validators', () {
      expect(Validators.validateEmail(''), 'Введите email');
      AppLocale.current = AppLocale.english;
      expect(Validators.validateEmail(''), 'Enter your email');
      expect(Validators.validatePasswordConfirmation('a', 'b'), 'Passwords do not match');
    });

    test('role and status labels', () {
      expect(roleLabel(AppRoles.courier), 'Курьер');
      expect(orderStatusLabel('delivered', 'Доставлен', AppLocale.strings), 'Доставлен');
      AppLocale.current = AppLocale.english;
      expect(roleLabel(AppRoles.courier), 'Courier');
      expect(orderStatusLabel('delivered', 'Доставлен', AppLocale.strings), 'Delivered');
      expect(orderStatusLabel('custom', 'Особый', AppLocale.strings), 'Особый');
    });
  });

  test('every catalog product and category has an English translation', () {
    for (final product in catalogProducts) {
      final translation = productTranslations[product.id];
      expect(translation, isNotNull, reason: product.id);
      expect(translation!.name, isNotEmpty, reason: product.id);
      expect(translation.description, isNotEmpty, reason: product.id);
      if (product.composition.isNotEmpty) {
        expect(translation.composition, isNotEmpty, reason: product.id);
      }
      expect(countryTranslations.containsKey(product.country), isTrue, reason: '${product.id}: ${product.country}');
    }
    for (final category in catalogCategories) {
      expect(categoryTranslations[category.id], isNotNull, reason: category.id);
    }
  });

  testWidgets('the same widget renders in Russian and in English', (tester) async {
    Future<void> pumpWith(Locale locale) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(builder: (context) => Text(context.l10n.navShop)),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpWith(AppLocale.russian);
    expect(find.text('Магазин'), findsOneWidget);

    await pumpWith(AppLocale.english);
    expect(find.text('Shop'), findsOneWidget);
  });
}
