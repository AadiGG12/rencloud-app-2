import 'dart:math';
import 'package:flutter/material.dart';

/// Butter-Smooth 120 FPS Corner-to-Center Circular Radial Theme Transition Wrapper
/// Sweeps from top-right corner to center when themeMode changes with GPU RepaintBoundary.
class ThemeRevealWrapper extends StatefulWidget {
  final Widget child;
  final ThemeMode themeMode;
  final Offset? originOffset;

  const ThemeRevealWrapper({
    super.key,
    required this.child,
    required this.themeMode,
    this.originOffset,
  });

  @override
  State<ThemeRevealWrapper> createState() => _ThemeRevealWrapperState();
}

class _ThemeRevealWrapperState extends State<ThemeRevealWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Widget? _oldChild;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
  }

  @override
  void didUpdateWidget(ThemeRevealWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _oldChild = oldWidget.child;
      _controller.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() => _oldChild = null);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_oldChild == null) {
      return widget.child;
    }

    return RepaintBoundary(
      child: Stack(
        children: [
          _oldChild!,
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final size = MediaQuery.of(context).size;
              final origin = widget.originOffset ?? Offset(size.width - 50, 50); // Top Right Theme Button Corner
              final maxRadius = sqrt(pow(max(origin.dx, size.width - origin.dx), 2) +
                  pow(max(origin.dy, size.height - origin.dy), 2));

              return ClipPath(
                clipper: _CircleClipper(
                  center: origin,
                  radius: _animation.value * maxRadius,
                ),
                child: widget.child,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
