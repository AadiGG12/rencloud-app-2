import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Production 3D Skeuomorphic Container Widget
/// Implements physical 3D depth, dual light/dark bevel shadows, metallic textures, and tactile press-down states.
class SkeuomorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool enableHaptics;
  final bool isPressedState;
  final Color? baseColor;

  const SkeuomorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.enableHaptics = true,
    this.isPressedState = false,
    this.baseColor,
  });

  @override
  State<SkeuomorphicCard> createState() => _SkeuomorphicCardState();
}

class _SkeuomorphicCardState extends State<SkeuomorphicCard> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = widget.borderRadius ?? BorderRadius.circular(18);
    final pressed = _isDown || widget.isPressedState;

    final base = widget.baseColor ??
        (isDark ? const Color(0xFF161E2E) : const Color(0xFFE6ECF5));

    final lightShadowColor = isDark
        ? const Color(0xFF24324D)
        : Colors.white;

    final darkShadowColor = isDark
        ? const Color(0xFF0A0F1A)
        : const Color(0xFFB8C4D9);

    final borderBevel = isDark
        ? const Color(0xFF334466)
        : const Color(0xFFFFFFFF);

    final cardChild = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: widget.padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: base,
        borderRadius: br,
        border: Border.all(
          color: borderBevel.withValues(alpha: isDark ? 0.25 : 0.6),
          width: 1.4,
        ),
        gradient: LinearGradient(
          colors: pressed
              ? (isDark
                  ? [const Color(0xFF0E1420), const Color(0xFF182234)]
                  : [const Color(0xFFD6DFED), const Color(0xFFF0F5FD)])
              : (isDark
                  ? [const Color(0xFF1D283D), const Color(0xFF111826)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFDDE5F2)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: pressed
            ? [
                BoxShadow(
                  color: darkShadowColor.withValues(alpha: 0.5),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: lightShadowColor.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ]
            : [
                BoxShadow(
                  color: darkShadowColor.withValues(alpha: 0.8),
                  offset: const Offset(5, 5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: lightShadowColor.withValues(alpha: 0.8),
                  offset: const Offset(-5, -5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return Container(
        margin: widget.margin,
        child: cardChild,
      );
    }

    return Container(
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isDown = true),
        onTapUp: (_) => setState(() => _isDown = false),
        onTapCancel: () => setState(() => _isDown = false),
        onTap: () {
          if (widget.enableHaptics) {
            HapticFeedback.mediumImpact();
          }
          widget.onTap!();
        },
        child: cardChild,
      ),
    );
  }
}
