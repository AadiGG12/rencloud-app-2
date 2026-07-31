import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ShimmerEffect extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerEffect({super.key, required this.width, required this.height, this.borderRadius});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
              stops: [
                0.0,
                (_animation.value + 2) / 4,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerEffect(width: 80, height: 20),
          SizedBox(height: 12),
          ShimmerEffect(width: double.infinity, height: 24),
          SizedBox(height: 8),
          ShimmerEffect(width: 120, height: 24),
          SizedBox(height: 16),
          ShimmerEffect(width: double.infinity, height: 16),
          SizedBox(height: 8),
          ShimmerEffect(width: double.infinity, height: 16),
          SizedBox(height: 16),
          ShimmerEffect(width: double.infinity, height: 40),
        ],
      ),
    );
  }
}
