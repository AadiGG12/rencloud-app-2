import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/pterodactyl/file_model.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/pterodactyl/file_service.dart';
import '../../../services/pterodactyl/pterodactyl_client.dart';

class FilesTab extends ConsumerStatefulWidget {
  final String serverId;
  const FilesTab({super.key, required this.serverId});

  @override
  ConsumerState<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends ConsumerState<FilesTab> {
  List<ServerFile> _files = [];
  bool _isLoading = true;
  String _currentDir = '/';
  String? _error;

  FileService? _getService() {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return null;
    return FileService(PterodactylClient(panelUrl: auth.panelUrl!, apiKey: auth.apiKey!), widget.serverId);
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final service = _getService();
    if (service == null) return;
    try {
      final files = await service.listFiles(_currentDir);
      setState(() { _files = files; _isLoading = false; _error = null; });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _enterDir(String name) {
    setState(() {
      _currentDir = _currentDir == '/' ? '/$name' : '$_currentDir/$name';
    });
    _loadFiles();
  }

  Future<void> _createFolder() async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(title: const Text('Create Folder'), content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Folder name'), autofocus: true),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Create'))]);
      },
    );
    if (name != null && name.isNotEmpty) {
      await _getService()?.createFolder(name, _currentDir);
      _loadFiles();
    }
  }

  Future<void> _deleteFile(ServerFile file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(title: const Text('Delete'), content: Text('Delete ${file.name}?'), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white)),
      ]),
    );
    if (confirm == true) {
      await _getService()?.deleteFiles([file.path]);
      _loadFiles();
    }
  }

  Future<void> _renameFile(ServerFile file) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController(text: file.name);
        return AlertDialog(title: const Text('Rename'), content: TextField(controller: c, autofocus: true),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Rename'))]);
      },
    );
    if (name != null && name.isNotEmpty && name != file.name) {
      await _getService()?.renameFile(file.path, '${_currentDir == '/' ? "" : _currentDir}/$name');
      _loadFiles();
    }
  }

  Future<void> _editFile(ServerFile file) async {
    if (!file.isText) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot edit binary files')));
      return;
    }
    final service = _getService();
    if (service == null) return;
    try {
      final content = await service.getFileContents(file.path);
      if (!mounted) return;
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final c = TextEditingController(text: content);
          return AlertDialog(
            title: Text('Edit: ${file.name}'),
            content: SizedBox(width: 500, height: 400, child: TextField(controller: c, maxLines: null, expands: true, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Save'))],
          );
        },
      );
      if (result != null) {
        await service.writeFile(file.path, result);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File saved')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFiles());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Breadcrumb
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: isDark ? AppTheme.cardSurfaceDark : Colors.grey.shade100,
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.home, size: 18), onPressed: () { setState(() => _currentDir = '/'); _loadFiles(); }),
              if (_currentDir != '/') ...[
                const Icon(Icons.chevron_right, size: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(_currentDir, style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(icon: const Icon(Icons.create_new_folder, size: 18), onPressed: _createFolder, tooltip: 'New Folder'),
              IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: _loadFiles, tooltip: 'Refresh'),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _files.isEmpty
                      ? const Center(child: Text('Empty directory'))
                      : RefreshIndicator(
                          onRefresh: _loadFiles,
                          child: ListView.builder(
                            itemCount: _files.length,
                            itemBuilder: (context, index) {
                              final file = _files[index];
                              return ListTile(
                                leading: Icon(
                                  file.isFile ? Icons.insert_drive_file : Icons.folder,
                                  color: file.isFile ? AppTheme.accentAqua : AppTheme.primaryPurple,
                                ),
                                title: Text(file.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                subtitle: file.isFile ? Text(file.sizeFormatted, style: const TextStyle(fontSize: 11)) : null,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    switch (v) {
                                      case 'rename': _renameFile(file);
                                      case 'delete': _deleteFile(file);
                                      case 'edit': _editFile(file);
                                      case 'open': if (!file.isFile) _enterDir(file.name);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    if (!file.isFile) const PopupMenuItem(value: 'open', child: Text('Open')),
                                    if (file.isText) const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                                onTap: () => file.isFile ? _editFile(file) : _enterDir(file.name),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
