import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateService {
  static const String currentVersion = '1.5.9';
  static const String githubRepo = 'AadiGG12/rencloud-app-2';
  static const String releasesApiUrl = 'https://api.github.com/repos/$githubRepo/releases/latest';

  static String? _dismissedVersion;

  /// Check for new updates on GitHub Releases (manual check only)
  static Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
    try {
      final response = await http.get(Uri.parse(releasesApiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestTagName = data['tag_name'] ?? '';
        final String latestVersion = latestTagName.replaceAll('v', '').trim();
        final String releaseNotes = data['body'] ?? 'Latest update available.';

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
      // Get local storage directory
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/rencloud-v${widget.version}.apk';
      final file = File(filePath);

      // Stream download with progress
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
