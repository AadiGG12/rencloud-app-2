import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pterodactyl/server_model.dart';
import '../../models/pterodactyl/panel_user_model.dart';
import '../../providers/pterodactyl_provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/auth_session_service.dart';
import '../../services/update_service.dart';
import 'admin/admin_dashboard_screen.dart';
import '../mobile_home_screen.dart';
import '../home_screen.dart';
import 'package:flutter/services.dart';
import '../widgets/biometric_lock_overlay.dart';
import '../widgets/glass_card.dart';
import '../widgets/shimmer_loading.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email/username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Authenticate via secure backend proxy
      final PanelUser? matchedUser = await AuthSessionService.authenticateUser(
        emailOrUsername: email,
        password: password,
      );

      if (matchedUser != null) {
        final bool isAdmin = matchedUser.isAdmin;
        final String userEmail = matchedUser.email;
        final String username = matchedUser.username;
        final int userId = matchedUser.id;

        // Set Auth provider state
        ref.read(pterodactylAuthProvider.notifier).setAdminInfo(
          isAdmin: isAdmin,
          email: userEmail,
          username: username,
        );

        // Save persistent login session
        await AuthSessionService.saveSession(
          email: userEmail,
          username: username,
          userId: userId,
          isAdmin: isAdmin,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          ref.read(pterodactylServerListProvider.notifier).fetchServers();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PterodactylServerListScreen()),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Authentication failed. Please check:\n\n1. Your Pterodactyl panel email and password\n2. Your internet connection\n3. That the panel at panel.rencloud.online is accessible';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not connect to the server. The backend may not be deployed yet. Please try again later or check your connection.';
      });
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
              // Brand Icon Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_pin, size: 56, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 20),
              const Text('Panel Account Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your RenCloud email & password\nto access your server management dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // Email / Username Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Gmail / Email or Username *',
                  hintText: 'user@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryPurple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: '••••••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryPurple),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 12),

              // Error Box
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

              // Security Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentAqua.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, size: 16, color: AppTheme.accentAqua),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🔒 Secure SSL encrypted authentication bridge to RenCloud',
                        style: TextStyle(fontSize: 11, color: AppTheme.accentAqua, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Sign In to Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Back Button
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Catalog'),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pterodactylServerListProvider.notifier).fetchServers();
      if (mounted) {
        UpdateService.checkForUpdates(context, silent: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pterodactylServerListProvider);
    final auth = ref.watch(pterodactylAuthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BiometricLockOverlay(
      child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final isPhone = MediaQuery.of(context).size.shortestSide < 600;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => isPhone ? const MobileHomeScreen() : const HomeScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final isPhone = MediaQuery.of(context).size.shortestSide < 600;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => isPhone ? const MobileHomeScreen() : const HomeScreen()),
              );
            },
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
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
            onPressed: () async {
              await AuthSessionService.clearSession();
              ref.read(pterodactylAuthProvider.notifier).logout();
              ref.read(adminAuthProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PterodactylLoginScreen()),
                );
              }
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
          Expanded(
            child: state.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (_, __) => const ServerCardSkeleton(),
                  )
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
    ),
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

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PterodactylServerDetailScreen(server: server)),
        );
      },
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
