import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_plan.dart';
import '../providers/catalog_provider.dart';
import '../core/theme/app_theme.dart';
import '../services/update_service.dart';
import 'widgets/category_tabs.dart';
import 'widgets/plan_card.dart';
import 'widgets/resource_calculator.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int _currentIndex = 0;

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

    // Biometric Security Lock Overlay Screen
    if (biometric.isEnabled && !biometric.isUnlocked) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint, size: 72, color: AppTheme.accentAqua),
                ),
                const SizedBox(height: 24),
                const Text(
                  'RenCloud Biometric Lock',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Touch fingerprint sensor or scan Face ID to unlock RenCloud',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (bContext) => _BiometricPromptDialog(
                        onSuccess: () {
                          Navigator.pop(bContext);
                          ref.read(biometricProvider.notifier).unlock();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fingerprint / Face ID Unlocked Successfully!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        onCancel: () => Navigator.pop(bContext),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: const Text('Scan Fingerprint / Face ID to Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        height: 340,
                        child: PlanCard(plan: plans[index]),
                      ),
                    );
                  },
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
                  const SizedBox(height: 4),
                  const Text('Configure currency, biometrics, dark mode & app updates', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
                  ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
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
            const SizedBox(height: 24),

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
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.cloud, color: AppTheme.primaryPurple),
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
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          // AppBar Update Button Action Icon
          IconButton(
            icon: const Icon(Icons.system_update, color: AppTheme.accentAqua),
            tooltip: 'Check for App Updates',
            onPressed: () => UpdateService.checkForUpdates(context, silent: false),
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0.5,
      ),
      body: isLandscape
          ? Row(
              children: [
                // NavigationRail for Landscape Mode
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryPurple),
                  unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.cloud), label: Text('Catalog')),
                    NavigationRailDestination(icon: Icon(Icons.calculate), label: Text('Calculator')),
                    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderLight),
                Expanded(child: pages[_currentIndex]),
              ],
            )
          : pages[_currentIndex],
      bottomNavigationBar: isLandscape
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              selectedItemColor: AppTheme.primaryPurple,
              unselectedItemColor: AppTheme.textSecondary,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Catalog'),
                BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
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

  void _simulateScan() {
    setState(() => _isAuthenticating = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        widget.onSuccess();
      }
    });
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
            onTap: _isAuthenticating ? null : _simulateScan,
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
          onPressed: _simulateScan,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
          child: const Text('Authenticate Now'),
        ),
      ],
    );
  }
}
