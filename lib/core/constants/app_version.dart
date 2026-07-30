import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String _cachedVersion = '1.6.3';

  /// Directly query Android PackageManager for the installed APK version name
  static Future<String> getInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _cachedVersion = info.version;
      }
    } catch (_) {}
    return _cachedVersion;
  }

  static String get version => _cachedVersion;
}

/// Riverpod provider for installed app version directly from Android PackageManager
final installedVersionProvider = FutureProvider<String>((ref) async {
  return await AppVersion.getInstalledVersion();
});
