import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_plan.dart';
import '../providers/catalog_provider.dart';
import '../core/constants/app_version.dart';
import '../core/theme/app_theme.dart';
import '../services/app_settings_service.dart';
import '../services/update_service.dart';
import '../services/biometric_service.dart';
import 'panel/login_screen.dart';
import 'widgets/category_tabs.dart';
import 'widgets/plan_card.dart';
import 'package:flutter/services.dart';
import 'widgets/resource_calculator.dart';
import 'widgets/biometric_lock_overlay.dart';
import 'widgets/vertical_3d_plan_carousel.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int _currentIndex = 0;
  bool _isPageLoading = false;

  void _onTabChanged(int idx) {
    if (_currentIndex == idx) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isPageLoading = true;
      _currentIndex = idx;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isPageLoading = false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkForUpdates(context, silent: true);
      }
    });
  }

  void _showDiscordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.discord, color: AppTheme.primaryPurple, size: 28),
            SizedBox(width: 10),
            Text('RenCloud Discord', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Join our official 24/7 Discord Community for instant support & server monitoring:'),
            SizedBox(height: 12),
            SelectableText(
              'https://discord.gg/rencloud',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentAqua, fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied https://discord.gg/rencloud to clipboard!'),
                  backgroundColor: AppTheme.primaryPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
            child: const Text('Copy Discord Invite'),
          ),
        ],
      ),
    );
  }

  void _triggerBiometricTestDialog(bool enable) {
    if (!enable) {
      ref.read(biometricProvider.notifier).toggleBiometrics(false);
      AppSettingsService.saveBiometrics(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric Security Lock Disabled')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _BiometricPromptDialog(
          onSuccess: () {
            ref.read(biometricProvider.notifier).toggleBiometrics(true);
            AppSettingsService.saveBiometrics(true);
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric Fingerprint / Face ID Verified & Enabled!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          },
          onCancel: () {
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(filteredPlansProvider);
    final cycle = ref.watch(billingCycleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    final biometric = ref.watch(biometricProvider);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      // Tab 0: Home Catalog
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search 55 server plans...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryPurple),
                filled: true,
                fillColor: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Billing Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Monthly'),
                  selected: cycle == BillingCycle.monthly,
                  onSelected: (_) => ref.read(billingCycleProvider.notifier).state = BillingCycle.monthly,
                  selectedColor: AppTheme.primaryPurple,
                  labelStyle: TextStyle(
                    color: cycle == BillingCycle.monthly ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimary),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Annual (Save 15%)'),
                  selected: cycle == BillingCycle.annual,
                  onSelected: (_) => ref.read(billingCycleProvider.notifier).state = BillingCycle.annual,
                  selectedColor: AppTheme.accentAqua,
                  labelStyle: TextStyle(
                    color: cycle == BillingCycle.annual ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimary),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Chips
            const CategoryTabs(),
            const SizedBox(height: 16),

            // Catalog List / Grid
            LayoutBuilder(
              builder: (context, constraints) {
                if (isLandscape || constraints.maxWidth > 550) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      return PlanCard(plan: plans[index]);
                    },
                  );
                }

                return SizedBox(
                  height: 520,
                  child: Vertical3DPlanCarousel(plans: plans),
                );
              },
            ),
          ],
        ),
      ),

      // Tab 1: Custom Calculator
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const ResourceCalculator(),
      ),

      // Tab 2: Settings, Security & Support
      SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                    errorBuilder: (_, __, ___) => const Icon(Icons.headset_mic, size: 60, color: AppTheme.primaryPurple),
                  ),
                  const SizedBox(height: 12),
                  const Text('App Preferences & Security', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAqua.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'RenCloud v${AppVersion.version} (Installed APK)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentAqua),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dark Mode Switch Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: SwitchListTile(
                title: const Text('Dark Mode (Deep Navy)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Switch between Light and Deep Navy theme', style: TextStyle(fontSize: 11)),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppTheme.primaryPurple),
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  final mode = val ? ThemeMode.dark : ThemeMode.light;
                  ref.read(themeModeProvider.notifier).state = mode;
                  AppSettingsService.saveThemeMode(mode);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Multi-Currency Display Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.currency_exchange, color: AppTheme.accentAqua),
                      SizedBox(width: 12),
                      Text('Currency Display', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  DropdownButton<AppCurrency>(
                    value: currency,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: AppCurrency.inr, child: Text('INR (₹)')),
                      DropdownMenuItem(value: AppCurrency.usd, child: Text('USD (\$)')),
                      DropdownMenuItem(value: AppCurrency.eur, child: Text('EUR (€)')),
                      DropdownMenuItem(value: AppCurrency.aed, child: Text('AED (Dh)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(currencyProvider.notifier).state = val;
                        AppSettingsService.saveCurrency(val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Biometric Authentication Switch Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: SwitchListTile(
                title: const Text('Fingerprint / Face ID Lock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Test & require biometric authentication to open app', style: TextStyle(fontSize: 11)),
                secondary: const Icon(Icons.fingerprint, color: AppTheme.accentAqua),
                value: biometric.isEnabled,
                onChanged: (val) => _triggerBiometricTestDialog(val),
              ),
            ),
            // App Version Display Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline, color: AppTheme.primaryPurple, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('App Version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('RenCloud v${AppVersion.version}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'v${AppVersion.version}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Biometric Authentication Switch Tile

            // Pterodactyl Panel Access Button
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PterodactylLoginScreen())),
            icon: const Icon(Icons.dns, color: Colors.white),
            label: const Text(
              '🖥️ Manage My Servers (Panel)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 12),
          // Update App Button
            ElevatedButton.icon(
              onPressed: () => UpdateService.checkForUpdates(context, silent: false),
              icon: const Icon(Icons.system_update_sharp, color: Colors.white),
              label: const Text(
                '⚡ Check & Install App Updates',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentAqua,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 12),

            // Functional Discord Button
            ElevatedButton.icon(
              onPressed: _showDiscordDialog,
              icon: const Icon(Icons.discord),
              label: const Text('Join Official RenCloud Discord', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'RenCloud App Version v${AppVersion.version}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    ];

    return BiometricLockOverlay(
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF090D16),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.5), width: 1.2),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 22,
                errorBuilder: (_, __, ___) => const Icon(Icons.cloud, color: AppTheme.accentAqua, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Text('RenCloud'),
          ],
        ),
        actions: [
          // Quick Dark Mode Toggle Button
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryPurple),
            tooltip: 'Toggle Dark / Light Theme',
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          // User Profile / Panel Login Header Icon
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppTheme.accentAqua, size: 28),
            tooltip: 'User Profile & Panel Login',
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PterodactylLoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0.5,
      ),
      body: Column(
        children: [
          if (_isPageLoading)
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentAqua),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: isLandscape
                    ? Row(
                        children: [
                          NavigationRail(
                            selectedIndex: _currentIndex,
                            onDestinationSelected: _onTabChanged,
                            labelType: NavigationRailLabelType.all,
                            selectedIconTheme: const IconThemeData(color: AppTheme.accentAqua),
                            unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
                            destinations: const [
                              NavigationRailDestination(icon: Icon(Icons.cloud), label: Text('Catalog')),
                              NavigationRailDestination(icon: Icon(Icons.tune_rounded), label: Text('Custom Plan')),
                              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
                            ],
                          ),
                          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderLight),
                          Expanded(child: pages[_currentIndex]),
                        ],
                      )
                    : pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isLandscape
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
              selectedItemColor: AppTheme.accentAqua,
              unselectedItemColor: AppTheme.textSecondary,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Catalog'),
                BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Custom Plan'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
      ),
    );
  }
}

