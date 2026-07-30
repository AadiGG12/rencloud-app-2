import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Production Metallic Design System for RenCloud
class AppTheme {
  // Metallic Color Palette Tokens
  static const Color primaryPurple = Color(0xFF38BDF8); // Metallic Cyber Steel (Primary)
  static const Color primaryDarkPurple = Color(0xFF0284C7); // Deep Steel Blue
  static const Color accentAqua = Color(0xFF38BDF8); // Platinum Cyan Accent
  static const Color accentAquaLight = Color(0xFFF0F9FF);
  
  // Metallic Steel & Titanium Tones
  static const Color metallicSilver = Color(0xFFE2E8F0);
  static const Color metallicPlatinum = Color(0xFFCBD5E1);
  static const Color metallicSteel = Color(0xFF475569);
  static const Color metallicTitanium = Color(0xFF1E293B);
  static const Color metallicGunmetal = Color(0xFF0F172A);
  static const Color metallicDarkOnyx = Color(0xFF090D16);
  static const Color metallicGold = Color(0xFFF59E0B);
  static const Color metallicBronze = Color(0xFFD97706);

  static const Color backgroundLight = Color(0xFFF1F5F9); // Light Metallic Slate
  static const Color backgroundDark = Color(0xFF0B0F19); // Metallic Dark Titanium
  static const Color cardSurfaceLight = Colors.white;
  static const Color cardSurfaceDark = Color(0xFF161F33); // Metallic Dark Surface
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8); // Metallic Slate Subtitle
  static const Color borderLight = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF334155);

  // Metallic Linear Gradients
  static const LinearGradient metallicSilverGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient metallicDarkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF090D16)],
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 1,
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
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A),
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
