import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Ultra-Fast, 120 FPS Glassmorphism Card Component
/// Hardware-accelerated translucent glass card optimized for smooth 120Hz scrolling.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double opacity;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool enableHaptics;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.opacity = 0.12,
    this.borderColor,
    this.borderRadius,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardDecoration = BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.92),
      borderRadius: br,
      border: Border.all(
        color: borderColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.12)
                : AppTheme.primaryPurple.withValues(alpha: 0.12)),
        width: 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : AppTheme.primaryPurple.withValues(alpha: 0.06),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 3),
        ),
      ],
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(12),
        decoration: cardDecoration,
        child: child,
      );
    }

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (enableHaptics) {
              HapticFeedback.selectionClick();
            }
            onTap!();
          },
          borderRadius: br,
          child: Container(
            padding: padding ?? const EdgeInsets.all(12),
            decoration: cardDecoration,
            child: child,
          ),
        ),
      ),
    );
  }
}
