import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/pterodactyl/panel_user_model.dart';
import '../providers/admin_provider.dart';
import '../providers/pterodactyl_provider.dart';
import 'backend/auth_service.dart';

/// Secure Auth Session Service
///
/// Routes all authentication through the secure backend API.
/// NO Pterodactyl API keys are stored on the device.
/// Only JWT tokens (from the backend) are persisted.
class AuthSessionService {
  static const String keyIsLoggedIn = 'auth_is_logged_in';
  static const String keyEmail = 'auth_user_email';
  static const String keyUsername = 'auth_user_username';
  static const String keyUserId = 'auth_user_id';
  static const String keyIsAdmin = 'auth_is_admin';
  static const String keyUserData = 'auth_user_data';

  /// Save session to persistent storage
  static Future<void> saveSession({
    required String email,
    required String username,
    required int userId,
    required bool isAdmin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyUsername, username);
    await prefs.setInt(keyUserId, userId);
    await prefs.setBool(keyIsAdmin, isAdmin);
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyEmail);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUserId);
    await prefs.remove(keyIsAdmin);
    await prefs.remove(keyUserData);
    await ApiClient.clearAuth();
  }

  /// Restore saved login session on app startup
  static Future<bool> restoreSession(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return false;

    final email = prefs.getString(keyEmail) ?? '';
    final username = prefs.getString(keyUsername) ?? '';
    final isAdmin = prefs.getBool(keyIsAdmin) ?? false;

    // Check if we have a valid JWT token
    final token = await ApiClient.getAuthToken();
    if (token == null || token.isEmpty) return false;

    // Restore Pterodactyl auth provider state (without API keys)
    ref.read(pterodactylAuthProvider.notifier).setAdminInfo(
      isAdmin: isAdmin,
      email: email,
      username: username,
    );

    // Initialize backend services (no API keys needed)
    ref.read(pterodactylServerListProvider.notifier).fetchServers();

    if (isAdmin) {
      ref.read(adminAllServersProvider.notifier).fetchAllServers();
    }

    return true;
  }

  /// Authenticate user via backend API
  static Future<PanelUser?> authenticateUser({
    required String emailOrUsername,
    required String password,
  }) async {
    final cleanInput = emailOrUsername.trim();
    final cleanPassword = password.trim();

    if (cleanInput.isEmpty || cleanPassword.isEmpty) return null;

    try {
      final result = await BackendAuthService.login(
        email: cleanInput,
        password: cleanPassword,
      );

      final userData = result['user'] as Map<String, dynamic>? ?? {};
      final int userId = (userData['id'] as num?)?.toInt() ?? 0;
      final String email = userData['email'] as String? ?? cleanInput;
      final String username = userData['username'] as String? ??
          (cleanInput.contains('@') ? cleanInput.split('@')[0] : cleanInput);
      final bool isAdmin = userData['is_admin'] == true;

      return PanelUser(
        id: userId,
        uuid: '',
        username: username,
        email: email,
        firstName: userData['first_name'] as String? ?? username,
        lastName: userData['last_name'] as String? ?? '',
        language: 'en',
        isAdmin: isAdmin,
        hasTwoFactor: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[AuthSession] Backend auth failed: $e');

      debugPrint('[AuthSession] Backend auth failed. Ensure the backend server is running.');
      return null;
    }
  }
}

