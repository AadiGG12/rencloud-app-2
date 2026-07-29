import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';

class ResourceCalculator extends ConsumerWidget {
  const ResourceCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(estimatorProvider);
    final notifier = ref.read(estimatorProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '⚡ Custom Resource Cost Estimator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Configure vCPUs, RAM, and NVMe Storage to estimate your custom cluster cost',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentAquaLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentAqua.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Estimated Price', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    Text(
                      '₹${state.estimatedPriceInr}/mo',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.extrabold,
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
          ),

          // RAM Slider
          _buildSlider(
            label: 'RAM Memory',
            valueText: '${state.ramGb} GB DDR4/DDR5',
            value: state.ramGb.toDouble(),
            min: 2,
            max: 128,
            divisions: 63,
            onChanged: (val) => notifier.updateRam(val.toInt()),
          ),

          // NVMe Storage Slider
          _buildSlider(
            label: 'NVMe Storage',
            valueText: '${state.storageGb} GB NVMe',
            value: state.storageGb.toDouble(),
            min: 10,
            max: 500,
            divisions: 49,
            onChanged: (val) => notifier.updateStorage(val.toInt()),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primaryPurple,
          inactiveColor: AppTheme.primaryPurple.withOpacity(0.15),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
