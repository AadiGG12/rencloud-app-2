/// Secure Backend API Client
///
/// This is the ONLY HTTP client the Flutter app should use for
/// Pterodactyl-related operations. It NEVER holds a PTLA key.
/// All sensitive operations are proxied through the backend at
/// `/api/proxy/pterodactyl/...` which holds the PTLA key server-side.
///
/// For user Client API operations (console, files, etc.), the backend
/// securely attaches the user's session/token.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static final Dio dio = Dio(BaseOptions(
    baseUrl: _defaultBackendUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static const String _defaultBackendUrl = 'https://panel.rencloud.online';

  /// Initialize the API client with interceptors for auth
  static Future<void> init() async {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Load custom backend URL if saved
          final customUrl = await _storage.read(key: 'backend_url');
          if (customUrl != null && customUrl.isNotEmpty) {
            options.baseUrl = customUrl;
          }

          // Attach JWT auth token
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Debug logging in development
          if (kDebugMode) {
            debugPrint('[ApiClient] ${options.method} ${options.uri}');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Auto-refresh token on 401
          if (error.response?.statusCode == 401) {
            final newToken = await _tryRefreshToken();
            if (newToken != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                // Refresh failed, continue with original error
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Set the backend URL (for custom deployments)
  static Future<void> setBackendUrl(String url) async {
    final cleanUrl = url.trim().replaceAll(RegExp(r'/$'), '');
    await _storage.write(key: 'backend_url', value: cleanUrl);
    dio.options.baseUrl = cleanUrl;
  }

  /// Get the current backend URL
  static Future<String> getBackendUrl() async {
    final saved = await _storage.read(key: 'backend_url');
    return saved ?? _defaultBackendUrl;
  }

  /// Save JWT auth token after login
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Get the saved JWT token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Clear auth data on logout
  static Future<void> clearAuth() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'backend_url');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_data');
  }

  /// Attempt to refresh the JWT token
  static Future<String?> _tryRefreshToken() async {
    try {
      final response = await dio.post('/auth/refresh');
      final newToken = response.data['access_token'] as String?;
      if (newToken != null) {
        await saveAuthToken(newToken);
        return newToken;
      }
    } catch (_) {
      // Token refresh failed
    }
    return null;
  }
}
