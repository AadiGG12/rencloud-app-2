import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String _installedVersionName = '1.6.5';
  static int _installedBuildNumber = 60;

  /// Read installed package info directly from native Android PackageManager BEFORE runApp()
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _installedVersionName = info.version;
        _installedBuildNumber = int.tryParse(info.buildNumber) ?? 60;
        debugPrint('[AppVersion] Native Android PackageManager version: $_installedVersionName (build $_installedBuildNumber)');
      }
    } catch (e) {
      debugPrint('[AppVersion] Failed to read PackageManager info: $e');
    }
  }

  /// Synchronously returns the exact version name read from native Android PackageManager
  static String get version => _installedVersionName;

  static Future<String> getInstalledVersion() async => _installedVersionName;

  static int get buildNumber => _installedBuildNumber;
}
