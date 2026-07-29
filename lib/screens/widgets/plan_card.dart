import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rencloud_plan.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';
import 'deploy_modal.dart';

class PlanCard extends ConsumerWidget {
  final RenCloudPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = ref.watch(billingCycleProvider);
    final price = plan.getPriceForCycle(cycle);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular ? AppTheme.primaryPurple : AppTheme.borderLight,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: plan.isPopular
                ? AppTheme.primaryPurple.withOpacity(0.12)
                : Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Tier Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAquaLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentAqua.withOpacity(0.3)),
                      ),
                      child: Text(
                        plan.categoryName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentAqua,
                        ),
                      ),
                    ),
                    if (plan.tierType != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          plan.tierType!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Plan Name
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    Text(
                      plan.isOneTime ? ' one-time' : (cycle == BillingCycle.annual ? '/mo (billed yearly)' : '/mo'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppTheme.borderLight),

                // Specs List
                _buildSpecItem(Icons.memory, 'RAM', plan.ram),
                _buildSpecItem(Icons.storage, 'Storage', plan.nvmeStorage),
                _buildSpecItem(Icons.speed, 'CPU / Cores', plan.cpu),

                if (plan.databases != null)
                  _buildSpecItem(Icons.dns, 'Databases', '${plan.databases} Included'),
                if (plan.backups != null)
                  _buildSpecItem(Icons.backup, 'Auto Backups', '${plan.backups} Daily Snapshots'),

                if (plan.extraInfo != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    plan.extraInfo!,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ],

                const Spacer(),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => DeployModal(plan: plan),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isPopular ? AppTheme.primaryPurple : AppTheme.textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      plan.isOneTime ? 'Order Service' : 'Deploy Server',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Popular Badge in Aqua Accent
          if (plan.isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.accentAqua,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryPurple),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
