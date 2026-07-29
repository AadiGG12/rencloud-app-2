import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../services/pterodactyl/admin_service.dart';
import 'admin_user_list_screen.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _panelUrlController = TextEditingController(text: 'https://panel.rencloud.online');
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter panel URL and Application API key')),
      );
      return;
    }
    final success = await ref.read(adminAuthProvider.notifier).login(panelUrl, apiKey);
    if (success && mounted) {
      final service = AdminService(panelUrl, apiKey);
      ref.read(adminUserListProvider.notifier).setService(service);
      ref.read(adminUserListProvider.notifier).fetchUsers();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(adminAuthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentAqua.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings, size: 64, color: AppTheme.accentAqua),
              ),
              const SizedBox(height: 24),
              const Text('Admin Panel Access', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Enter your Pterodactyl Application API key',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This requires an Application API key from Admin > Application API, not a Client API key',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: 'Application API Key',
                  hintText: 'ptla_...',
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentAqua,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Connect Admin Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
