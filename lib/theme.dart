import 'package:flutter/material.dart';

/// The same colours as the website (frontend/src/styles/tokens.css).
class Brand {
  static const blue = Color(0xFF2F6FDB);
  static const blueDeep = Color(0xFF1F55B8);
  static const blueSoft = Color(0xFFE6EFFF);
  static const sun = Color(0xFFFFC23D);
  static const sunSoft = Color(0xFFFFF4D6);
  static const coral = Color(0xFFFF6B57);
  static const grape = Color(0xFF7C4DDB);
  static const grapeSoft = Color(0xFFEFE8FF);
  static const ink = Color(0xFF1F2A55);
  static const muted = Color(0xFF576389);
  static const line = Color(0xFFD9E1F2);
  static const page = Color(0xFFF7FBFF);
  static const good = Color(0xFF13854F);
  static const goodSoft = Color(0xFFE1F6EA);
  static const bad = Color(0xFFD0313F);
  static const badSoft = Color(0xFFFDE7E9);
}

ThemeData ariseloTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Brand.blue, primary: Brand.blue, surface: Colors.white);
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
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Brand.line)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Brand.line)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Brand.line)),
    ),
  );
}
