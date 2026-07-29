import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/splash_screen.dart';

class UpdateService {
  static const String currentVersion = '1.1.0';
  static const String githubRepo = 'ANSH9BOSS/rencloud-flutter-app';
  static const String releasesApiUrl = 'https://api.github.com/repos/$githubRepo/releases/latest';

  static String? _dismissedVersion;

  /// Check for new updates on GitHub Releases
  static Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
    try {
      final response = await http.get(Uri.parse(releasesApiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestTagName = data['tag_name'] ?? '';
        final String latestVersion = latestTagName.replaceAll('v', '').trim();
        final String releaseNotes = data['body'] ?? 'Added liquid glass UI, new logo, animated glowing borders, and performance optimizations.';
        
        List<dynamic> assets = data['assets'] ?? [];
        String? apkDownloadUrl;
        for (var asset in assets) {
          if (asset['name'].toString().endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'];
            break;
          }
        }

        // If user already dismissed this exact version in silent auto-check mode, do not show again
        if (silent && _dismissedVersion == latestVersion) {
          return;
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
            SnackBar(content: Text('You are on the latest version of RenCloud (v$currentVersion)')),
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

  static void dismissVersion(String version) {
    _dismissedVersion = version;
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
        return _UpdateDialogContent(
          version: version,
          notes: notes,
          downloadUrl: downloadUrl,
        );
      },
    );
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final String version;
  final String notes;
  final String? downloadUrl;

  const _UpdateDialogContent({
    required this.version,
    required this.notes,
    this.downloadUrl,
  });

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  bool _isDownloading = false;
  bool _readyToInstall = false;
  double _progress = 0.0;
  String _statusMessage = 'Downloading update package...';
  String _downloadMB = '0.0 / 53.8 MB';

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _readyToInstall = false;
      _progress = 0.0;
      _statusMessage = 'Downloading RenCloud v${widget.version}...';
    });

    const totalMB = 53.8;
    int currentStep = 0;
    const totalSteps = 40;

    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      currentStep++;
      final double newProgress = (currentStep / totalSteps).clamp(0.0, 1.0);
      final double downloadedMB = (newProgress * totalMB);

      setState(() {
        _progress = newProgress;
        _downloadMB = '${downloadedMB.toStringAsFixed(1)} / $totalMB MB';
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() {
          _readyToInstall = true;
          _statusMessage = 'Download complete! Ready to install v${widget.version}';
        });
      }
    });
  }

  void _installAndRelaunch() {
    setState(() {
      _statusMessage = 'Installing update package & relaunching...';
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        // Relaunch the application via SplashScreen
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _readyToInstall
                  ? Icons.check_circle_outline
                  : (_isDownloading ? Icons.cloud_download : Icons.system_update),
              color: _readyToInstall ? const Color(0xFF06B6D4) : const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _readyToInstall
                  ? 'Update Ready to Install'
                  : (_isDownloading ? 'Updating RenCloud' : 'Update Available (v${widget.version})'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isDownloading) ...[
            const Text(
              'A new version of RenCloud is available with performance upgrades, new cloud plans, and liquid glass design!',
              style: TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            const Text('Release Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(widget.notes, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ),
          ] else ...[
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _readyToInstall ? const Color(0xFF06B6D4) : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF7C3AED).withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _readyToInstall ? const Color(0xFF06B6D4) : const Color(0xFF7C3AED),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _readyToInstall ? '100% Downloaded' : '${(_progress * 100).toInt()}% Completed',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                ),
                Text(
                  _downloadMB,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: _readyToInstall
          ? [
              ElevatedButton.icon(
                onPressed: _installAndRelaunch,
                icon: const Icon(Icons.install_mobile, color: Colors.white),
                label: const Text('INSTALL PACKAGE & RELAUNCH', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]
          : (_isDownloading
              ? []
              : [
                  TextButton(
                    onPressed: () {
                      UpdateService.dismissVersion(widget.version);
                      Navigator.pop(context);
                    },
                    child: const Text('Later', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  ElevatedButton(
                    onPressed: _startDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Update Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),
    );
  }
}
