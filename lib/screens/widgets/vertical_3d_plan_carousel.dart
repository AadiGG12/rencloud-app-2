import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/rencloud_plan.dart';
import '../../core/theme/app_theme.dart';
import 'plan_card.dart';

/// Interactive 3D Vertical Coverflow/Carousel for Server Plans
/// Rotates plan cards on the X-axis with perspective depth scaling and snap scrolling.
class Vertical3DPlanCarousel extends StatefulWidget {
  final List<RenCloudPlan> plans;

  const Vertical3DPlanCarousel({super.key, required this.plans});

  @override
  State<Vertical3DPlanCarousel> createState() => _Vertical3DPlanCarouselState();
}

class _Vertical3DPlanCarouselState extends State<Vertical3DPlanCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.50,
      initialPage: 0,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plans.isEmpty) {
      return const Center(child: Text('No plans available'));
    }

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          onPageChanged: (index) {
            HapticFeedback.selectionClick();
          },
          itemCount: widget.plans.length,
          itemBuilder: (context, index) {
            final difference = index - _currentPage;
            final absDifference = difference.abs();

            // 3D Perspective Calculations
            final scale = (1.0 - (absDifference * 0.15)).clamp(0.70, 1.0);
            final opacity = (1.0 - (absDifference * 0.45)).clamp(0.2, 1.0);
            final rotateXAngle = (difference * 0.35).clamp(-0.6, 0.6); // X-Axis 3D Rotation

            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..scale(scale)
              ..rotateX(-rotateXAngle);

            return Opacity(
              opacity: opacity,
              child: Transform(
                transform: transform,
                alignment: Alignment.center,
                child: SizedBox(
                  height: 230,
                  child: PlanCard(plan: widget.plans[index]),
                ),
              ),
            );
          },
        ),

        // Vertical 3D Scroll Progress Dots Bar
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              min(widget.plans.length, 10),
              (index) {
                final isSelected = (_currentPage.round()) == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  width: isSelected ? 8 : 4,
                  height: isSelected ? 18 : 6,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentAqua : AppTheme.borderDark,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.accentAqua.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
