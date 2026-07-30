/// Custom Backend API Client for RenCloud
/// Target Backend URL: https://app.rencloud.online/api

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String defaultBackendUrl = 'https://app.rencloud.online/api';

  static final Dio dio = Dio(BaseOptions(
    baseUrl: defaultBackendUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  /// Initialize API client with authorization interceptors
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

          if (kDebugMode) {
            debugPrint('[ApiClient] ${options.method} ${options.uri}');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final newToken = await _tryRefreshToken();
            if (newToken != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {}
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Set custom backend URL
  static Future<void> setBackendUrl(String url) async {
    final cleanUrl = url.trim().replaceAll(RegExp(r'/$'), '');
    await _storage.write(key: 'backend_url', value: cleanUrl);
    dio.options.baseUrl = cleanUrl;
  }

  /// Get current backend URL
  static Future<String> getBackendUrl() async {
    final saved = await _storage.read(key: 'backend_url');
    return saved ?? defaultBackendUrl;
  }

  /// Save auth token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Get saved auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Clear auth data
  static Future<void> clearAuth() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }

  /// Try token refresh
  static Future<String?> _tryRefreshToken() async {
    try {
      final response = await dio.post('/auth/refresh');
      final newToken = response.data['access_token'] as String?;
      if (newToken != null) {
        await saveAuthToken(newToken);
        return newToken;
      }
    } catch (_) {}
    return null;
  }
}
