import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rencloud_plan.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';
import 'deploy_modal.dart';
import 'glass_card.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final String formatStr;
  
  const AnimatedCounter({super.key, required this.value, required this.formatStr});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(seconds: 1),
      builder: (context, val, child) {
        return Text(
          formatStr.replaceFirst(value.toStringAsFixed(0), val.toStringAsFixed(0)),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryPurple,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }
}

class PlanCard extends ConsumerWidget {
  final RenCloudPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = ref.watch(billingCycleProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final priceInr = plan.getPriceForCycle(cycle);
    final formattedPrice = CurrencyHelper.format(priceInr, currency);

    Color headerColor = AppTheme.primaryPurple;
    final catName = plan.categoryName.toLowerCase();
    if (catName.contains('minecraft')) headerColor = Colors.green;
    else if (catName.contains('vps')) headerColor = Colors.blue;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      onTap: () {
        showDialog(context: context, builder: (_) => DeployModal(plan: plan));
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.categoryName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: headerColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedCounter(value: priceInr.toDouble(), formatStr: formattedPrice),
                        Text(
                          plan.isOneTime ? ' one-time' : (cycle == BillingCycle.annual ? '/mo (yearly)' : '/mo'),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(Icons.memory, plan.ram, isDark),
                        _buildBadge(Icons.speed, plan.cpu, isDark),
                        _buildBadge(Icons.storage, plan.nvmeStorage, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (plan.isPopular)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.metallicGoldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('POPULAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.accentCyan),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }
}
