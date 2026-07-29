import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rencloud_plan.dart';
import '../../providers/catalog_provider.dart';
import '../../core/theme/app_theme.dart';
import 'deploy_modal.dart';

class PlanCard extends ConsumerStatefulWidget {
  final RenCloudPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  ConsumerState<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<PlanCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(billingCycleProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final priceInr = widget.plan.getPriceForCycle(cycle);
    final formattedPrice = CurrencyHelper.format(priceInr, currency);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final glowOpacity = widget.plan.isPopular ? _glowAnimation.value : (_isPressed ? 0.4 : 0.1);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: widget.plan.isPopular
                      ? [
                          AppTheme.primaryPurple.withOpacity(glowOpacity),
                          AppTheme.accentAqua.withOpacity(glowOpacity),
                        ]
                      : [
                          (isDark ? AppTheme.borderDark : AppTheme.borderLight).withOpacity(0.8),
                          (isDark ? AppTheme.borderDark : AppTheme.borderLight).withOpacity(0.3),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.plan.isPopular
                        ? AppTheme.accentAqua.withOpacity(glowOpacity * 0.5)
                        : AppTheme.primaryPurple.withOpacity(_isPressed ? 0.2 : 0.05),
                    blurRadius: widget.plan.isPopular ? 18 : 12,
                    spreadRadius: widget.plan.isPopular ? 1.5 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.8), // Border Width Gradient Effect
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withOpacity(0.92)
                      : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Pill & Tier Badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAqua.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.accentAqua.withOpacity(0.35)),
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
                                    color: AppTheme.primaryPurple.withOpacity(0.12),
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
                          const SizedBox(height: 10),

                          // Price Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: Text(
                                  formattedPrice,
                                  key: ValueKey(formattedPrice),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryPurple,
                                    letterSpacing: -0.5,
                                  ),
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
                          const SizedBox(height: 12),

                          // Specifications Grid
                          _buildSpecRow(Icons.memory_rounded, 'RAM', widget.plan.ram, isDark),
                          _buildSpecRow(Icons.sd_storage_rounded, 'Storage', widget.plan.nvmeStorage, isDark),
                          _buildSpecRow(Icons.speed_rounded, 'CPU', widget.plan.cpu, isDark),

                          if (widget.plan.databases != null)
                            _buildSpecRow(Icons.dns_rounded, 'Databases', '${widget.plan.databases} Included', isDark),
                          if (widget.plan.backups != null)
                            _buildSpecRow(Icons.backup_rounded, 'Backups', '${widget.plan.backups} Snapshots', isDark),

                          const Spacer(),

                          // Deploy / Order Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: widget.plan.isPopular
                                    ? const LinearGradient(
                                        colors: [AppTheme.primaryPurple, AppTheme.primaryDarkPurple],
                                      )
                                    : null,
                                color: !widget.plan.isPopular
                                    ? (isDark ? AppTheme.accentAqua : AppTheme.textPrimaryLight)
                                    : null,
                                boxShadow: widget.plan.isPopular
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryPurple.withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DeployModal(plan: widget.plan),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  widget.plan.isOneTime ? 'Order Plan' : 'Deploy Server',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Popular Badge with Sparkle Icon
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
                                color: AppTheme.accentAqua.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
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
