import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/locale_provider.dart';
import '../utils/app_palette.dart';

/// Переключатель RU / EN. [onDark] рисует его светлым на темных фонах.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final foreground = onDark ? Colors.white : AppPalette.textPrimary;

    Widget option(String label, Locale value, String semanticLabel) {
      final selected = locale.locale.languageCode == value.languageCode;
      return Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => context.read<LocaleProvider>().setLocale(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppPalette.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : foreground,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: onDark ? Colors.black.withValues(alpha: 0.35) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: onDark ? Colors.white54 : AppPalette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option('RU', AppLocale.russian, context.l10n.languageRussian),
          option('EN', AppLocale.english, context.l10n.languageEnglish),
        ],
      ),
    );
  }
}
