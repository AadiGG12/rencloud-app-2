import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/rencloud_auth_provider.dart';
import '../../services/biometric_service.dart';
import '../widgets/skeuomorphic_card.dart';

class RenCloudAuthScreen extends ConsumerStatefulWidget {
  final bool initialIsRegister;

  const RenCloudAuthScreen({super.key, this.initialIsRegister = false});

  @override
  ConsumerState<RenCloudAuthScreen> createState() => _RenCloudAuthScreenState();
}

class _RenCloudAuthScreenState extends ConsumerState<RenCloudAuthScreen> {
  late bool _isRegister;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    final authNotifier = ref.read(rencloudAuthProvider.notifier);

    if (_isRegister) {
      final result = await authNotifier.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
        if (result.success) {
          Navigator.pop(context);
        }
      }
    } else {
      final result = await authNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
        if (result.success) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await BiometricService.authenticate(
      reason: 'Scan fingerprint or face to log in to RenCloud',
    );

    if (authenticated && mounted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric authentication verified!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();
    await ref.read(rencloudAuthProvider.notifier).logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out of RenCloud account successfully.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(rencloudAuthProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(authState.isAuthenticated ? 'Account Management' : (_isRegister ? 'Create RenCloud Account' : 'Account Login')),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Header Logo Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentAqua.withValues(alpha: 0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.cloud, color: AppTheme.accentAqua, size: 48),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'RenCloud Platform',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Manage cloud servers, databases & deployments',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAqua.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '🔗 Synced with Panel (panel.rencloud.online)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentAqua),
                  ),
                ),
                const SizedBox(height: 20),

                // IF USER IS ALREADY AUTHENTICATED: Show Profile Card + Logout Button!
                if (authState.isAuthenticated && user != null) ...[
                  SkeuomorphicCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: user.isAdmin ? AppTheme.accentAqua : AppTheme.primaryPurple,
                          child: Icon(user.isAdmin ? Icons.shield_rounded : Icons.person_rounded, color: Colors.black, size: 36),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: user.isAdmin ? AppTheme.metallicGoldGradient : AppTheme.metallicSteelGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isAdmin ? '👑 SUPER ADMIN' : 'CLIENT ACCOUNT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: user.isAdmin ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                            label: const Text('LOG OUT ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Skeuomorphic Auth Form Card
                  SkeuomorphicCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Login / Register Selector Pills
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _isRegister = false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: !_isRegister ? AppTheme.metallicSteelGradient : null,
                                      color: _isRegister
                                          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: !_isRegister ? Colors.white : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _isRegister = true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: _isRegister ? AppTheme.metallicSteelGradient : null,
                                      color: !_isRegister
                                          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'REGISTER',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: _isRegister ? Colors.white : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Full Name Field (Register Mode Only)
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person, color: AppTheme.accentAqua),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (val) {
                                if (_isRegister && (val == null || val.trim().isEmpty)) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Email Address Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email, color: AppTheme.accentAqua),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty || !val.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock, color: AppTheme.accentAqua),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Confirm Password Field (Register Mode Only)
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.accentAqua),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (val) {
                                if (_isRegister && val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          const SizedBox(height: 8),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: AppTheme.metallicSteelGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _isRegister ? 'CREATE ACCOUNT' : 'LOG IN',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                                    ),
                            ),
                          ),

                          // Biometric Quick Login Shortcut (Login Mode Only)
                          if (!_isRegister) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: _handleBiometricLogin,
                                icon: const Icon(Icons.fingerprint, color: AppTheme.accentAqua),
                                label: const Text('Fast Login with Biometrics', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.accentAqua.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
