import 'package:flutter/material.dart';

/// Colors aligned with the Next.js admin panel (Ethiopian gold / forest / dark surface).
abstract final class AppColors {
  static const Color brand = Color(0xFFC59546);
  static const Color brandDark = Color(0xFF8A5C2D);
  static const Color forest = Color(0xFF22A971);
  static const Color surface = Color(0xFF090D16);
  static const Color surfaceCard = Color(0xFF0F172A);
  static const Color border = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF94A3B8);
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.brand,
      onPrimary: Color(0xFF1A1208),
      secondary: AppColors.forest,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
