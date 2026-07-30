import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  /// Directly query Android PackageManager for the installed APK version name
  static Future<String> getInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        return info.version;
      }
    } catch (_) {}
    return '1.6.4';
  }

  static String get version => '1.6.4';
}

/// Riverpod provider for installed app version directly from Android PackageManager
final installedVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version.isNotEmpty ? info.version : '1.6.4';
});
