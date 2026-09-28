import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/app/session_app.dart';
import 'package:nectar/utils/app_palette.dart';

void main() {
  test('включенный переключатель: зеленая дорожка и белый бегунок', () {
    final switchTheme = nectarTheme.switchTheme;
    final on = {WidgetState.selected};
    final off = <WidgetState>{};

    expect(switchTheme.trackColor!.resolve(on), AppPalette.primary);
    expect(switchTheme.thumbColor!.resolve(on), Colors.white, reason: 'бегунок не должен сливаться с дорожкой');
    expect(switchTheme.trackOutlineColor!.resolve(on), Colors.transparent);
    expect(switchTheme.trackColor!.resolve(off), isNot(AppPalette.primary));
    expect(switchTheme.trackOutlineColor!.resolve(off), isNot(Colors.transparent));
  });

  testWidgets('SwitchListTile не переопределяет цвет бегунка зеленым', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: nectarTheme,
        home: Scaffold(
          body: SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Push')),
        ),
      ),
    );

    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.activeThumbColor, isNull);
  });
}
