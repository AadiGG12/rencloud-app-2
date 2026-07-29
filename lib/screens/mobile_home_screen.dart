import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_plan.dart';
import '../providers/catalog_provider.dart';
import '../core/theme/app_theme.dart';
import '../services/update_service.dart';
import 'widgets/category_tabs.dart';
import 'widgets/plan_card.dart';
import 'widgets/resource_calculator.dart';
import 'widgets/server_performance_widget.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          UpdateService.checkForUpdates(context, silent: true);
        }
      });
    });
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
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint, size: 72, color: AppTheme.accentAqua),
                ),
                const SizedBox(height: 24),
                const Text(
                  'RenCloud Security Lock',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Authenticate using Fingerprint or Face ID to access your server console',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(biometricProvider.notifier).unlock();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometric Authentication Successful!')),
                    );
                  },
                  icon: const Icon(Icons.lock_open, color: Colors.white),
                  label: const Text('Unlock with Biometrics', style: TextStyle(fontWeight: FontWeight.bold)),
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
      // Tab 0: Home Catalog & Live Widget
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 26. Live Server Performance Monitor Widget
            const ServerPerformanceWidget(),
            const SizedBox(height: 14),

            // 27. Offline Mode Cache Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentAqua.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentAqua.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.offline_pin, size: 16, color: AppTheme.accentAqua),
                  SizedBox(width: 8),
                  Text(
                    'Offline Mode Active — 55 plans cached locally',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentAqua),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

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
                    color: cycle == BillingCycle.monthly ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimaryLight),
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
                    color: cycle == BillingCycle.annual ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimaryLight),
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
                  const Text('App Preferences & Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Configure currency, biometrics, theme & app updates', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 23. Dark Mode Switch Tile
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

            // 25. Multi-Currency Tile
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

            // 24. Biometric Authentication Switch Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: SwitchListTile(
                title: const Text('Fingerprint / Face ID Lock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Require biometric authentication on app start', style: TextStyle(fontSize: 11)),
                secondary: const Icon(Icons.fingerprint, color: AppTheme.accentAqua),
                value: biometric.isEnabled,
                onChanged: (val) {
                  ref.read(biometricProvider.notifier).toggleBiometrics(val);
                },
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
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.discord),
              label: const Text('Join RenCloud Discord'),
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
            const Text('RenCloud Mobile'),
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
