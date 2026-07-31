import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/pterodactyl_provider.dart';
import '../../../services/backend/server_service.dart';

class ConsoleTab extends ConsumerStatefulWidget {
  final String serverId;
  const ConsoleTab({super.key, required this.serverId});

  @override
  ConsumerState<ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends ConsumerState<ConsoleTab> {
  final List<String> _lines = [];
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  WebSocketChannel? _channel;
  bool _isConnected = false;
  StreamSubscription? _sub;
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    _lines.add('Connecting to console...');
    _connect();
  }

  Future<void> _connect() async {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return;

    try {
      final creds = await BackendServerService.getWebSocketCredentials(widget.serverId);
      final wsUrl = creds['socket']?.toString() ?? '';

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      // Authenticate
      _channel!.sink.add(json.encode({'event': 'auth', 'args': [creds['token'] ?? '']}));

      _sub = _channel!.stream.listen(
        (data) {
          final msg = json.decode(data as String) as Map<String, dynamic>;
          final event = msg['event'] as String?;
          final args = msg['args'] as List? ?? [];

          if (event == 'auth success') {
            setState(() {
              _isConnected = true;
              _lines.add('=== Connected to console ===');
            });
            _startStatsPoller();
          } else if (event == 'console output') {
            setState(() {
              for (var arg in args) {
                _lines.add(arg.toString());
              }
              if (_lines.length > 500) _lines.removeRange(0, _lines.length - 500);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());
          } else if (event == 'status') {
            setState(() => _lines.add('[Status: ${args.first}]'));
          } else if (event == 'token expiring') {
            _renewToken();
          } else if (event == 'token expired') {
            _lines.add('Token expired, reconnecting...');
            _reconnect();
          }
        },
        onError: (e) => setState(() => _lines.add('WebSocket error: $e')),
        onDone: () {
          setState(() => _isConnected = false);
          Future.delayed(const Duration(seconds: 3), _reconnect);
        },
      );
    } catch (e) {
      setState(() => _lines.add('Failed to connect: $e'));
    }
  }

  void _startStatsPoller() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_channel != null && _isConnected) {
        _channel!.sink.add(json.encode({'event': 'send stats'}));
      }
    });
  }

  void _renewToken() async {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return;
    try {
      final creds = await BackendServerService.getWebSocketCredentials(widget.serverId);
      _channel!.sink.add(json.encode({'event': 'auth', 'args': [creds['token'] ?? '']}));
    } catch (e) {
      if (!mounted) return;
      setState(() => _lines.add('Token renewal failed: $e'));
    }
  }

  void _reconnect() {
    _channel?.sink.close();
    _sub?.cancel();
    _statsTimer?.cancel();
    _connect();
  }

  void _sendCommand() {
    final cmd = _cmdController.text.trim();
    if (cmd.isEmpty || _channel == null) return;
    _channel!.sink.add(json.encode({'event': 'send command', 'args': [cmd]}));
    setState(() => _lines.add('> $cmd'));
    _cmdController.clear();
  }

  void _sendPowerAction(String action) async {
    final auth = ref.read(pterodactylAuthProvider);
    if (auth.panelUrl == null || auth.apiKey == null) return;
    try {
      await BackendServerService.sendPowerSignal(widget.serverId, action);
      if (!mounted) return;
      setState(() => _lines.add('[Power: $action]'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _lines.add('[Power failed: $e]'));
    }
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _cmdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Power Actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: isDark ? AppTheme.cardSurfaceDark : Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PowerButton(label: 'Start', icon: Icons.play_arrow, color: Colors.green, onTap: () => _sendPowerAction('start')),
              _PowerButton(label: 'Restart', icon: Icons.replay, color: Colors.orange, onTap: () => _sendPowerAction('restart')),
              _PowerButton(label: 'Stop', icon: Icons.stop, color: Colors.red, onTap: () => _sendPowerAction('stop')),
              _PowerButton(label: 'Kill', icon: Icons.block, color: Colors.red.shade900, onTap: () => _sendPowerAction('kill')),
            ],
          ),
        ),
        // Console output
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF0D1117) : const Color(0xFF1E1E1E),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _lines.length,
              itemBuilder: (context, index) {
                final line = _lines[index];
                return Text(
                  line,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: line.startsWith('[') ? Colors.orangeAccent : const Color(0xFFC9D1D9),
                  ),
                );
              },
            ),
          ),
        ),
        // Command input
        Container(
          padding: const EdgeInsets.all(8),
          color: isDark ? AppTheme.cardSurfaceDark : Colors.grey.shade200,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cmdController,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter command...',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0D1117) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendCommand(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendCommand,
                icon: const Icon(Icons.send, size: 18),
                style: IconButton.styleFrom(backgroundColor: AppTheme.accentAqua),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PowerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PowerButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
