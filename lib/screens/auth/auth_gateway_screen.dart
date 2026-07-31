import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/rencloud_auth_provider.dart';
import '../../services/biometric_service.dart';
import '../mobile_home_screen.dart';
import 'rencloud_auth_screen.dart';
import '../widgets/skeuomorphic_card.dart';

/// Mandatory App Entry Gateway:
/// Step 1: Biometric Verification
/// Step 2: Account Login / Register (if not logged in)
/// Step 3: Main App Interface
class AuthGatewayScreen extends ConsumerStatefulWidget {
  const AuthGatewayScreen({super.key});

  @override
  ConsumerState<AuthGatewayScreen> createState() => _AuthGatewayScreenState();
}

class _AuthGatewayScreenState extends ConsumerState<AuthGatewayScreen> {
  bool _biometricVerified = false;
  bool _isCheckingBiometrics = true;

  @override
  void initState() {
    super.initState();
    _startGatewayCheck();
  }

  Future<void> _startGatewayCheck() async {
    setState(() => _isCheckingBiometrics = true);

    // Check biometrics availability & verify
    final hasBiometrics = await BiometricService.canAuthenticate();
    if (hasBiometrics) {
      final verified = await BiometricService.authenticate(
        reason: 'Verify fingerprint or face to unlock RenCloud App',
      );
      if (verified) {
        HapticFeedback.heavyImpact();
        setState(() {
          _biometricVerified = true;
          _isCheckingBiometrics = false;
        });
      } else {
        setState(() => _isCheckingBiometrics = false);
      }
    } else {
      // Biometrics not available on device, bypass biometrics step
      setState(() {
        _biometricVerified = true;
        _isCheckingBiometrics = false;
      });
    }
  }

  void _proceedToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MobileHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(rencloudAuthProvider);

    // If both Biometric Verified AND Logged In -> Open Main App Interface
    if (_biometricVerified && authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _proceedToApp();
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.metallicDarkGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // RenCloud Glowing Logo Badge
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D16),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.8), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentAqua.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.cloud, color: AppTheme.accentAqua, size: 56),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'RenCloud Gateway',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Security verification & account login required',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // STEP 1: Biometric Verification Card
                    SkeuomorphicCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _biometricVerified
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : AppTheme.accentAqua.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _biometricVerified ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                                  color: _biometricVerified ? Colors.green : AppTheme.accentAqua,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Step 1: Biometrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(
                                      _biometricVerified ? 'Verified Successfully' : 'Fingerprint / Face ID Check',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _biometricVerified ? Colors.green : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!_biometricVerified) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isCheckingBiometrics ? null : _startGatewayCheck,
                                icon: const Icon(Icons.fingerprint, color: AppTheme.accentAqua, size: 18),
                                label: Text(
                                  _isCheckingBiometrics ? 'Verifying...' : 'Unlock with Biometrics',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.accentAqua),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // STEP 2: RenCloud Account Login Card
                    SkeuomorphicCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: authState.isAuthenticated
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : AppTheme.primaryPurple.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  authState.isAuthenticated ? Icons.verified_user_rounded : Icons.lock_person_rounded,
                                  color: authState.isAuthenticated ? Colors.green : AppTheme.primaryPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Step 2: Account Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(
                                      authState.isAuthenticated
                                          ? 'Logged in as ${authState.user?.fullName ?? "User"}'
                                          : 'Login or Register to continue',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: authState.isAuthenticated ? Colors.green : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          if (!authState.isAuthenticated) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: !_biometricVerified
                                        ? null
                                        : () {
                                            HapticFeedback.mediumImpact();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => const RenCloudAuthScreen(initialIsRegister: false)),
                                            );
                                          },
                                    icon: const Icon(Icons.login_rounded, size: 16, color: Colors.white),
                                    label: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryDarkPurple,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: !_biometricVerified
                                        ? null
                                        : () {
                                            HapticFeedback.mediumImpact();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => const RenCloudAuthScreen(initialIsRegister: true)),
                                            );
                                          },
                                    icon: const Icon(Icons.person_add_rounded, size: 16, color: AppTheme.accentAqua),
                                    label: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accentAqua)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppTheme.accentAqua),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (_biometricVerified) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _proceedToApp,
                                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black),
                                label: const Text('ENTER APP INTERFACE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentAqua,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
