import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/catalog_provider.dart';
import '../../services/biometric_service.dart';

/// Reusable Biometric Lock Screen Overlay
/// Wraps any screen and enforces Fingerprint / Face ID lock when biometrics is enabled.
class BiometricLockOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const BiometricLockOverlay({super.key, required this.child});

  @override
  ConsumerState<BiometricLockOverlay> createState() => _BiometricLockOverlayState();
}

class _BiometricLockOverlayState extends ConsumerState<BiometricLockOverlay> with WidgetsBindingObserver {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptBiometric();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Lock app when sent to background
      ref.read(biometricProvider.notifier).lock();
    } else if (state == AppLifecycleState.resumed) {
      // Prompt lock when returning to foreground
      _checkAndPromptBiometric();
    }
  }

  Future<void> _checkAndPromptBiometric() async {
    final biometric = ref.read(biometricProvider);
    if (biometric.isEnabled && !biometric.isUnlocked && !_isAuthenticating) {
      _isAuthenticating = true;
      final success = await BiometricService.authenticate(
        reason: 'Unlock RenCloud Control Panel with Fingerprint or Face ID',
      );
      _isAuthenticating = false;

      if (success) {
        ref.read(biometricProvider.notifier).unlock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometric = ref.watch(biometricProvider);

    if (biometric.isEnabled && !biometric.isUnlocked) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentAqua.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.fingerprint, size: 72, color: AppTheme.accentAqua),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'RenCloud App Locked',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Biometric authentication is required to access your servers and account preferences.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton.icon(
                    onPressed: _checkAndPromptBiometric,
                    icon: const Icon(Icons.fingerprint, color: Colors.white),
                    label: const Text(
                      'Scan Fingerprint / Face ID',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
