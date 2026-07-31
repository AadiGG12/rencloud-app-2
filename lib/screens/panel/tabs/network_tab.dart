import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/pterodactyl/server_model.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/pterodactyl/pterodactyl_client.dart';
import '../../../services/pterodactyl/resource_service.dart';

class NetworkTab extends ConsumerStatefulWidget {
  final String serverId;
  const NetworkTab({super.key, required this.serverId});

  @override
  ConsumerState<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends ConsumerState<NetworkTab> {
  List<Allocation> _allocations = [];
  bool _isLoading = true;
  String? _error;

  NetworkService? _getService() {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return null;
    return NetworkService(PterodactylClient(panelUrl: auth.panelUrl!, apiKey: auth.apiKey!), widget.serverId);
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try { 
      _allocations = await _getService()?.list() ?? []; 
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _setPrimary(int id) async {
    await _getService()?.setPrimary(id);
    _load();
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text('Error: $_error'))
            : _allocations.isEmpty
                ? const Center(child: Text('No allocations'))
                : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  itemCount: _allocations.length,
                  itemBuilder: (context, index) {
                    final a = _allocations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.lan, color: a.isPrimary ? AppTheme.accentAqua : AppTheme.textSecondary),
                        title: Row(
                          children: [
                            Text('${a.ip}:${a.port}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (a.isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.accentAqua.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Primary', style: TextStyle(fontSize: 10, color: AppTheme.accentAqua, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: a.ipAlias.isNotEmpty ? Text('Alias: ${a.ipAlias}') : null,
                        trailing: a.isPrimary ? null : TextButton(onPressed: () => _setPrimary(a.id), child: const Text('Set Primary', style: TextStyle(fontSize: 12))),
                      ),
                    );
                  },
                ),
              );
  }
}
