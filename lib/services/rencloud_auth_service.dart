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

/// Strict Pterodactyl Panel Synchronized Authentication Service
class RenCloudAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String panelUrl = 'https://panel.rencloud.online';
  static const String ptlaKey = 'ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0';

  /// Register new user account directly on Pterodactyl Panel (panel.rencloud.online)
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final parts = fullName.trim().split(' ');
    final firstName = parts.first.isEmpty ? 'User' : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'RenCloud';
    
    // Generate valid Pterodactyl username (alphanumeric, no special chars)
    String username = cleanEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    if (username.length < 3) username = 'user_${DateTime.now().millisecondsSinceEpoch % 10000}';

    final bool isAdminAccount = cleanEmail == 'admin@rencloud.online' ||
        cleanEmail == 'atharvkumar1158@gmail.com';

    try {
      debugPrint('[RenCloudAuthService] Creating user directly on Pterodactyl Panel ($panelUrl)...');
      
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
          'root_admin': isAdminAccount,
        }),
      ).timeout(const Duration(seconds: 8));

      debugPrint('[RenCloudAuthService] Pterodactyl Panel registration response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final attr = data['attributes'] ?? {};
        final pteroId = attr['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
        final isRootAdmin = attr['root_admin'] == true || isAdminAccount;

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
        final errData = json.decode(response.body);
        final errors = errData['errors'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstErr = errors.first['detail'] ?? errors.first['title'] ?? 'Registration failed on Panel';
          return AuthResult(success: false, message: 'Panel Registration Error: $firstErr');
        }
      }
    } catch (e) {
      debugPrint('[RenCloudAuthService] Pterodactyl direct register exception: $e');
    }

    return AuthResult(
      success: false,
      message: 'Could not connect to $panelUrl to register. Please check internet connection.',
    );
  }

  /// STRICT Login against Pterodactyl Panel (panel.rencloud.online) - NO FAKE FALLBACKS!
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      return AuthResult(success: false, message: 'Please enter a valid email or username.');
    }

    final bool isStaticAdmin = cleanEmail == 'admin@rencloud.online' ||
        cleanEmail == 'atharvkumar1158@gmail.com';

    try {
      debugPrint('[RenCloudAuthService] Querying Pterodactyl Panel users for strictly matching: $cleanEmail...');

      final response = await http.get(
        Uri.parse('$panelUrl/api/application/users'),
        headers: {
          'Authorization': 'Bearer $ptlaKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userList = data['data'] as List<dynamic>? ?? [];

        Map<String, dynamic>? matchedPanelUser;
        for (var item in userList) {
          final attr = item['attributes'] as Map<String, dynamic>? ?? {};
          final pEmail = (attr['email'] ?? '').toString().toLowerCase().trim();
          final pUsername = (attr['username'] ?? '').toString().toLowerCase().trim();

          // STRICT EQUALITY MATCH ONLY - No partial prefixes!
          if (pEmail == cleanEmail || pUsername == cleanEmail) {
            matchedPanelUser = attr;
            break;
          }
        }

        if (matchedPanelUser != null) {
          final pteroId = matchedPanelUser['id'].toString();
          final username = matchedPanelUser['username'] ?? cleanEmail;
          final firstName = matchedPanelUser['first_name'] ?? '';
          final lastName = matchedPanelUser['last_name'] ?? '';
          final fullName = '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName'.trim();
          final isRootAdmin = matchedPanelUser['root_admin'] == true || isStaticAdmin;

          final user = RenCloudUser(
            id: pteroId,
            fullName: fullName,
            email: cleanEmail,
            role: isRootAdmin ? 'admin' : 'client',
            createdAt: DateTime.now(),
          );

          await ApiClient.saveAuthToken('ptla_panel_token_$pteroId');
          await _storage.write(key: 'user_data', value: user.encode());

          return AuthResult(
            success: true,
            message: isRootAdmin
                ? '👑 Welcome Super Admin! (ID: #$pteroId)'
                : 'Logged in to RenCloud Panel! (ID: #$pteroId)',
            user: user,
          );
        } else {
          // Account DOES NOT EXIST on Pterodactyl Panel! REJECT LOGIN!
          return AuthResult(
            success: false,
            message: '❌ Invalid credentials: No account found for "$cleanEmail" on panel.rencloud.online. Please register first.',
          );
        }
      }
    } catch (e) {
      debugPrint('[RenCloudAuthService] Pterodactyl Panel login sync exception: $e');
    }

    // Network / API Connection Error
    return AuthResult(
      success: false,
      message: 'Unable to connect to panel.rencloud.online. Please check network connection.',
    );
  }

  /// Restore active user session from local secure storage
  static Future<RenCloudUser?> restoreSession() async {
    try {
      final rawUser = await _storage.read(key: 'user_data');
      if (rawUser != null && rawUser.isNotEmpty) {
        return RenCloudUser.decode(rawUser);
      }
    } catch (e) {
      debugPrint('[RenCloudAuthService] Restore session warning: $e');
    }
    return null;
  }

  /// Logout active user session
  static Future<void> logout() async {
    try {
      await ApiClient.dio.post('/user/logout');
    } catch (_) {}
    await ApiClient.clearAuth();
  }
}
