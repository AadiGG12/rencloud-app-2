import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String _installedVersionName = '3.0.2';
  static int _installedBuildNumber = 1020;

  /// Read installed package info directly from native Android PackageManager BEFORE runApp()
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _installedVersionName = info.version;
        _installedBuildNumber = int.tryParse(info.buildNumber) ?? 150;
        debugPrint('[AppVersion] Native Android PackageManager version: $_installedVersionName (build $_installedBuildNumber)');
      }
    } catch (e) {
      debugPrint('[AppVersion] Failed to read PackageManager info: $e');
    }
  }

  /// Synchronously returns the exact version name read from native Android PackageManager
  static String get version => _installedVersionName;

  static Future<String> getInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _installedVersionName = info.version;
      }
    } catch (_) {}
    return _installedVersionName;
  }

  static int get buildNumber => _installedBuildNumber;
}
