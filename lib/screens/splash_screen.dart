import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_theme.dart';
import 'mobile_home_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Logo Scale & Fade
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    // 2. Rotating Glowing Ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 3. Pulse Wave
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Text Animations
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.4, 0.9, curve: Curves.easeIn)),
    );

    _logoController.forward();

    // Transition to main screen after 3 seconds
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              final isPhone = MediaQuery.of(context).size.shortestSide < 600;
              return isPhone ? const MobileHomeScreen() : const HomeScreen();
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Background Ambient Lights
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final pulse = _pulseController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -120 + (pulse * 20),
                    right: -120 + (pulse * 20),
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentAqua.withValues(alpha: 0.25),
                            AppTheme.accentAqua.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -120 + (pulse * 20),
                    left: -120 + (pulse * 20),
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryPurple.withValues(alpha: 0.25),
                            AppTheme.primaryPurple.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Center Logo & Ring
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Dual-Color Outer Ring
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            AppTheme.primaryPurple,
                            AppTheme.accentAqua,
                            Colors.white,
                            AppTheme.primaryPurple,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Inner White Container Mask
                  Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Animated Center Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 110,
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.cloud,
                          size: 56,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Animated Slide & Fade Text
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Ren',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryPurple,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'Cloud',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAquaLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accentAqua.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          '⚡ ULTRA HIGH PERFORMANCE CLOUD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentAqua,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Shimmer Loading Bar
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentAqua),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
