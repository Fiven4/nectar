import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Функции локализации принимают String. Значение из Firestore (`map['key']`) —
/// dynamic и может быть числом: тогда падает cast в рантайме («int is not a
/// subtype of String»), как это было на экранах заказов и промокодов.
void main() {
  test('в функции l10n не передаются «сырые» значения из map', () {
    final call = RegExp(r"l10n\.\w+\(([^;]*)\)");
    final rawMapArgument = RegExp(r"(^|,\s*)[A-Za-z_.]+\['[A-Za-z]+'\]\s*(?=[,)])");
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart') || entity.path.contains('lib/l10n/')) continue;
      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        for (final match in call.allMatches(lines[index])) {
          if (rawMapArgument.hasMatch(match.group(1)!)) {
            offenders.add('${entity.path}:${index + 1}: ${lines[index].trim()}');
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
