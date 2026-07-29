import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Purple, White, Aqua Color Tokens
  static const Color primaryPurple = Color(0xFF7C3AED); // Electric Purple
  static const Color primaryDarkPurple = Color(0xFF6D28D9);
  static const Color accentAqua = Color(0xFF06B6D4); // Neon Aqua / Cyan
  static const Color accentAquaLight = Color(0xFFECFEFF);
  static const Color backgroundLight = Color(0xFFF8FAFC); // Pure Crisp Slate White
  static const Color backgroundDark = Color(0xFF030712); // Onyx Pure Black
  static const Color cardSurfaceLight = Colors.white;
  static const Color cardSurfaceDark = Color(0xFF111827); // Dark Onyx Surface
  static const Color textPrimary = Color(0xFF0F172A); // Dark Slate (Alias)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF1F2937);

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
        primary: primaryPurple,
        secondary: accentAqua,
        surface: cardSurfaceLight,
        onSurface: textPrimaryLight,
      ),
      cardTheme: CardThemeData(
        color: cardSurfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: primaryPurple),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.dark,
        primary: primaryPurple,
        secondary: accentAqua,
        surface: cardSurfaceDark,
        onSurface: textPrimaryDark,
      ),
      cardTheme: CardThemeData(
        color: cardSurfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: accentAqua),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
