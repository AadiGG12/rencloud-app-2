import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color accentAqua = Color(0xFF00D4FF);
  static const Color accentAquaLight = Color(0xFFF0F9FF);
  static const Color primaryDarkPurple = Color(0xFF0284C7);
  static const Color accentCyan = Color(0xFF00D4FF);
  
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color cardSurfaceLight = Color(0xFFFFFFFF);
  static const Color cardSurfaceDark = Color(0xFF111827);
  
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF1E293B);
  
  static const Color metallicGold = Color(0xFFF59E0B);
  
  static const LinearGradient metallicDarkGradient = LinearGradient(colors: [Color(0xFF1E2D4A), Color(0xFF111929), Color(0xFF0A0F1A)], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient metallicSteelGradient = LinearGradient(
    colors: [primaryPurple, accentAqua],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient metallicGoldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: textTheme,
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: primaryPurple),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimaryLight),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: textTheme,
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentAqua,
          side: const BorderSide(color: accentAqua, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentAqua, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: accentAqua),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentAqua),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
