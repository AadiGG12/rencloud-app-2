import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../core/constants/app_version.dart';

class UpdateService {
  static String get currentVersion => AppVersion.version;
  static const String githubRepo = 'AadiGG12/rencloud-app-2';
  static const String releasesApiUrl = 'https://api.github.com/repos/$githubRepo/releases/latest';

  static String? _dismissedVersion;

  /// Check for new updates on GitHub Releases with strict cache-busting
  static Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
    final installedVersion = currentVersion;
    debugPrint('[UpdateService] Installed app version: $installedVersion');

    try {
      // 1. Force fresh fetch by appending cache-busting timestamp parameter
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final requestUri = Uri.parse('$releasesApiUrl?t=$cacheBuster');

      debugPrint('[UpdateService] Fetching latest release directly from GitHub: $requestUri');

      final response = await http.get(
        requestUri,
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ).timeout(const Duration(seconds: 7));

      debugPrint('[UpdateService] Raw GitHub API response status: ${response.statusCode}');
      debugPrint('[UpdateService] Raw GitHub API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final String latestTagName = data['tag_name'] as String? ?? '';
        final String latestVersion = latestTagName.replaceAll(RegExp(r'[^0-9.]'), '').trim();
        final String releaseNotes = data['body'] as String? ?? 'Latest update available.';

        debugPrint('[UpdateService] Latest version fetched from GitHub: $latestVersion');

        List<dynamic> assets = data['assets'] as List<dynamic>? ?? [];
        String? apkDownloadUrl;
        for (var asset in assets) {
          if (asset['name'].toString().toLowerCase().endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'];
            break;
          }
        }

        final bool isUpdateAvailable = _isNewerVersion(latestVersion, installedVersion);
        debugPrint('[UpdateService] Version comparison result (latest: $latestVersion vs current: $installedVersion): isNewer=$isUpdateAvailable');
        debugPrint('[UpdateService] Whether an update is available: $isUpdateAvailable');

        // If user already dismissed this exact version in silent auto-check mode, skip dialog
        if (silent && _dismissedVersion == latestVersion) {
          debugPrint('[UpdateService] Silent check: version $latestVersion was previously dismissed');
          return;
        }

        if (isUpdateAvailable) {
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
            SnackBar(content: Text('You are on the latest version of RenCloud (v$installedVersion)')),
          );
        }
      } else {
        throw Exception('GitHub API HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[UpdateService] Update check failed: $e');
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

  /// True Semantic Versioning comparison (major.minor.patch)
  static bool _isNewerVersion(String latest, String current) {
    final latestSemver = _parseSemver(latest);
    final currentSemver = _parseSemver(current);

    for (int i = 0; i < 3; i++) {
      if (latestSemver[i] > currentSemver[i]) return true;
      if (latestSemver[i] < currentSemver[i]) return false;
    }
    return false;
  }

  static List<int> _parseSemver(String versionStr) {
    final cleaned = versionStr.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final parts = cleaned.split('.');
    final semver = <int>[0, 0, 0];
    for (int i = 0; i < parts.length && i < 3; i++) {
      semver[i] = int.tryParse(parts[i]) ?? 0;
    }
    return semver;
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
  String _statusMessage = 'Preparing download...';
  String _downloadMB = '0.0 MB';
  String? _downloadedFilePath;

  Future<void> _startDownload() async {
    if (widget.downloadUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No APK found in the latest release')),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _readyToInstall = false;
      _progress = 0.0;
      _statusMessage = 'Downloading RenCloud v${widget.version}...';
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/rencloud-v${widget.version}.apk';
      final file = File(filePath);
      if (await file.exists()) {
        try { await file.delete(); } catch (_) {}
      }

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(widget.downloadUrl!)),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int bytesReceived = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        bytesReceived += chunk.length;

        if (contentLength > 0) {
          final newProgress = bytesReceived / contentLength;
          final downloadedMB = bytesReceived / (1024 * 1024);
          final totalMB = contentLength / (1024 * 1024);

          setState(() {
            _progress = newProgress.clamp(0.0, 1.0);
            _downloadMB = '${downloadedMB.toStringAsFixed(1)} / ${totalMB.toStringAsFixed(1)} MB';
          });
        }
      }

      await sink.flush();
      await sink.close();

      setState(() {
        _readyToInstall = true;
        _progress = 1.0;
        _statusMessage = 'Update downloaded! Tap below to install.';
        _downloadedFilePath = filePath;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Download failed: $e';
      });
    }
  }

  void _installApk() async {
    if (_downloadedFilePath == null) return;

    setState(() {
      _statusMessage = 'Opening package installer...';
    });

    try {
      final result = await OpenFilex.open(_downloadedFilePath!);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open installer: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening APK: $e')),
        );
      }
    }
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
              color: const Color.fromARGB(26, 124, 58, 237),
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
                  : (_isDownloading ? 'Downloading...' : 'Update Available (v${widget.version})'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isDownloading && !_readyToInstall) ...[
            const Text(
              'A new version of RenCloud is ready for download.',
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
                backgroundColor: const Color.fromARGB(31, 124, 58, 237),
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
                  _readyToInstall ? '100% Downloaded' : '${(_progress * 100).toInt()}%',
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
                onPressed: _installApk,
                icon: const Icon(Icons.system_update_alt, color: Colors.white),
                label: const Text('INSTALL UPDATE', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
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
