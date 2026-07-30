import 'package:flutter/material.dart';
import 'skeuomorphic_card.dart';

/// 3D Skeuomorphic Card Component Wrapper
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
    return SkeuomorphicCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      borderRadius: borderRadius,
      enableHaptics: enableHaptics,
      child: child,
    );
  }
}
