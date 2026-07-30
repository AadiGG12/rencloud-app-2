import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Reusable Glassmorphism Card Widget
/// Provides frosted glass blur effect with translucent borders and haptic feedback.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blur;
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
    this.blur = 10.0,
    this.opacity = 0.12,
    this.borderColor,
    this.borderRadius,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(18);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryPurple.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: br,
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppTheme.primaryPurple.withValues(alpha: 0.12)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppTheme.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (enableHaptics) {
                        HapticFeedback.selectionClick();
                      }
                      onTap!();
                    },
                    borderRadius: br,
                    child: cardChild,
                  ),
                )
              : cardChild,
        ),
      ),
    );
  }
}
