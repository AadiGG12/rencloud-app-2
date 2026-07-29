import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/pterodactyl/schedule_model.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/pterodactyl/pterodactyl_client.dart';
import '../../../services/pterodactyl/resource_service.dart';

class SchedulesTab extends ConsumerStatefulWidget {
  final String serverId;
  const SchedulesTab({super.key, required this.serverId});

  @override
  ConsumerState<SchedulesTab> createState() => _SchedulesTabState();
}

class _SchedulesTabState extends ConsumerState<SchedulesTab> {
  List<ServerSchedule> _schedules = [];
  bool _isLoading = true;

  ScheduleService? _getService() {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return null;
    return ScheduleService(PterodactylClient(panelUrl: auth.panelUrl!, apiKey: auth.apiKey!), widget.serverId);
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try { _schedules = await _getService()?.list() ?? []; } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _create() async {
    final nameC = TextEditingController();
    final minC = TextEditingController(text: '*');
    final hourC = TextEditingController(text: '*');
    final domC = TextEditingController(text: '*');
    final dowC = TextEditingController(text: '*');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Schedule'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name', isDense: true)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: minC, decoration: const InputDecoration(labelText: 'Minute', isDense: true))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: hourC, decoration: const InputDecoration(labelText: 'Hour', isDense: true))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: domC, decoration: const InputDecoration(labelText: 'Day (Month)', isDense: true))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: dowC, decoration: const InputDecoration(labelText: 'Day (Week)', isDense: true))),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (result == true) {
      await _getService()?.create(nameC.text, minC.text, hourC.text, domC.text, dowC.text);
      _load();
    }
    nameC.dispose(); minC.dispose(); hourC.dispose(); domC.dispose(); dowC.dispose();
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.add), heroTag: null),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.schedule, size: 48, color: AppTheme.textSecondary), SizedBox(height: 8), Text('No schedules')]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final s = _schedules[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(s.isActive ? Icons.check_circle : Icons.pause_circle, color: s.isActive ? Colors.green : Colors.orange),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s.cronExpression, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'toggle') {
                                await _getService()?.update(s.id, isActive: !s.isActive);
                                _load();
                              } else if (v == 'execute') {
                                await _getService()?.execute(s.id);
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule executed')));
                              } else if (v == 'delete') {
                                await _getService()?.delete(s.id);
                                _load();
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'toggle', child: Text(s.isActive ? 'Pause' : 'Activate')),
                              const PopupMenuItem(value: 'execute', child: Text('Execute Now')),
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