class _BiometricPromptDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _BiometricPromptDialog({required this.onSuccess, required this.onCancel});

  @override
  State<_BiometricPromptDialog> createState() => _BiometricPromptDialogState();
}

class _BiometricPromptDialogState extends State<_BiometricPromptDialog> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    final bool success = await BiometricService.authenticate(
      reason: 'Scan your fingerprint or Face ID to verify identity',
    );

    if (mounted) {
      setState(() => _isAuthenticating = false);
      if (success) {
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication failed or cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.fingerprint, color: AppTheme.accentAqua, size: 28),
          SizedBox(width: 10),
          Text('Biometric Authentication'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Scan your fingerprint or face to verify identity for RenCloud security:'),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isAuthenticating ? null : _authenticate,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isAuthenticating ? AppTheme.accentAqua.withValues(alpha: 0.2) : AppTheme.primaryPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isAuthenticating ? AppTheme.accentAqua : AppTheme.primaryPurple,
                  width: 2,
                ),
              ),
              child: Icon(
                _isAuthenticating ? Icons.sensor_occupied : Icons.fingerprint,
                size: 56,
                color: _isAuthenticating ? AppTheme.accentAqua : AppTheme.primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isAuthenticating ? 'Scanning Biometric Sensor...' : 'Touch Fingerprint Sensor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isAuthenticating ? AppTheme.accentAqua : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _authenticate,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
          child: const Text('Authenticate Now'),
        ),
      ],
    );
  }
}
