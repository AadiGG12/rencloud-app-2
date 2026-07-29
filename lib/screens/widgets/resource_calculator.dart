import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/rencloud_plan.dart';
import 'deploy_modal.dart';

class ResourceCalculator extends ConsumerWidget {
  const ResourceCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(estimatorProvider);
    final notifier = ref.read(estimatorProvider.notifier);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final formattedPrice = CurrencyHelper.format(state.estimatedPriceInr, currency);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.primaryPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header Layout (Prevents Overflow Errors)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ Custom Resource Cost Estimator',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Configure vCPUs, RAM, and NVMe Storage to build your custom server cluster',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentAquaLight.withOpacity(isDark ? 0.15 : 1.0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentAqua.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Estimated Cost', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                    Text(
                      '$formattedPrice/mo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentAqua,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // vCPU Slider
          _buildSlider(
            label: 'vCPU Cores',
            valueText: '${state.vcpuCores} vCores',
            value: state.vcpuCores.toDouble(),
            min: 1,
            max: 32,
            divisions: 31,
            onChanged: (val) => notifier.updateVcpu(val.toInt()),
            isDark: isDark,
          ),

          // RAM Slider
          _buildSlider(
            label: 'RAM Memory',
            valueText: '${state.ramGb} GB DDR5 RAM',
            value: state.ramGb.toDouble(),
            min: 2,
            max: 128,
            divisions: 63,
            onChanged: (val) => notifier.updateRam(val.toInt()),
            isDark: isDark,
          ),

          // NVMe Storage Slider
          _buildSlider(
            label: 'NVMe Storage',
            valueText: '${state.storageGb} GB NVMe SSD',
            value: state.storageGb.toDouble(),
            min: 10,
            max: 500,
            divisions: 49,
            onChanged: (val) => notifier.updateStorage(val.toInt()),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Deploy Custom Configuration Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                final customPlan = RenCloudPlan(
                  id: 'custom-config',
                  name: 'Custom Cluster Config (${state.vcpuCores} vCPU, ${state.ramGb}GB RAM)',
                  categoryId: 'custom',
                  categoryName: 'Custom Config',
                  ram: '${state.ramGb} GB DDR5 RAM',
                  cpu: '${state.vcpuCores} Dedicated vCPU Cores',
                  nvmeStorage: '${state.storageGb} GB High Speed NVMe',
                  monthlyPriceInr: state.estimatedPriceInr,
                  databases: 5,
                  backups: 7,
                );

                showDialog(
                  context: context,
                  builder: (_) => DeployModal(plan: customPlan),
                );
              },
              icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
              label: const Text('Deploy Custom Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)),
            Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryPurple)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.primaryPurple,
            inactiveTrackColor: AppTheme.primaryPurple.withOpacity(0.15),
            thumbColor: AppTheme.accentAqua,
            overlayColor: AppTheme.accentAqua.withOpacity(0.2),
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
