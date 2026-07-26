import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF6C5CE7);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F5FB),
        navigationBarTheme: const NavigationBarThemeData(
          height: 64,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        fontFamily: 'Roboto',
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121016),
        navigationBarTheme: const NavigationBarThemeData(
          height: 64,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1E1B26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        fontFamily: 'Roboto',
      );
}
