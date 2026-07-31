import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_session_service.dart';
import '../services/app_settings_service.dart';
import 'auth/auth_gateway_screen.dart';
import '../core/constants/app_version.dart';

class StarfieldPainter extends CustomPainter {
  final double animationValue;
  final List<Offset> stars;
  final List<double> sizes;

  StarfieldPainter(this.animationValue, this.stars, this.sizes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.accentCyan.withValues(alpha: 0.4);
    for (int i = 0; i < stars.length; i++) {
      final y = (stars[i].dy * size.height + animationValue * 100) % size.height;
      final x = stars[i].dx * size.width;
      canvas.drawCircle(Offset(x, y), sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _bgController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseAnimation;
  late Animation<double> _taglineOpacity;
  
  List<Offset> _stars = [];
  List<double> _starSizes = [];

  String _appName = "RenCloud";
  String _displayedName = "";

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _stars.add(Offset(random.nextDouble(), random.nextDouble()));
      _starSizes.add(random.nextDouble() * 2 + 1);
    }

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0.7, 1.0)));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _logoController.forward();
    _animateText();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      await AppSettingsService.restoreSettings(ref);
      await AuthSessionService.restoreSession(ref);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthGatewayScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  void _animateText() async {
    for (int i = 0; i < _appName.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _displayedName = _appName.substring(0, i + 1));
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) => CustomPaint(
              painter: StarfieldPainter(_bgController.value, _stars, _starSizes),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120 * _pulseAnimation.value,
                            height: 120 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentCyan.withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF090D16),
                            ),
                            child: Image.asset('assets/images/logo.png', width: 60, height: 60),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                _displayedName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _taglineOpacity,
                child: const Text(
                  'Enterprise Cloud. Mobile Native.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.accentCyan,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: Text(
                'v${AppVersion.version}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
