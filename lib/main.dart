import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RenCloudApp(),
    ),
  );
}

class RenCloudApp extends StatelessWidget {
  const RenCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RenCloud — Cloud & Game Server Hosting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
