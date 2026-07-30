import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 3D Skeuomorphic Design System for RenCloud
class AppTheme {
  // Skeuomorphic & Metallic Palette Tokens
  static const Color primaryPurple = Color(0xFF38BDF8); // Metallic Cyber Steel
  static const Color primaryDarkPurple = Color(0xFF0284C7);
  static const Color accentAqua = Color(0xFF38BDF8);
  static const Color accentAquaLight = Color(0xFFF0F9FF);
  
  static const Color metallicSilver = Color(0xFFE2E8F0);
  static const Color metallicPlatinum = Color(0xFFCBD5E1);
  static const Color metallicSteel = Color(0xFF475569);
  static const Color metallicTitanium = Color(0xFF1E293B);
  static const Color metallicGunmetal = Color(0xFF0F172A);
  static const Color metallicDarkOnyx = Color(0xFF090D16);
  static const Color metallicGold = Color(0xFFF59E0B);
  static const Color metallicBronze = Color(0xFFD97706);

  static const Color backgroundLight = Color(0xFFE2E8F0); // Skeuomorphic Light Slate
  static const Color backgroundDark = Color(0xFF090E17); // Skeuomorphic Dark Titanium
  static const Color cardSurfaceLight = Color(0xFFECFEFF);
  static const Color cardSurfaceDark = Color(0xFF131C2E);
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF334155);

  // Metallic & Skeuomorphic Gradients
  static const LinearGradient metallicSilverGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient metallicDarkGradient = LinearGradient(
    colors: [Color(0xFF1E2D4A), Color(0xFF111929), Color(0xFF0A0F1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient metallicGoldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient metallicSteelGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shadowColor: const Color(0xFFB8C4D9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFE2E8F0),
        elevation: 2,
        scrolledUnderElevation: 2,
        iconTheme: const IconThemeData(color: primaryDarkPurple),
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
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2B3A52), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0D1422),
        elevation: 2,
        scrolledUnderElevation: 2,
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
