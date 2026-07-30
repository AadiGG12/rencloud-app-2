import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/rencloud_plan.dart';
import 'deploy_modal.dart';
import 'glass_card.dart';

enum ServiceType { minecraft, vps, other }

class ResourceCalculator extends ConsumerStatefulWidget {
  const ResourceCalculator({super.key});

  @override
  ConsumerState<ResourceCalculator> createState() => _ResourceCalculatorState();
}

class _ResourceCalculatorState extends ConsumerState<ResourceCalculator> {
  ServiceType _selectedService = ServiceType.minecraft;
  bool _includeDedicatedIp = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estimatorProvider);
    final notifier = ref.read(estimatorProvider.notifier);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Additional price additions based on service type
    double serviceMultiplier = 1.0;
    String serviceName = 'Minecraft Server';
    if (_selectedService == ServiceType.vps) {
      serviceMultiplier = 1.25;
      serviceName = 'VPS Hosting';
    } else if (_selectedService == ServiceType.other) {
      serviceMultiplier = 0.85;
      serviceName = 'Other Service (Discord Bot / Web)';
    }

    double finalPriceInr = (state.estimatedPriceInr * serviceMultiplier);
    if (_includeDedicatedIp) {
      finalPriceInr += 150.0;
    }

    final formattedPrice = CurrencyHelper.format(finalPriceInr.toInt(), currency);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metallic Header Card
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.tune_rounded, color: AppTheme.accentAqua, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Build Your Custom Plan',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.metallicSteelGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$formattedPrice/mo',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select your service type and customize RAM, CPU, and NVMe resources:',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 14),

                // Service Type Selectors
                Row(
                  children: [
                    _buildServiceChip(ServiceType.minecraft, '🎮 Minecraft', isDark),
                    const SizedBox(width: 8),
                    _buildServiceChip(ServiceType.vps, '🖥️ VPS Hosting', isDark),
                    const SizedBox(width: 8),
                    _buildServiceChip(ServiceType.other, '⚡ Other', isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Metallic Resource Sliders Card
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RAM Slider
                _buildSlider(
                  label: 'RAM Memory',
                  valueText: '${state.ramGb} GB DDR5 RAM',
                  icon: Icons.memory_rounded,
                  value: state.ramGb.toDouble(),
                  min: 1,
                  max: 128,
                  divisions: 127,
                  onChanged: (val) => notifier.updateRam(val.toInt()),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // CPU Slider
                _buildSlider(
                  label: 'CPU Cores',
                  valueText: '${state.vcpuCores} Dedicated vCores',
                  icon: Icons.speed_rounded,
                  value: state.vcpuCores.toDouble(),
                  min: 1,
                  max: 16,
                  divisions: 15,
                  onChanged: (val) => notifier.updateVcpu(val.toInt()),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Storage Slider
                _buildSlider(
                  label: 'NVMe SSD Storage',
                  valueText: '${state.storageGb} GB High Speed NVMe',
                  icon: Icons.sd_storage_rounded,
                  value: state.storageGb.toDouble(),
                  min: 10,
                  max: 500,
                  divisions: 49,
                  onChanged: (val) => notifier.updateStorage(val.toInt()),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Dedicated IP Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dedicated IPv4 Address (+ ₹150/mo)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Dedicated IP address with custom port 25565', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  value: _includeDedicatedIp,
                  activeColor: AppTheme.accentAqua,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _includeDedicatedIp = val);
                  },
                ),
                const SizedBox(height: 12),

                // Deploy Custom Plan Button
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.metallicSteelGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final customPlan = RenCloudPlan(
                        id: 'custom-config',
                        name: 'Custom $serviceName (${state.vcpuCores} vCPU, ${state.ramGb}GB RAM)',
                        categoryId: 'custom',
                        categoryName: 'Custom Plan',
                        ram: '${state.ramGb} GB DDR5 RAM',
                        cpu: '${state.vcpuCores} Dedicated vCPU Cores',
                        nvmeStorage: '${state.storageGb} GB NVMe SSD',
                        monthlyPriceInr: finalPriceInr.toInt(),
                        databases: 5,
                        backups: 7,
                      );

                      showDialog(
                        context: context,
                        builder: (_) => DeployModal(plan: customPlan),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                    label: Text(
                      'Deploy Custom Plan ($formattedPrice)',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(ServiceType type, String label, bool isDark) {
    final isSelected = _selectedService == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedService = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.metallicSteelGradient : null,
            color: !isSelected
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentAqua
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? AppTheme.textSecondary : AppTheme.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required String valueText,
    required IconData icon,
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
            Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.accentAqua),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.white : AppTheme.textPrimary)),
              ],
            ),
            Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.accentAqua)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.accentAqua,
            inactiveTrackColor: AppTheme.accentAqua.withValues(alpha: 0.15),
            thumbColor: Colors.white,
            overlayColor: AppTheme.accentAqua.withValues(alpha: 0.2),
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
