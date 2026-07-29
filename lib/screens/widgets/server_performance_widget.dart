import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';

class ServerPerformanceWidget extends ConsumerWidget {
  const ServerPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(serverMetricsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentAqua.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentAqua.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Server Name & Live Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981), // Emerald Green Online
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFF10B981), blurRadius: 8, spreadRadius: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    metrics.serverName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.speed, size: 12, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      '${metrics.tps} TPS',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Player Count & Ping Latency Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.people_outline,
                  label: 'Players Online',
                  value: '${metrics.onlinePlayers}/${metrics.maxPlayers}',
                  color: AppTheme.primaryPurple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.wifi,
                  label: 'Latency',
                  value: '${metrics.pingMs} ms',
                  color: AppTheme.accentAqua,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // CPU & RAM Usage Bars
          _buildUsageBar(
            label: 'CPU Usage',
            valueText: '${metrics.cpuUsagePct}%',
            percentage: metrics.cpuUsagePct / 100.0,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 8),
          _buildUsageBar(
            label: 'RAM Usage',
            valueText: '${metrics.ramUsageGb} / ${metrics.maxRamGb} GB',
            percentage: metrics.ramUsageGb / metrics.maxRamGb,
            color: AppTheme.accentAqua,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimaryLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar({
    required String label,
    required String valueText,
    required double percentage,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            Text(valueText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
