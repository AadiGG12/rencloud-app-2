import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import 'mobile_home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.cloud,
      'title': 'Enterprise-Grade Cloud Servers',
      'subtitle': 'Deploy Minecraft, game servers, and more in seconds',
      'color': const Color(0xFF0284C7),
    },
    {
      'icon': Icons.security,
      'title': 'Your Servers, Fully Secure',
      'subtitle': 'Biometric login, encrypted sessions, real-time monitoring',
      'color': const Color(0xFF7C3AED),
    },
    {
      'icon': Icons.rocket_launch,
      'title': 'Deploy in Seconds',
      'subtitle': 'Choose your plan, pick your region, go live instantly',
      'color': const Color(0xFF00D4FF),
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MobileHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [page['color'].withValues(alpha: 0.2), const Color(0xFF090D16)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, val, child) {
                        return Transform.scale(
                          scale: val,
                          child: Icon(page['icon'], size: 120, color: page['color']),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        page['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        page['subtitle'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: const Text('Skip', style: TextStyle(color: Colors.white70)),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppTheme.accentCyan : Colors.white30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
