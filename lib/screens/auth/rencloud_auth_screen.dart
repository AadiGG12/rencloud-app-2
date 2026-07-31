import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/rencloud_auth_provider.dart';
import '../../services/biometric_service.dart';

class RenCloudAuthScreen extends ConsumerStatefulWidget {
  final bool initialIsRegister;
  const RenCloudAuthScreen({super.key, this.initialIsRegister = false});

  @override
  ConsumerState<RenCloudAuthScreen> createState() => _RenCloudAuthScreenState();
}

class _RenCloudAuthScreenState extends ConsumerState<RenCloudAuthScreen> with SingleTickerProviderStateMixin {
  late bool _isRegister;
  bool _biometricVerified = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  Future<void> _handleBiometric() async {
    final auth = await BiometricService.authenticate(reason: 'Step 1 Verification');
    if (auth && mounted) {
      setState(() => _biometricVerified = true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isRegister && !_biometricVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete biometric verification first.')),
      );
      return;
    }

    final notifier = ref.read(rencloudAuthProvider.notifier);
    if (_isRegister) {
      final res = await notifier.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (res.success && mounted) Navigator.pop(context);
    } else {
      final res = await notifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (res.success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(rencloudAuthProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090D16), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.accentCyan.withValues(alpha: 0.3), blurRadius: 20)
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png', height: 60),
                  ),
                  const SizedBox(height: 32),
                  
                  if (authState.isAuthenticated && user != null) ...[
                    Card(
                      color: Colors.white.withValues(alpha: 0.05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(radius: 30, backgroundColor: AppTheme.primaryPurple, child: const Icon(Icons.person, color: Colors.white)),
                            const SizedBox(height: 16),
                            Text(user.fullName, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(user.email, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => ref.read(rencloudAuthProvider.notifier).logout(),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Card(
                      color: Colors.white.withValues(alpha: 0.05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey(_isRegister),
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isRegister = false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: !_isRegister ? AppTheme.primaryPurple : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('Login', style: TextStyle(color: !_isRegister ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isRegister = true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _isRegister ? AppTheme.primaryPurple : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('Register', style: TextStyle(color: _isRegister ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                if (!_isRegister) ...[
                                  ElevatedButton.icon(
                                    onPressed: _handleBiometric,
                                    icon: Icon(_biometricVerified ? Icons.check_circle : Icons.fingerprint, color: Colors.white),
                                    label: Text(_biometricVerified ? 'Biometric Verified' : 'Step 1: Biometric Login'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _biometricVerified ? Colors.green : AppTheme.accentCyan,
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (_isRegister) ...[
                                  TextFormField(
                                    controller: _nameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person, color: AppTheme.accentCyan)),
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                TextFormField(
                                  controller: _emailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email, color: AppTheme.accentCyan)),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock, color: AppTheme.accentCyan),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.accentCyan),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: authState.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    backgroundColor: AppTheme.primaryPurple,
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(_isRegister ? 'Register' : 'Step 2: Login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
