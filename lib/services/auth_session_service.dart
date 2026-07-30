import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pterodactyl/panel_user_model.dart';
import '../providers/admin_provider.dart';
import '../providers/pterodactyl_provider.dart';
import 'pterodactyl/admin_service.dart';
import 'pterodactyl/pterodactyl_client.dart';

class AuthSessionService {
  static const String keyIsLoggedIn = 'auth_is_logged_in';
  static const String keyEmail = 'auth_user_email';
  static const String keyUsername = 'auth_user_username';
  static const String keyUserId = 'auth_user_id';
  static const String keyIsAdmin = 'auth_is_admin';
  static const String keyPanelUrl = 'auth_panel_url';
  static const String keyApiKey = 'auth_api_key';

  static const String defaultPanelUrl = 'https://panel.rencloud.online';
  static const String defaultApiKey = 'ptla_oCxBHX7wIGwqMnXcL4bKfqviONhFKZrAt52fu9RsKGX';

  /// Save session to persistent storage
  static Future<void> saveSession({
    required String email,
    required String username,
    required int userId,
    required bool isAdmin,
    String? panelUrl,
    String? apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyUsername, username);
    await prefs.setInt(keyUserId, userId);
    await prefs.setBool(keyIsAdmin, isAdmin);
    await prefs.setString(keyPanelUrl, panelUrl ?? defaultPanelUrl);
    await prefs.setString(keyApiKey, apiKey ?? defaultApiKey);
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyEmail);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUserId);
    await prefs.remove(keyIsAdmin);
    await prefs.remove(keyPanelUrl);
    await prefs.remove(keyApiKey);
  }

  /// Restore saved login session on app startup
  static Future<bool> restoreSession(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return false;

    final email = prefs.getString(keyEmail) ?? '';
    final username = prefs.getString(keyUsername) ?? '';
    final isAdmin = prefs.getBool(keyIsAdmin) ?? false;
    final panelUrl = prefs.getString(keyPanelUrl) ?? defaultPanelUrl;
    final apiKey = prefs.getString(keyApiKey) ?? defaultApiKey;

    // Restore Pterodactyl auth provider state
    ref.read(pterodactylAuthProvider.notifier).setAdminInfo(
      isAdmin: isAdmin,
      email: email,
      username: username,
    );

    // Initialize Admin or Client services depending on role
    final service = AdminService(panelUrl, apiKey);
    ref.read(adminAuthProvider.notifier).login(panelUrl, apiKey);
    ref.read(adminUserListProvider.notifier).setService(service);
    ref.read(adminAllServersProvider.notifier).setService(service);

    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    ref.read(pterodactylServerListProvider.notifier).setClient(client);
    ref.read(pterodactylServerListProvider.notifier).fetchServers();

    return true;
  }

  /// Authenticate user via Email/Username & Password with role differentiation
  static Future<PanelUser?> authenticateUser({
    required String emailOrUsername,
    required String password,
  }) async {
    final service = AdminService(defaultPanelUrl, defaultApiKey);
    final users = await service.listUsers();

    final cleanInput = emailOrUsername.trim().toLowerCase();

    // Find user matching email or username
    for (final user in users) {
      if (user.email.toLowerCase() == cleanInput ||
          user.username.toLowerCase() == cleanInput ||
          user.email.toLowerCase().split('@')[0] == cleanInput) {
        return user;
      }
    }
    return null;
  }
}
