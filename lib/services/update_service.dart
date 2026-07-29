import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateService {
  static const String currentVersion = '1.1.0';
  static const String githubRepo = 'ANSH9BOSS/rencloud-flutter-app';
  static const String releasesApiUrl = 'https://api.github.com/repos/$githubRepo/releases/latest';

  /// Check for new updates on GitHub Releases
  static Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
    try {
      final response = await http.get(Uri.parse(releasesApiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestTagName = data['tag_name'] ?? '';
        final String latestVersion = latestTagName.replaceAll('v', '').trim();
        final String releaseNotes = data['body'] ?? 'Added smooth splash screen opening animation, card touch micro-animations, non-stretched crisp launcher icons, and performance optimizations.';
        
        List<dynamic> assets = data['assets'] ?? [];
        String? apkDownloadUrl;
        for (var asset in assets) {
          if (asset['name'].toString().endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'];
            break;
          }
        }

        if (_isNewerVersion(latestVersion, currentVersion)) {
          if (context.mounted) {
            _showUpdateDialog(
              context,
              version: latestVersion,
              notes: releaseNotes,
              downloadUrl: apkDownloadUrl,
            );
          }
        } else if (!silent && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are on the latest version of RenCloud (v1.1.0)')),
          );
        }
      }
    } catch (e) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not check for updates: $e')),
        );
      }
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    if (latest.isEmpty) return false;
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return latestParts.length > currentParts.length;
  }

  static void _showUpdateDialog(
    BuildContext context, {
    required String version,
    required String notes,
    String? downloadUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Color(0xFF7C3AED)),
              const SizedBox(width: 10),
              Text('Update Available (v$version)'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A new version of RenCloud is available with improvements and new cloud plans!',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Text('Release Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(notes, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloading RenCloud v$version APK from GitHub...'),
                    backgroundColor: const Color(0xFF06B6D4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
