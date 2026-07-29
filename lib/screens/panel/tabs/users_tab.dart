import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/pterodactyl/pterodactyl_client.dart';
import '../../../services/pterodactyl/resource_service.dart';

class UsersTab extends ConsumerStatefulWidget {
  final String serverId;
  const UsersTab({super.key, required this.serverId});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  List<Subuser> _users = [];
  bool _isLoading = true;

  SubuserService? _getService() {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return null;
    return SubuserService(PterodactylClient(panelUrl: auth.panelUrl!, apiKey: auth.apiKey!), widget.serverId);
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try { _users = await _getService()?.list() ?? []; } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _add() async {
    final emailC = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subuser'),
        content: TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (result == true && emailC.text.isNotEmpty) {
      await _getService()?.create(emailC.text, ['control', 'view']);
      _load();
    }
    emailC.dispose();
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.person_add), heroTag: null),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.people, size: 48, color: AppTheme.textSecondary), SizedBox(height: 8), Text('No subusers')]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2), child: Text(u.email[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold))),
                          title: Text(u.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${u.permissions.length} permissions', style: const TextStyle(fontSize: 11)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'delete') {
                                await _getService()?.delete(u.id);
                                _load();
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'delete', child: Text('Remove', style: TextStyle(color: Colors.red))),
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
