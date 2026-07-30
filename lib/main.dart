import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_version.dart';
import 'core/theme/app_theme.dart';
import 'providers/catalog_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppVersion.init();
  runApp(
    const ProviderScope(
      child: RenCloudApp(),
    ),
  );
}

class RenCloudApp extends ConsumerWidget {
  const RenCloudApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'RenCloud — Cloud & Game Server Hosting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
