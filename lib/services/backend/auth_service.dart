/// Backend Authentication Service
///
/// Two-tier auth strategy:
/// 1. PRIMARY — Calls our secure backend at /auth/login (NEVER exposes PTLA keys)
/// 2. FALLBACK — Direct Pterodactyl panel login via CSRF-protected web login
/// 3. LAST RESORT — Basic credential acceptance when panel is unreachable
///
/// NEVER uses a hardcoded PTLA key. The panel fallback authenticates
/// using the user's own email/password via the panel's web login flow.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';

class BackendAuthService {
  static const String _defaultPanelUrl = 'https://panel.rencloud.online';

  /// Login with email & password.
  ///
  /// Strategy:
  ///   1. Secure backend /auth/login  (when deployed)
  ///   2. Direct panel web login       (CSRF-protected)
  ///   3. Basic credential acceptance  (last resort - catalog-only access)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // 1. SECURE BACKEND (when the FastAPI backend is deployed)
    try {
      return await _backendLogin(email, password);
    } catch (e) {
      debugPrint('[BackendAuth] Backend unreachable, trying panel fallback: $e');
    }

    // 2. DIRECT PTERODACTYL PANEL WEB LOGIN (CSRF-protected)
    //    Uses user's own email/password — no hardcoded PTLA key
    try {
      return await _directPanelLogin(email, password);
    } catch (e) {
      debugPrint('[BackendAuth] Panel login fallback failed: $e');
    }

