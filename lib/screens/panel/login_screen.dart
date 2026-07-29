import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pterodactyl/server_model.dart';
import '../../providers/pterodactyl_provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/pterodactyl/auth_service.dart';
import '../../services/pterodactyl/pterodactyl_client.dart';
import '../../services/pterodactyl/admin_service.dart';
import 'admin/admin_dashboard_screen.dart';
import 'tabs/console_tab.dart';
import 'tabs/files_tab.dart';
import 'tabs/databases_tab.dart';
import 'tabs/schedules_tab.dart';
import 'tabs/backups_tab.dart';
import 'tabs/network_tab.dart';
import 'tabs/users_tab.dart';

// ─── Unified Login Screen ─────────────────────────────────────────────
// Detects whether the API key is a Client Key or Application Key
// and routes to the appropriate dashboard.

class PterodactylLoginScreen extends ConsumerStatefulWidget {
  const PterodactylLoginScreen({super.key});

  @override
  ConsumerState<PterodactylLoginScreen> createState() => _PterodactylLoginScreenState();
}

class _PterodactylLoginScreenState extends ConsumerState<PterodactylLoginScreen> {
  final _panelUrlController = TextEditingController(text: 'https://panel.rencloud.online');
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _panelUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final panelUrl = _panelUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (panelUrl.isEmpty || apiKey.isEmpty) {
      setState(() => _error = 'Please enter panel URL and API key');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Detect key type (try both APIs in parallel - just 2 calls)
    final keyType = await AuthService.detectKeyType(panelUrl, apiKey);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (keyType == ApiKeyType.unknown) {
      setState(() => _error = 'Invalid API key. Check your panel URL and try again.');
      return;
    }

    if (keyType == ApiKeyType.client) {
      // ── Client key → My Servers (also check if user is panel admin) ──
      final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);

      // Fetch account info to check admin status
      final account = await AuthService.fetchAccount(panelUrl, apiKey);

      // Set auth state directly (detectKeyType already validated connectivity)
      ref.read(pterodactylAuthProvider.notifier).setAdminInfo(
        isAdmin: account.isAdmin,
        email: account.email,
        username: account.username,
      );
      ref.read(pterodactylServerListProvider.notifier).setClient(client);
      ref.read(pterodactylServerListProvider.notifier).fetchServers();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PterodactylServerListScreen()),
        );
      }
    } else {
      // ── Application key → Admin Dashboard ──
      final service = AdminService(panelUrl, apiKey);
      ref.read(adminAuthProvider.notifier).login(panelUrl, apiKey);
      ref.read(adminUserListProvider.notifier).setService(service);
      ref.read(adminAllServersProvider.notifier).setService(service);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.dns, size: 64, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 24),
              const Text('Connect to Panel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Enter your Pterodactyl panel details.\nWorks with both Client & Admin keys.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Panel URL
              TextField(
                controller: _panelUrlController,
                decoration: InputDecoration(
                  labelText: 'Panel URL',
                  hintText: 'https://panel.rencloud.online',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // API Key
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'ptlc_... or ptla_...',
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 8),

              // Info box about key types
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentAqua.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppTheme.accentAqua),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🔹 Client Key (ptlc_): Manage your servers\n'
                        '🔹 Admin Key (ptla_): Dashboard + all users & servers',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Connect Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Connect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Back
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Client: My Servers List ──────────────────────────────────────────

class PterodactylServerListScreen extends ConsumerStatefulWidget {
  const PterodactylServerListScreen({super.key});

  @override
  ConsumerState<PterodactylServerListScreen> createState() => _PterodactylServerListScreenState();
}

class _PterodactylServerListScreenState extends ConsumerState<PterodactylServerListScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pterodactylServerListProvider);
    final auth = ref.watch(pterodactylAuthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('My Servers'),
            if (auth.isAdmin) ...[const SizedBox(width: 8), _AdminBadge()],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pterodactylServerListProvider.notifier).fetchServers(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(pterodactylAuthProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PterodactylLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Upgrade Banner
          if (auth.isAdmin)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentAqua.withValues(alpha: 0.15),
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: AppTheme.accentAqua.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAqua.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: AppTheme.accentAqua, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You have admin privileges',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Use an Application API key (ptla_) for full admin access',
                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PterodactylLoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16, color: AppTheme.accentAqua),
                    label: const Text('Admin Key', style: TextStyle(fontSize: 12, color: AppTheme.accentAqua, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ],
              ),
            ),
          // Server List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(pterodactylServerListProvider.notifier).fetchServers(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : state.servers.isEmpty
                        ? const Center(child: Text('No servers found'))
                        : RefreshIndicator(
                            onRefresh: () => ref.read(pterodactylServerListProvider.notifier).fetchServers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.servers.length,
                              itemBuilder: (context, index) {
                                final server = state.servers[index];
                                return _ServerCard(server: server, isDark: isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentAqua.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.4)),
      ),
      child: const Text(
        'Admin',
        style: TextStyle(fontSize: 9, color: AppTheme.accentAqua, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ServerCard extends ConsumerWidget {
  final PterodactylServer server;
  final bool isDark;

  const _ServerCard({required this.server, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(serverResourcesProvider(server.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PterodactylServerDetailScreen(server: server)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: server.isSuspended
                          ? Colors.orange
                          : server.isInstalling ? Colors.yellow : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(server.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (server.isSuspended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Suspended', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                  if (server.isInstalling)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Installing', style: TextStyle(fontSize: 10, color: Colors.yellow, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              resourcesAsync.when(
                data: (res) => res != null
                    ? Column(
                        children: [
                          _ResourceBar(label: 'CPU', percent: res.cpuPercent, color: AppTheme.accentAqua),
                          const SizedBox(height: 6),
                          _ResourceBar(label: 'RAM', percent: res.memoryPercent, color: AppTheme.primaryPurple),
                          const SizedBox(height: 6),
                          _ResourceBar(label: 'Disk', percent: res.diskPercent, color: Color(0xFF10B981)),
                        ],
                      )
                    : const SizedBox(),
                loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 8),
              Text(
                '${server.limits.cpu}% CPU · ${server.limits.memory}MB RAM · ${server.limits.disk}MB Disk',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _ResourceBar({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30, child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 40, child: Text('${percent.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
      ],
    );
  }
}

// ─── Client: Server Detail with Tabs ──────────────────────────────────

class PterodactylServerDetailScreen extends ConsumerStatefulWidget {
  final PterodactylServer server;
  const PterodactylServerDetailScreen({super.key, required this.server});

  @override
  ConsumerState<PterodactylServerDetailScreen> createState() => _PterodactylServerDetailScreenState();
}

class _PterodactylServerDetailScreenState extends ConsumerState<PterodactylServerDetailScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const Tab(text: 'Console', icon: Icon(Icons.terminal)),
      const Tab(text: 'Files', icon: Icon(Icons.folder)),
      const Tab(text: 'Databases', icon: Icon(Icons.storage)),
      const Tab(text: 'Schedules', icon: Icon(Icons.schedule)),
      const Tab(text: 'Backups', icon: Icon(Icons.backup)),
      const Tab(text: 'Network', icon: Icon(Icons.lan)),
      const Tab(text: 'Users', icon: Icon(Icons.people)),
    ];

    final screens = [
      ConsoleTab(serverId: widget.server.id),
      FilesTab(serverId: widget.server.id),
      DatabasesTab(serverId: widget.server.id),
      SchedulesTab(serverId: widget.server.id),
      BackupsTab(serverId: widget.server.id),
      NetworkTab(serverId: widget.server.id),
      UsersTab(serverId: widget.server.id),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.server.name),
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
            onTap: (i) => setState(() => _currentTab = i),
          ),
        ),
        body: screens[_currentTab],
      ),
    );
  }
}
