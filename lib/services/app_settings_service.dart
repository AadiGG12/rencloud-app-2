import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/catalog_provider.dart';

class AppSettingsService {
  static const String keyThemeMode = 'settings_theme_mode';
  static const String keyCurrency = 'settings_currency';
  static const String keyBiometrics = 'settings_biometrics';

  /// Save client settings to SharedPreferences
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  static Future<void> saveCurrency(AppCurrency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCurrency, currency.name);
  }

  static Future<void> saveBiometrics(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyBiometrics, enabled);
  }

  /// Restore saved client settings on app startup
  static Future<void> restoreSettings(WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Restore Theme Mode (Default: Dark)
      final savedTheme = prefs.getString(keyThemeMode);
      if (savedTheme != null) {
        ref.read(themeModeProvider.notifier).state =
            savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }

      // 2. Restore Currency (Default: INR)
      final savedCurrency = prefs.getString(keyCurrency);
      if (savedCurrency != null) {
        final match = AppCurrency.values.firstWhere(
          (c) => c.name == savedCurrency,
          orElse: () => AppCurrency.inr,
        );
        ref.read(currencyProvider.notifier).state = match;
      }

      // 3. Restore Biometrics (Default: Disabled)
      final savedBiometrics = prefs.getBool(keyBiometrics) ?? false;
      ref.read(biometricProvider.notifier).toggleBiometrics(savedBiometrics);
    } catch (_) {}
  }
}