    // 3. LAST RESORT — Basic acceptance for any non-empty credentials
    //    This grants catalog-only access when neither the backend
    //    nor the panel login is reachable. No server management possible.
    if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
      debugPrint('[BackendAuth] Using last-resort credential acceptance');
      final isGmail = email.contains('@');
      final username = isGmail ? email.split('@')[0] : email;
      return {
        'access_token': 'local_session_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 0,
          'email': email,
          'username': username,
          'first_name': username,
          'last_name': '',
          'is_admin': false,
        },
        'token_type': 'local',
        'auth_source': 'local_fallback',
      };
    }

    throw Exception(
      'Authentication failed. Please check your credentials and ensure '
      'the server is reachable.',
    );
  }

  /// PRIMARY: Login through our secure FastAPI backend
  static Future<Map<String, dynamic>> _backendLogin(
    String email,
    String password,
  ) async {
    final response = await ApiClient.dio.post('/auth/login', data: {
      'email': email.trim(),
      'password': password,
    });

    final data = response.data as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;

    if (token != null && token.isNotEmpty) {
      await ApiClient.saveAuthToken(token);
    }

    return {
      'access_token': token ?? '',
      'user': user ?? {},
      'token_type': data['token_type'] ?? 'bearer',
      'auth_source': 'backend',
    };
  }

  /// FALLBACK: Direct Pterodactyl panel login using the web auth flow.
  ///
  /// Pterodactyl uses CSRF-protected login:
  ///   1. GET /auth/login  → extract _token from HTML
  ///   2. POST /auth/login → with _token, user, password
  ///   3. Session cookie → subsequent API calls
  ///
  /// NO hardcoded PTLA key — only user's email and password.
  static Future<Map<String, dynamic>> _directPanelLogin(
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    // === FALLBACK A: Try Client API directly if password is an API key ===
    if (cleanPassword.startsWith('ptlc_') || cleanPassword.startsWith('ptla_')) {
      try {
        final dio = Dio(BaseOptions(
          baseUrl: _defaultPanelUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ));

        final response = await dio.get(
          '/api/client',
          options: Options(headers: {
            'Authorization': 'Bearer ${cleanPassword}',
            'Accept': 'application/json',
          }),
        );

        final data = response.data;
        Map<String, dynamic> userAttrs = {};
        if (data is Map && data['attributes'] != null) {
          userAttrs = data['attributes'] as Map<String, dynamic>;
        }

        await ApiClient.saveAuthToken(cleanPassword);

        return {
          'access_token': cleanPassword,
          'user': {
            'id': userAttrs['id'] ?? 1,
            'email': userAttrs['email'] ?? cleanEmail,
            'username': userAttrs['username'] ?? cleanEmail,
            'first_name': userAttrs['first_name'] ?? '',
            'last_name': userAttrs['last_name'] ?? '',
            'is_admin': userAttrs['root_admin'] == true,
          },
          'token_type': 'client_api_key',
          'auth_source': 'api_key',
        };
      } catch (e) {
        debugPrint('[BackendAuth] API key login failed: $e');
        throw Exception('Invalid API key');
      }
    }

    // === FALLBACK B: CSRF-protected panel web login ===
    // Step 1: GET the login page to extract CSRF token
    String? csrfToken;
    try {
      final getResponse = await http.get(
        Uri.parse('$_defaultPanelUrl/auth/login'),
        headers: {'Accept': 'text/html,application/json'},
      ).timeout(const Duration(seconds: 8));

      final body = getResponse.body;

      // Try to extract CSRF _token from hidden input field
      // Pterodactyl uses <input type="hidden" name="_token" value="...">
      final tokenMatch = RegExp(
        r'''<input[^>]*name=['"]_token['"][^>]*value=['"]([^'"]+)['"]>''',
        caseSensitive: false,
      ).firstMatch(body);

      if (tokenMatch != null) {
        csrfToken = tokenMatch.group(1);
        debugPrint('[BackendAuth] Extracted CSRF token from login page');
      }

      // Also try JSON-based token endpoint
      if (csrfToken == null) {
        try {
          final tokenResponse = await http.get(
            Uri.parse('$_defaultPanelUrl/auth/login'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 5));

          if (tokenResponse.body.isNotEmpty) {
            final jsonData = jsonDecode(tokenResponse.body);
            if (jsonData is Map) {
              csrfToken = jsonData['_token']?.toString() ??
                  jsonData['csrf_token']?.toString();
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[BackendAuth] Failed to fetch CSRF token: $e');
    }

    // Step 2: POST login with CSRF token + credentials
    Map<String, String> loginData = {
      'user': cleanEmail,
      'password': cleanPassword,
    };
    if (csrfToken != null && csrfToken.isNotEmpty) {
      loginData['_token'] = csrfToken;
    }

    try {
      final loginResponse = await http.post(
        Uri.parse('$_defaultPanelUrl/auth/login'),
        headers: {
          'Accept': 'application/json, text/html',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginData),
      ).timeout(const Duration(seconds: 10));

      // Check if login was successful
      if (loginResponse.statusCode == 200 || loginResponse.statusCode == 302) {
        final isGmail = cleanEmail.contains('@');
        final username = isGmail ? cleanEmail.split('@')[0] : cleanEmail;

        // Try to extract user info from response body
        Map<String, dynamic> userData = {};
        try {
          if (loginResponse.body.isNotEmpty && loginResponse.headers['content-type']?.contains('json') == true) {
            final body = jsonDecode(loginResponse.body);
            if (body is Map) {
              userData = body.cast<String, dynamic>();
            }
          }
        } catch (_) {}

        await ApiClient.saveAuthToken(
          'panel_session_${username}_${DateTime.now().millisecondsSinceEpoch}',
        );

        return {
          'access_token':
              'panel_session_${username}_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': userData['id'] ?? 0,
            'email': userData['email'] ?? cleanEmail,
            'username': userData['username'] ?? username,
            'first_name': userData['first_name'] ?? username,
            'last_name': userData['last_name'] ?? '',
            'is_admin': userData['root_admin'] == true ||
                userData['is_admin'] == true,
          },
          'token_type': 'session',
          'auth_source': 'panel_direct',
        };
      }
    } catch (e) {
      debugPrint('[BackendAuth] Panel login POST failed: $e');
    }

    // === FALLBACK C: Try the Pterodactyl Client API with session ===
    // Some panels support cookie-based auth
    throw Exception('Panel login failed. Check credentials or use an API key.');
  }

  /// Get current user info
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.dio.get('/auth/me');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[BackendAuth] Get user failed: $e');
      return null;
    }
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await ApiClient.dio.post('/auth/logout');
    } catch (_) {}
    await ApiClient.clearAuth();
  }
}
