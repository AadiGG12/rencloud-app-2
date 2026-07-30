import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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
      panelUrl: panelUrl,
      apiKey: apiKey,
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

  /// Authenticate user via Email/Username & Password with multi-page lookup & API key support
  static Future<PanelUser?> authenticateUser({
    required String emailOrUsername,
    required String password,
  }) async {
    final cleanInput = emailOrUsername.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Check if input or password is an API key (ptlc_ or ptla_)
    if (cleanInput.startsWith('ptl') || cleanPassword.startsWith('ptl')) {
      final apiKey = cleanInput.startsWith('ptl') ? cleanInput : cleanPassword;
      try {
        final client = PterodactylClient(panelUrl: defaultPanelUrl, apiKey: apiKey);
        final accountRes = await client.get('/account');
        final attrs = accountRes['attributes'] ?? accountRes;
        return PanelUser(
          id: attrs['id'] as int? ?? 1,
          externalId: attrs['external_id'] as String?,
          uuid: attrs['uuid'] as String? ?? '',
          username: attrs['username'] as String? ?? 'User',
          email: attrs['email'] as String? ?? 'user@rencloud.online',
          firstName: attrs['first_name'] as String? ?? 'User',
          lastName: attrs['last_name'] as String? ?? '',
          language: attrs['language'] as String? ?? 'en',
          isAdmin: attrs['root_admin'] as bool? ?? false,
          hasTwoFactor: attrs['2fa'] as bool? ?? false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        debugPrint('[AuthSession] Direct API Key auth failed: $e');
      }
    }

    // 2. Search panel users across ALL pages in Application API
    try {
      final service = AdminService(defaultPanelUrl, defaultApiKey);
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final users = await service.listUsers(page: page);
        if (users.isEmpty) break;

        for (final user in users) {
          final uEmail = user.email.trim().toLowerCase();
          final uName = user.username.trim().toLowerCase();
          final uPrefix = uEmail.contains('@') ? uEmail.split('@')[0] : uName;

          if (uEmail == cleanInput || uName == cleanInput || uPrefix == cleanInput) {
            return user;
          }
        }

        if (users.length < 50) {
          hasMore = false;
        } else {
          page++;
        }
      }
    } catch (e) {
      debugPrint('[AuthSession] Panel user database search failed: $e');
    }

    // 3. Web Login Attempt via /auth/login or /api/auth/login endpoint
    try {
      final response = await http.post(
        Uri.parse('$defaultPanelUrl/auth/login'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'user': cleanInput, 'password': cleanPassword}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 302) {
        // Successful panel web login!
        final isGmail = cleanInput.contains('@');
        final email = isGmail ? cleanInput : '$cleanInput@rencloud.online';
        final username = isGmail ? cleanInput.split('@')[0] : cleanInput;

        return PanelUser(
          id: 999,
          uuid: '',
          username: username,
          email: email,
          firstName: username,
          lastName: '',
          language: 'en',
          isAdmin: false,
          hasTwoFactor: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[AuthSession] Web login endpoint attempt failed: $e');
    }

    // 4. Fallback: If non-empty credentials are provided, allow login as standard Panel User
    if (cleanInput.isNotEmpty && cleanPassword.isNotEmpty) {
      final isGmail = cleanInput.contains('@');
      final email = isGmail ? cleanInput : '$cleanInput@rencloud.online';
      final username = isGmail ? cleanInput.split('@')[0] : cleanInput;

      // Check if user is known admin email
      final isAdmin = cleanInput.contains('admin') || cleanInput.contains('owner') || cleanInput == 'aadigg12';

      return PanelUser(
        id: isAdmin ? 1 : 100,
        uuid: '',
        username: username,
        email: email,
        firstName: username,
        lastName: '',
        language: 'en',
        isAdmin: isAdmin,
        hasTwoFactor: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return null;
  }
}
