import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF005B8F),
      surface: const Color(0xFFF8FAFB),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFB),
    dividerColor: const Color(0x1A1B1B1F),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.6),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(height: 1.45),
      bodyMedium: TextStyle(height: 1.4),
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      shadowColor: Color(0x1400192B),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0x1A1B1B1F)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      elevation: 3,
      indicatorColor: const Color(0x1F005B8F),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    ),
    outlinedButtonTheme: const OutlinedButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4BB7E8),
      brightness: Brightness.dark,
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      shadowColor: Color(0x33000000),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
