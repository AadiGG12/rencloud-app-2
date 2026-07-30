import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final String installedVersion;
  final String latestReleaseVersion;
  final bool isUpdateAvailable;
  final String releaseNotes;
  final String? downloadUrl;

  const AppUpdateInfo({
    required this.installedVersion,
    required this.latestReleaseVersion,
    required this.isUpdateAvailable,
    required this.releaseNotes,
    this.downloadUrl,
  });
}

class AppUpdateNotifier extends StateNotifier<AsyncValue<AppUpdateInfo>> {
  static const String githubRepo = 'AadiGG12/rencloud-app-2';
  static const String releasesApiUrl = 'https://api.github.com/repos/$githubRepo/releases/latest';

  AppUpdateNotifier() : super(const AsyncValue.loading()) {
    checkVersionInfo();
  }

  Future<void> checkVersionInfo() async {
    try {
      // 1. Get exact installed APK version directly from native Android PackageManager
      final packageInfo = await PackageInfo.fromPlatform();
      final installedVer = packageInfo.version.isNotEmpty ? packageInfo.version : '1.6.4';

      debugPrint('[AppUpdateNotifier] Installed version from PackageManager: $installedVer');

      // 2. Fetch fresh GitHub release data with strict cache-busting
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final requestUri = Uri.parse('$releasesApiUrl?t=$cacheBuster');

      final response = await http.get(
        requestUri,
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
          'Accept': 'application/vnd.github+json',
        },
      ).timeout(const Duration(seconds: 7));

      String latestVer = installedVer;
      String notes = 'No update details.';
      String? apkUrl;

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final String tagName = data['tag_name'] as String? ?? '';
        latestVer = tagName.replaceAll(RegExp(r'[^0-9.]'), '').trim();
        notes = data['body'] as String? ?? 'Latest update available.';

        final List<dynamic> assets = data['assets'] as List<dynamic>? ?? [];
        for (var asset in assets) {
          if (asset['name'].toString().toLowerCase().endsWith('.apk')) {
            apkUrl = asset['browser_download_url'];
            break;
          }
        }
      }

      final isNewer = _isNewer(latestVer, installedVer);

      debugPrint('[AppUpdateNotifier] Installed: $installedVer | GitHub Latest: $latestVer | Update Available: $isNewer');

      state = AsyncValue.data(
        AppUpdateInfo(
          installedVersion: installedVer,
          latestReleaseVersion: latestVer,
          isUpdateAvailable: isNewer,
          releaseNotes: notes,
          downloadUrl: apkUrl,
        ),
      );
    } catch (e, stack) {
      debugPrint('[AppUpdateNotifier] Error checking version info: $e');
      // Fallback state reading PackageManager
      try {
        final info = await PackageInfo.fromPlatform();
        state = AsyncValue.data(
          AppUpdateInfo(
            installedVersion: info.version.isNotEmpty ? info.version : '1.6.4',
            latestReleaseVersion: info.version.isNotEmpty ? info.version : '1.6.4',
            isUpdateAvailable: false,
            releaseNotes: '',
          ),
        );
      } catch (_) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  static bool _isNewer(String latest, String installed) {
    final lParts = _parseSemver(latest);
    final iParts = _parseSemver(installed);

    for (int i = 0; i < 3; i++) {
      if (lParts[i] > iParts[i]) return true;
      if (lParts[i] < iParts[i]) return false;
    }
    return false;
  }

  static List<int> _parseSemver(String vStr) {
    final cleaned = vStr.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final parts = cleaned.split('.');
    final semver = <int>[0, 0, 0];
    for (int i = 0; i < parts.length && i < 3; i++) {
      semver[i] = int.tryParse(parts[i]) ?? 0;
    }
    return semver;
  }
}

/// Provider for installed version & update state
final appUpdateInfoProvider = StateNotifierProvider<AppUpdateNotifier, AsyncValue<AppUpdateInfo>>((ref) {
  return AppUpdateNotifier();
});

/// Native installed package version provider directly from Android PackageManager
final installedPackageVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});
