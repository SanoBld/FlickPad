import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Builds light/dark ThemeData from a ColorScheme (dynamic or manual)
class AppTheme {
  static ThemeData build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Fallback scheme when Material You / dynamic color is unavailable
  static ColorScheme fallbackScheme(Color seed, Brightness brightness) {
    return ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  }
}
