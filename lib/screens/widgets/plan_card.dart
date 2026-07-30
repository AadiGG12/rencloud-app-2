import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rencloud_plan.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';
import 'deploy_modal.dart';
import 'glass_card.dart';

/// Interactive 3D Flip Plan Card Component
/// Tapping the card smoothly rotates it on the Y-axis with haptic feedback to reveal full plan details.
class PlanCard extends ConsumerStatefulWidget {
  final RenCloudPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  ConsumerState<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<PlanCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _flipAnimation.addListener(() {
      if (_flipAnimation.value >= 0.5 && !_showBack) {
        setState(() => _showBack = true);
      } else if (_flipAnimation.value < 0.5 && _showBack) {
        setState(() => _showBack = false);
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    HapticFeedback.mediumImpact();
    if (_flipController.isAnimating) return;
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(billingCycleProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final priceInr = widget.plan.getPriceForCycle(cycle);
    final formattedPrice = CurrencyHelper.format(priceInr, currency);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective calculation
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: _showBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(pi), // Un-mirror back content
                  alignment: Alignment.center,
                  child: _buildBackContent(context, formattedPrice, cycle, isDark),
                )
              : _buildFrontContent(context, formattedPrice, cycle, isDark),
        );
      },
    );
  }

  /// Front Side of the 3D Flip Card
  Widget _buildFrontContent(BuildContext context, String formattedPrice, BillingCycle cycle, bool isDark) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(22),
      onTap: _toggleFlip,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pill & Tier Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAqua.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        widget.plan.categoryName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentAqua,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (widget.plan.tierType != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          widget.plan.tierType!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Plan Title
                Text(
                  widget.plan.name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryPurple,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      widget.plan.isOneTime
                          ? ' one-time'
                          : (cycle == BillingCycle.annual ? '/mo (yearly)' : '/mo'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                const SizedBox(height: 10),

                // Specifications Highlights
                _buildSpecRow(Icons.memory_rounded, 'RAM', widget.plan.ram, isDark),
                _buildSpecRow(Icons.sd_storage_rounded, 'NVMe Storage', widget.plan.nvmeStorage, isDark),
                _buildSpecRow(Icons.speed_rounded, 'CPU Cores', widget.plan.cpu, isDark),

                const Spacer(),

                // Tap to Flip Prompt Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flip_camera_android_rounded, size: 16, color: AppTheme.accentAqua),
                      SizedBox(width: 8),
                      Text(
                        'Tap to Flip & View Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentAqua,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Popular Badge
          if (widget.plan.isPopular)
            Positioned(
              top: 0,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentAqua, Color(0xFF0284C7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentAqua.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 11, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Back Side of the 3D Flip Card
  Widget _buildBackContent(BuildContext context, String formattedPrice, BillingCycle cycle, bool isDark) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(22),
      borderColor: AppTheme.accentAqua.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.plan.name} Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.accentAqua),
                  onPressed: _toggleFlip,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Feature Highlights List
            _buildFeatureCheck('Anti-DDoS Shield Protection Included'),
            _buildFeatureCheck('Instant Pterodactyl Panel Provisioning'),
            _buildFeatureCheck('Ultra-High IOPS NVMe SSD Array'),
            _buildFeatureCheck('Automated Daily Snapshots & Backups'),
            if (widget.plan.databases != null)
              _buildFeatureCheck('${widget.plan.databases} Dedicated MySQL Databases'),

            const Spacer(),

            // Order / Deploy Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showDialog(
                    context: context,
                    builder: (_) => DeployModal(plan: widget.plan),
                  );
                },
                icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                label: Text(
                  widget.plan.isOneTime ? 'Order Plan ($formattedPrice)' : 'Deploy Now ($formattedPrice)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCheck(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
