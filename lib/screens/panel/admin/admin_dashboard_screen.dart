import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/admin_provider.dart';
import '../login_screen.dart';
import 'admin_user_list_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminAllServersProvider.notifier).fetchAllServers();
      ref.read(adminUserListProvider.notifier).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminDashboardStatsProvider);
    final serversState = ref.watch(adminAllServersProvider);
    final usersState = ref.watch(adminUserListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentAqua.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: AppTheme.accentAqua, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Admin Panel'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminAllServersProvider.notifier).fetchAllServers();
              ref.read(adminUserListProvider.notifier).fetchUsers();
            },
            tooltip: 'Refresh All',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(adminAuthProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PterodactylLoginScreen()),
              );
            },
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Stats Cards ─────────────────────────────────────
            Row(
              children: [
                Expanded(child: _StatCard(
                  icon: Icons.dns,
                  label: 'Servers',
                  value: '${stats.totalServers}',
                  color: AppTheme.primaryPurple,
                  isLoading: serversState.isLoading,
                )),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(
                  icon: Icons.people,
                  label: 'Users',
                  value: '${stats.totalUsers}',
                  color: AppTheme.accentAqua,
                  isLoading: usersState.isLoading,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _StatCard(
                  icon: Icons.admin_panel_settings,
                  label: 'Admins',
                  value: '${stats.adminCount}',
                  color: const Color(0xFF10B981),
                  isLoading: usersState.isLoading,
                )),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(
                  icon: Icons.warning_amber,
                  label: 'Suspended',
                  value: '${stats.suspendedServers}',
                  color: Colors.orange,
                  isLoading: serversState.isLoading,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _StatCard(
                  icon: Icons.memory,
                  label: 'Total RAM',
                  value: _formatBytes(stats.totalMemoryMb * 1024 * 1024),
                  color: AppTheme.primaryPurple,
                  isLoading: serversState.isLoading,
                )),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(
                  icon: Icons.storage,
                  label: 'Total Disk',
                  value: _formatBytes(stats.totalDiskMb * 1024 * 1024),
                  color: AppTheme.accentAqua,
                  isLoading: serversState.isLoading,
                )),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Quick Actions ───────────────────────────────────
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ActionChip(
                  icon: Icons.people,
                  label: 'Manage Users',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(child: _ActionChip(
                  icon: Icons.refresh,
                  label: 'Refresh All',
                  onTap: () {
                    ref.read(adminAllServersProvider.notifier).fetchAllServers();
                    ref.read(adminUserListProvider.notifier).fetchUsers();
                  },
                )),
              ],
            ),
            const SizedBox(height: 20),

            // ─── All Servers List ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Servers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (serversState.isLoading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 8),

            if (serversState.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(serversState.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              )
            else if (serversState.servers.isEmpty && !serversState.isLoading)
              Container(
                padding: const EdgeInsets.all(32),
                child: const Center(child: Text('No servers found', style: TextStyle(color: AppTheme.textSecondary))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: serversState.servers.length,
                itemBuilder: (context, index) {
                  final s = serversState.servers[index];
                  final isSuspended = s.isSuspended;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSuspended ? Colors.orange : s.isInstalling ? Colors.yellow : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.limits.cpu}% · ${s.limits.memory}MB · ${s.limits.disk}MB',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                                if (s.ownerEmail != null)
                                  Text(
                                    'Owner: ${s.ownerEmail}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.accentAqua),
                                  ),
                              ],
                            ),
                          ),
                          if (isSuspended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Suspended', style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}



class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentAqua, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
