import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material 3, set up to match the website's components (see the Ariselo design system,
/// "Mobile app"): pill buttons 56px tall, fields with an `edge` border, flat cards with a `line`
/// border.
ThemeData ariseloTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Brand.blue, primary: Brand.blue, surface: Brand.card);
  const pill = StadiumBorder();
  OutlineInputBorder field(Color color, [double width = 2]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: color, width: width),
      );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Brand.page,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(backgroundColor: Brand.page, foregroundColor: Brand.ink, elevation: 0),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Brand.ink, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: Brand.ink, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: Brand.ink, fontSize: 16),
      bodySmall: TextStyle(color: Brand.muted, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Brand.card,
      border: field(Brand.edge),
      enabledBorder: field(Brand.edge),
      focusedBorder: field(Brand.ink, 2.5),
      errorBorder: field(Brand.badInk),
      focusedErrorBorder: field(Brand.badInk, 2.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Sizes.touch),
        shape: pill,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(Sizes.touch),
        shape: pill,
        foregroundColor: Brand.ink,
        side: const BorderSide(color: Brand.edge, width: 2),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, Sizes.touchSmall), foregroundColor: Brand.blueDeep),
    ),
    cardTheme: CardThemeData(
      color: Brand.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: const BorderSide(color: Brand.line),
      ),
    ),
  );
}
