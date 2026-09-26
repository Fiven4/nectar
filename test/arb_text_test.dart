import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('в ARB нет буквальных «\\n»: переводы строк должны быть настоящими', () {
    for (final file in ['lib/l10n/app_ru.arb', 'lib/l10n/app_en.arb']) {
      final data = jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;
      data.forEach((key, value) {
        if (value is String) {
          expect(value.contains(r'\n'), isFalse, reason: '$file: $key содержит буквальный \\n');
        }
      });
    }
  });
}
