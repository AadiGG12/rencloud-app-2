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
                fillColor: Colors.white,
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
                    color: cycle == BillingCycle.monthly ? Colors.white : AppTheme.textPrimary,
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
                    color: cycle == BillingCycle.annual ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Chips
            const CategoryTabs(),
            const SizedBox(height: 16),

            // Catalog List
            ListView.builder(
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
            ),
          ],
        ),
      ),

      // Tab 1: Custom Calculator
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const ResourceCalculator(),
      ),

      // Tab 2: Support & Account
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 64,
              errorBuilder: (_, __, ___) => const Icon(Icons.headset_mic, size: 64, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 16),
            const Text(
              'RenCloud Mobile Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '24/7 Engineer Support, Discord Community & Instant Node Monitoring',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // Prominent Update App Button
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
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }
}
