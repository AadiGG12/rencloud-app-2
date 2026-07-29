import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_plan.dart';
import '../providers/catalog_provider.dart';
import '../core/theme/app_theme.dart';
import 'widgets/category_tabs.dart';
import 'widgets/plan_card.dart';
import 'widgets/resource_calculator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(filteredPlansProvider);
    final cycle = ref.watch(billingCycleProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_queue, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'RenCloud',
              style: TextStyle(fontWeight: FontWeight.extrabold, letterSpacing: -0.5, color: AppTheme.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentAquaLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentAqua.withOpacity(0.4)),
              ),
              child: const Text(
                '55 PLANS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.extrabold, color: AppTheme.accentAqua),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryPurple),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('RenCloud Support: 24/7 Live Discord & Ticket Support')),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Section
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 64,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cloud & Game Server Hosting',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.extrabold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Explore all 55 high-performance server plans across Minecraft, VPS, Web, Hytale & Bot hosting',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Billing Cycle Toggle (Monthly vs Annual)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => ref.read(billingCycleProvider.notifier).state = BillingCycle.monthly,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: cycle == BillingCycle.monthly ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: cycle == BillingCycle.monthly
                                    ? [BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.1), blurRadius: 4)]
                                    : [],
                              ),
                              child: Text(
                                'Monthly Billing',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: cycle == BillingCycle.monthly ? FontWeight.bold : FontWeight.normal,
                                  color: cycle == BillingCycle.monthly ? AppTheme.primaryPurple : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref.read(billingCycleProvider.notifier).state = BillingCycle.annual,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: cycle == BillingCycle.annual ? AppTheme.primaryPurple : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: cycle == BillingCycle.annual
                                    ? [BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.2), blurRadius: 6)]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Annual Billing',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: cycle == BillingCycle.annual ? FontWeight.bold : FontWeight.normal,
                                      color: cycle == BillingCycle.annual ? Colors.white : AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentAqua,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'SAVE 15%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: 'Search by plan name, RAM, vCPU or specs (e.g. Ryzen, DDR5, Platinum, Iron)...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryPurple),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Pills
              const CategoryTabs(),
              const SizedBox(height: 24),

              // Custom Estimator Widget
              const ResourceCalculator(),
              const SizedBox(height: 28),

              // Plans Catalog Grid Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Service Plans (${plans.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Catalog Grid
              if (plans.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: AppTheme.primaryPurple),
                      const SizedBox(height: 12),
                      const Text(
                        'No plans found matching your search query.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(selectedCategoryProvider.notifier).state = 'all';
                        },
                        child: const Text('Reset All Filters', style: TextStyle(color: AppTheme.accentAqua)),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    if (constraints.maxWidth > 1100) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 700) {
                      crossAxisCount = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        return PlanCard(plan: plans[index]);
                      },
                    );
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
