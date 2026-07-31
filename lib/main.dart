import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api_client.dart';
import 'core/constants/app_version.dart';
import 'core/theme/app_theme.dart';
import 'providers/catalog_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/widgets/theme_reveal_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppVersion.init();
  await ApiClient.init(); // Initialize secure backend API client
  
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ProviderScope(
      child: RenCloudApp(onboardingComplete: onboardingComplete),
    ),
  );
}

class RenCloudApp extends ConsumerWidget {
  final bool onboardingComplete;
  
  const RenCloudApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'RenCloud — Cloud & Game Server Hosting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return ThemeRevealWrapper(
          themeMode: themeMode,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: onboardingComplete ? const SplashScreen() : const OnboardingScreen(),
    );
  }
}
