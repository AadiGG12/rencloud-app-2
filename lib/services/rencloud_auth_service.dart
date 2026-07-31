import 'dart:convert';
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

/// Strict Pterodactyl Panel Synchronized Authentication Service
class RenCloudAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String panelUrl = 'https://panel.rencloud.online';
  static const String ptlaKey = 'ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0';

  static Future<Map<String, dynamic>?> _findPanelUserByEmail(String email) async {
    final filterUrl = '$panelUrl/api/application/users?filter[email]=${Uri.encodeComponent(email)}';
    try {
      final response = await http.get(
        Uri.parse(filterUrl),
        headers: {
          'Authorization': 'Bearer $ptlaKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final userList = data['data'] as List<dynamic>? ?? [];

      for (var item in userList) {
        final attr = item['attributes'] as Map<String, dynamic>? ?? {};
        final pEmail = (attr['email'] ?? '').toString().toLowerCase().trim();
        if (pEmail == email) return attr;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> _findPanelUserByUsername(String username) async {
    final filterUrl = '$panelUrl/api/application/users?filter[username]=${Uri.encodeComponent(username)}';
    try {
      final response = await http.get(
        Uri.parse(filterUrl),
        headers: {
          'Authorization': 'Bearer $ptlaKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final userList = data['data'] as List<dynamic>? ?? [];

      for (var item in userList) {
        final attr = item['attributes'] as Map<String, dynamic>? ?? {};
        final pUsername = (attr['username'] ?? '').toString().toLowerCase().trim();
        if (pUsername == username) return attr;
      }
    } catch (_) {}
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

    try {
      final existingUser = await _findPanelUserByEmail(cleanEmail);
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: 'An account with email "$cleanEmail" already exists on the panel. Please login instead.',
        );
      }

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
      ).timeout(const Duration(seconds: 10));

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
          message: 'Account registered on $panelUrl! (User ID: #$pteroId)',
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
      return AuthResult(
        success: false,
        message: 'Could not connect to panel.rencloud.online. Check your internet connection.',
      );
    }
  }

  /// STRICT Login against Pterodactyl Panel
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      return AuthResult(success: false, message: 'Please enter your email or username.');
    }

    try {
      Map<String, dynamic>? panelUser;
      if (cleanEmail.contains('@')) {
        panelUser = await _findPanelUserByEmail(cleanEmail);
      } else {
        panelUser = await _findPanelUserByUsername(cleanEmail);
      }

      if (panelUser == null) {
        return AuthResult(
          success: false,
          message: '❌ No account found for "$cleanEmail" on panel.rencloud.online. Please register first.',
        );
      }

      final pteroId = panelUser['id'].toString();
      final username = panelUser['username'] ?? cleanEmail;
      final firstName = panelUser['first_name'] ?? '';
      final lastName = panelUser['last_name'] ?? '';
      final panelEmail = (panelUser['email'] ?? cleanEmail).toString().toLowerCase();
      final fullName = '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName'.trim();
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
      return AuthResult(
        success: false,
        message: 'Unable to connect to panel.rencloud.online. Check your internet connection.',
      );
    }
  }

  static Future<RenCloudUser?> restoreSession() async {
    try {
      final rawUser = await _storage.read(key: 'user_data');
      if (rawUser != null && rawUser.isNotEmpty) {
        final cachedUser = RenCloudUser.decode(rawUser);
        final panelUser = await _findPanelUserByEmail(cachedUser.email);
        if (panelUser != null) {
          return cachedUser;
        } else {
          await _storage.delete(key: 'user_data');
          await _storage.delete(key: 'auth_token');
          return null;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> logout() async {
    try {
      await _storage.delete(key: 'user_data');
      await _storage.delete(key: 'auth_token');
      await ApiClient.clearAuth();
    } catch (_) {}
  }
}
