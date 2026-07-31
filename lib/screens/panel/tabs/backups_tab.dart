import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/pterodactyl/backup_model.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/pterodactyl/pterodactyl_client.dart';
import '../../../services/pterodactyl/resource_service.dart';

class BackupsTab extends ConsumerStatefulWidget {
  final String serverId;
  const BackupsTab({super.key, required this.serverId});

  @override
  ConsumerState<BackupsTab> createState() => _BackupsTabState();
}

class _BackupsTabState extends ConsumerState<BackupsTab> {
  List<ServerBackup> _backups = [];
  bool _isLoading = true;
  String? _error;

  BackupService? _getService() {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return null;
    return BackupService(PterodactylClient(panelUrl: auth.panelUrl!, apiKey: auth.apiKey!), widget.serverId);
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try { 
      _backups = await _getService()?.list() ?? []; 
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _create() async {
    await _getService()?.create();
    _load();
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }

  IconData _statusIcon(ServerBackup b) {
    if (!b.isSuccessful) return Icons.error;
    if (b.completedAt == null) return Icons.hourglass_empty;
    return Icons.check_circle;
  }

  Color _statusColor(ServerBackup b) {
    if (!b.isSuccessful) return Colors.red;
    if (b.completedAt == null) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.backup), heroTag: null),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _backups.isEmpty
                  ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.backup, size: 48, color: AppTheme.textSecondary), SizedBox(height: 8), Text('No backups')]))
                  : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _backups.length,
                    itemBuilder: (context, index) {
                      final b = _backups[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(_statusIcon(b), color: _statusColor(b)),
                          title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${b.sizeFormatted} • ${b.createdAt.toString().substring(0, 19)}', style: const TextStyle(fontSize: 11)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'download') {
                                final url = await _getService()?.getDownloadUrl(b.id);
                                if (url != null && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download URL (5 min): ${url.substring(0, 50)}...')));
                                }
                              } else if (v == 'delete') {
                                await _getService()?.delete(b.id);
                                _load();
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'download', child: Text('Get Download URL')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
