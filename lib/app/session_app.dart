import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/l10n.dart';
import '../utils/app_palette.dart';

final ThemeData nectarTheme = _buildTheme();

ThemeData _buildTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: AppPalette.primary).copyWith(
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    error: AppPalette.danger,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppPalette.textPrimary,
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppPalette.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppPalette.disabledBackground,
        disabledForegroundColor: AppPalette.disabledForeground,
        shape: buttonShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppPalette.disabledBackground,
        disabledForegroundColor: AppPalette.disabledForeground,
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppPalette.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.primary,
        side: const BorderSide(color: AppPalette.primary),
        shape: buttonShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: AppPalette.textSecondary),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.primary, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.grey.shade600,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppPalette.primary : Colors.grey.shade300,
      ),
      // Включенный переключатель: зеленая дорожка и белый «бегунок» без обводки.
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.transparent : Colors.grey.shade500,
      ),
    ),
  );
}

/// The [MaterialApp] for one auth session.
///
/// It is keyed by [sessionId], so a sign-in or sign-out rebuilds the whole
/// Navigator/Overlay tree in a single frame. Swapping only the page inside a
/// live Navigator leaves routes, dialogs and bottom sheets alive while the
/// InheritedElements they depend on are deactivated, which fails Flutter's
/// `_dependents.isEmpty` assertion.
class SessionApp extends StatelessWidget {
  const SessionApp({
    super.key,
    required this.sessionId,
    required this.home,
    this.theme,
    this.locale = AppLocale.russian,
  });

  final String? sessionId;
  final Widget home;
  final ThemeData? theme;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey<String>(sessionId ?? 'guest'),
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: theme ?? nectarTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }
}
