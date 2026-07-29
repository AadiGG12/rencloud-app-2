import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/pterodactyl/database_model.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/pterodactyl/pterodactyl_client.dart';
import '../../../services/pterodactyl/resource_service.dart';

class DatabasesTab extends ConsumerStatefulWidget {
  final String serverId;
  const DatabasesTab({super.key, required this.serverId});

  @override
  ConsumerState<DatabasesTab> createState() => _DatabasesTabState();
}

class _DatabasesTabState extends ConsumerState<DatabasesTab> {
  List<ServerDatabase> _dbs = [];
  bool _isLoading = true;

  DatabaseService? _getService() {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return null;
    return DatabaseService(PterodactylClient(panelUrl: auth.panelUrl!, apiKey: auth.apiKey!), widget.serverId);
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _dbs = await _getService()?.list() ?? [];
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _create() async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(title: const Text('Create Database'), content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Database name')), actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Create')),
        ]);
      },
    );
    if (name != null && name.isNotEmpty) {
      await _getService()?.create(name);
      _load();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.add), heroTag: null),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dbs.isEmpty
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.storage, size: 48, color: AppTheme.textSecondary), SizedBox(height: 8), Text('No databases')]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _dbs.length,
                    itemBuilder: (context, index) {
                      final db = _dbs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.storage, color: AppTheme.primaryPurple),
                          title: Text(db.name),
                          subtitle: Text('${db.host}:${db.port} • User: ${db.username}', style: const TextStyle(fontSize: 12)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'rotate') {
                                await _getService()?.rotatePassword(db.id);
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password rotated')));
                              } else if (v == 'delete') {
                                await _getService()?.delete(db.id);
                                _load();
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'rotate', child: Text('Rotate Password')),
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
