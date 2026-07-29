import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/admin_provider.dart';

class AdminUserCreateDialog extends ConsumerStatefulWidget {
  const AdminUserCreateDialog({super.key});

  @override
  ConsumerState<AdminUserCreateDialog> createState() => _AdminUserCreateDialogState();
}

class _AdminUserCreateDialogState extends ConsumerState<AdminUserCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _firstNameCtl = TextEditingController();
  final _lastNameCtl = TextEditingController();
  bool _isAdmin = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _firstNameCtl.dispose();
    _lastNameCtl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    final success = await ref.read(adminUserListProvider.notifier).createUser(
      username: _usernameCtl.text.trim(),
      email: _emailCtl.text.trim(),
      firstName: _firstNameCtl.text.trim(),
      lastName: _lastNameCtl.text.trim(),
      rootAdmin: _isAdmin,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create user'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAqua.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add, color: AppTheme.accentAqua, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New User',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameCtl,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  prefixIcon: Icon(Icons.person, size: 20),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email, size: 20),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtl,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.badge, size: 20),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Administrator', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Grant full admin panel access'),
                value: _isAdmin,
                onChanged: (v) => setState(() => _isAdmin = v),
                secondary: Icon(
                  _isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: _isAdmin ? AppTheme.accentAqua : AppTheme.textSecondary,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentAqua,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isCreating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create User', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
