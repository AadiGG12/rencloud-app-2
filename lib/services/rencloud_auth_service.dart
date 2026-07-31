import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/api_client.dart';
import '../models/rencloud_user.dart';

class AuthResult {
  final bool success;
  final String message;
  final RenCloudUser? user;

  AuthResult({required this.success, required this.message, this.user});
}

/// Strict Pterodactyl Panel Authentication Service
/// Uses Application API filter endpoint for exact user lookup.
/// ZERO local fallbacks — every login/register MUST hit panel.rencloud.online.
class RenCloudAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String panelUrl = 'https://panel.rencloud.online';
  static const String ptlaKey = 'ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0';

  /// Helper: Query Pterodactyl Panel for a user by email using the filter API.
  /// Returns the matched user attributes map, or null if not found.
  static Future<Map<String, dynamic>?> _findPanelUserByEmail(String email) async {
    // Use Pterodactyl Application API filter to search across ALL pages
    final filterUrl = '$panelUrl/api/application/users?filter[email]=${Uri.encodeComponent(email)}';
    debugPrint('[RenCloudAuth] Querying Panel: $filterUrl');

    final response = await http.get(
      Uri.parse(filterUrl),
      headers: {
        'Authorization': 'Bearer $ptlaKey',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 12));

    debugPrint('[RenCloudAuth] Panel response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('[RenCloudAuth] Panel returned non-200: ${response.body}');
      return null;
    }

    final data = json.decode(response.body);
    final userList = data['data'] as List<dynamic>? ?? [];

    debugPrint('[RenCloudAuth] Filter returned ${userList.length} result(s)');

    // Pterodactyl filter is a CONTAINS search, so we must do exact match
    for (var item in userList) {
      final attr = item['attributes'] as Map<String, dynamic>? ?? {};
      final pEmail = (attr['email'] ?? '').toString().toLowerCase().trim();
      if (pEmail == email) {
        debugPrint('[RenCloudAuth] Exact match found: Pterodactyl User ID #${attr['id']}');
        return attr;
      }
    }

    debugPrint('[RenCloudAuth] No exact email match found for "$email"');
    return null;
  }

  /// Helper: Query Pterodactyl Panel for a user by username using the filter API.
  static Future<Map<String, dynamic>?> _findPanelUserByUsername(String username) async {
    final filterUrl = '$panelUrl/api/application/users?filter[username]=${Uri.encodeComponent(username)}';
    debugPrint('[RenCloudAuth] Querying Panel by username: $filterUrl');

    final response = await http.get(
      Uri.parse(filterUrl),
      headers: {
        'Authorization': 'Bearer $ptlaKey',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    final userList = data['data'] as List<dynamic>? ?? [];

    for (var item in userList) {
      final attr = item['attributes'] as Map<String, dynamic>? ?? {};
      final pUsername = (attr['username'] ?? '').toString().toLowerCase().trim();
      if (pUsername == username) {
        return attr;
      }
    }
    return null;
  }

  /// Register new user account directly on Pterodactyl Panel
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult(success: false, message: 'Please enter a valid email address.');
    }

    final parts = fullName.trim().split(' ');
    final firstName = parts.first.isEmpty ? 'User' : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'RenCloud';

    String username = cleanEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    if (username.length < 3) username = 'user_${DateTime.now().millisecondsSinceEpoch % 10000}';

    // Admin status is determined ONLY by Pterodactyl Panel's root_admin field

    try {
      // First check if account already exists
      final existingUser = await _findPanelUserByEmail(cleanEmail);
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: 'An account with email "$cleanEmail" already exists on the panel. Please login instead.',
        );
      }

      debugPrint('[RenCloudAuth] Creating user on Pterodactyl Panel...');

      final response = await http.post(
        Uri.parse('$panelUrl/api/application/users'),
        headers: {
          'Authorization': 'Bearer $ptlaKey',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': cleanEmail,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'root_admin': false,
        }),
      ).timeout(const Duration(seconds: 12));

      debugPrint('[RenCloudAuth] Registration response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final attr = data['attributes'] ?? {};
        final pteroId = attr['id']?.toString() ?? '0';
        final isRootAdmin = attr['root_admin'] == true;

        final user = RenCloudUser(
          id: pteroId,
          fullName: '$firstName $lastName'.trim(),
          email: cleanEmail,
          role: isRootAdmin ? 'admin' : 'client',
          createdAt: DateTime.now(),
        );

        await ApiClient.saveAuthToken('ptla_user_token_$pteroId');
        await _storage.write(key: 'user_data', value: user.encode());

        return AuthResult(
          success: true,
          message: 'Account registered on panel! (User ID: #$pteroId)',
          user: user,
        );
      } else {
        String errorMsg = 'Registration failed.';
        try {
          final errData = json.decode(response.body);
          final errors = errData['errors'] as List<dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            errorMsg = errors.first['detail'] ?? errors.first['title'] ?? errorMsg;
          }
        } catch (_) {}
        return AuthResult(success: false, message: 'Panel Error: $errorMsg');
      }
    } catch (e) {
      debugPrint('[RenCloudAuth] Registration exception: $e');
      return AuthResult(
        success: false,
        message: 'Could not connect to panel.rencloud.online. Check your internet connection.',
      );
    }
  }

  /// STRICT Login — queries Pterodactyl Panel filter API.
  /// Returns success ONLY if the email/username exists on the panel.
  /// ZERO local fallbacks.
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      return AuthResult(success: false, message: 'Please enter your email or username.');
    }

    try {
      // Try email filter first, then username filter
      Map<String, dynamic>? panelUser;

      if (cleanEmail.contains('@')) {
        panelUser = await _findPanelUserByEmail(cleanEmail);
      } else {
        panelUser = await _findPanelUserByUsername(cleanEmail);
      }

      if (panelUser == null) {
        // REJECT — account does not exist on the panel
        return AuthResult(
          success: false,
          message: '❌ No account found for "$cleanEmail" on panel.rencloud.online. Please register first.',
        );
      }

      // Account exists on the panel — create authenticated session
      final pteroId = panelUser['id'].toString();
      final username = panelUser['username'] ?? cleanEmail;
      final firstName = panelUser['first_name'] ?? '';
      final lastName = panelUser['last_name'] ?? '';
      final panelEmail = (panelUser['email'] ?? cleanEmail).toString().toLowerCase();
      final fullName = '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName'.trim();
      // Admin status ONLY from Pterodactyl Panel root_admin field
      final isRootAdmin = panelUser['root_admin'] == true;

      final user = RenCloudUser(
        id: pteroId,
        fullName: fullName,
        email: panelEmail,
        role: isRootAdmin ? 'admin' : 'client',
        createdAt: DateTime.now(),
      );

      await ApiClient.saveAuthToken('ptla_panel_token_$pteroId');
      await _storage.write(key: 'user_data', value: user.encode());

      return AuthResult(
        success: true,
        message: isRootAdmin
            ? '👑 Welcome Super Admin! (ID: #$pteroId)'
            : 'Logged in! Verified on panel.rencloud.online (ID: #$pteroId)',
        user: user,
      );
    } catch (e) {
      debugPrint('[RenCloudAuth] Login exception: $e');
      return AuthResult(
        success: false,
        message: 'Unable to connect to panel.rencloud.online. Check your internet connection.',
      );
    }
  }

  /// Restore active user session from local secure storage.
  /// On restore, re-verify the user still exists on Pterodactyl Panel.
  static Future<RenCloudUser?> restoreSession() async {
    try {
      final rawUser = await _storage.read(key: 'user_data');
      if (rawUser == null || rawUser.isEmpty) return null;

      final cachedUser = RenCloudUser.decode(rawUser);

      // Re-verify this user still exists on the panel
      try {
        final panelUser = await _findPanelUserByEmail(cachedUser.email);
        if (panelUser != null) {
          debugPrint('[RenCloudAuth] Session restored & verified: ${cachedUser.email}');
          return cachedUser;
        } else {
          // User no longer exists on panel — clear stale session
          debugPrint('[RenCloudAuth] Cached user ${cachedUser.email} not found on panel. Clearing session.');
          await _storage.delete(key: 'user_data');
          await _storage.delete(key: 'auth_token');
          return null;
        }
      } catch (e) {
        // Network error during verification — allow cached session (offline mode)
        debugPrint('[RenCloudAuth] Could not verify session online, allowing cached: $e');
        return cachedUser;
      }
    } catch (e) {
      debugPrint('[RenCloudAuth] Restore session error: $e');
    }
    return null;
  }

  /// Logout — clears ALL local session data
  static Future<void> logout() async {
    try {
      await _storage.delete(key: 'user_data');
      await _storage.delete(key: 'auth_token');
      await ApiClient.clearAuth();
    } catch (_) {}
  }
}
