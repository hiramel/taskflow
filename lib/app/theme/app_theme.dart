import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _brandPurple = Color(0xFF6D5EF8);

  static ThemeData get lightTheme => _themeFor(Brightness.light);

  static ThemeData get darkTheme => _themeFor(Brightness.dark);

  static ThemeData _themeFor(Brightness brightness) {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: _brandPurple,
          brightness: brightness,
        ).copyWith(
          primary: _brandPurple,
          secondary: _brandPurple,
          tertiary: _brandPurple,
          surfaceTint: _brandPurple,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
