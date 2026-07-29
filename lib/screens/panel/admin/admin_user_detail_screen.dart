import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/pterodactyl/panel_user_model.dart';
import '../../../providers/admin_provider.dart';

class AdminUserDetailScreen extends ConsumerStatefulWidget {
  final PanelUser user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  ConsumerState<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends ConsumerState<AdminUserDetailScreen> {
  late bool _isAdmin;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.user.isAdmin;
  }

  Future<void> _toggleAdmin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isAdmin ? 'Revoke Admin' : 'Make Admin'),
        content: Text(
          _isAdmin
              ? 'Remove admin privileges from ${widget.user.username}?'
              : 'Grant admin privileges to ${widget.user.username}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAdmin ? Colors.red : AppTheme.accentAqua,
              foregroundColor: Colors.white,
            ),
            child: Text(_isAdmin ? 'Revoke' : 'Grant'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(adminUserListProvider.notifier).updateUser(
        widget.user.id,
        rootAdmin: !_isAdmin,
      );
      if (success && mounted) {
        setState(() => _isAdmin = !_isAdmin);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAdmin ? 'Admin privileges granted' : 'Admin privileges revoked'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Permanently delete ${widget.user.username} (${widget.user.email})? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      final success = await ref.read(adminUserListProvider.notifier).deleteUser(widget.user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      } else if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete user'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isDeleting ? null : _deleteUser,
            tooltip: 'Delete User',
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: user.isAdmin
                              ? AppTheme.accentAqua.withValues(alpha: 0.2)
                              : AppTheme.primaryPurple.withValues(alpha: 0.2),
                          child: Text(
                            user.initials,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: user.isAdmin ? AppTheme.accentAqua : AppTheme.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBadge(user.isAdmin ? 'Admin' : 'User',
                                user.isAdmin ? AppTheme.accentAqua : AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            _buildBadge(
                              user.hasTwoFactor ? '2FA Enabled' : '2FA Disabled',
                              user.hasTwoFactor ? const Color(0xFF10B981) : Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Details
                  _buildDetailCard(isDark, [
                    _DetailRow(label: 'User ID', value: '#${user.id}'),
                    _DetailRow(label: 'UUID', value: user.uuid),
                    _DetailRow(label: 'Username', value: user.username),
                    _DetailRow(label: 'Email', value: user.email),
                    _DetailRow(label: 'Name', value: user.fullName),
                    _DetailRow(label: 'Language', value: user.language.toUpperCase()),
                    _DetailRow(label: 'External ID', value: user.externalId ?? 'None'),
                  ]),
                  const SizedBox(height: 12),

                  // Dates
                  _buildDetailCard(isDark, [
                    _DetailRow(
                      label: 'Created',
                      value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                    _DetailRow(
                      label: 'Last Updated',
                      value: '${user.updatedAt.day}/${user.updatedAt.month}/${user.updatedAt.year}',
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _toggleAdmin,
                      icon: Icon(_isAdmin ? Icons.manage_accounts : Icons.admin_panel_settings, color: Colors.white),
                      label: Text(
                        _isAdmin ? 'Revoke Admin Privileges' : 'Grant Admin Privileges',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAdmin ? Colors.red : AppTheme.accentAqua,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _deleteUser,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete User', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildDetailCard(bool isDark, List<_DetailRow> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Column(
        children: rows.map((row) {
          final isLast = rows.last == row;
          return Column(
            children: [
              row,
              if (!isLast) const Divider(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
