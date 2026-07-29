import 'package:flutter/material.dart';

class AppTheme {
  // Purple, White, Aqua Color Tokens
  static const Color primaryPurple = Color(0xFF7C3AED); // Electric Purple
  static const Color primaryDarkPurple = Color(0xFF6D28D9);
  static const Color accentAqua = Color(0xFF06B6D4); // Neon Aqua / Cyan
  static const Color accentAquaLight = Color(0xFFECFEFF);
  static const Color backgroundLight = Color(0xFFF8FAFC); // Pure Crisp Slate White
  static const Color cardSurface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color popularBadgeBg = Color(0xFF06B6D4); // Bright Aqua Popular Tag
  static const Color popularBadgeText = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        primary: primaryPurple,
        secondary: accentAqua,
        surface: cardSurface,
        background: backgroundLight,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: IconThemeData(color: primaryPurple),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
