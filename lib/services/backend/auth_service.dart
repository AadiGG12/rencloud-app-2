/// Backend Authentication Service
///
/// These calls go through our secure backend at /auth/*.
/// The backend verifies Pterodactyl credentials using its
/// Application API key (which NEVER leaves the server).
///
/// The Flutter app only receives a JWT for subsequent calls.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/api_client.dart';

class BackendAuthService {
  /// Login with Pterodactyl panel email & password
  ///
  /// Returns JWT access token + user info on success.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token != null) {
        await ApiClient.saveAuthToken(token);
      }

      return {
        'access_token': token ?? '',
        'user': user ?? {},
        'token_type': data['token_type'] ?? 'bearer',
      };
    } on DioException catch (e) {
      String message = 'Authentication failed. Please check your credentials.';
      if (e.response?.data is Map) {
        final detail = e.response?.data['detail'];
        if (detail is String) {
          message = detail;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        message = 'Cannot connect to the server. Check your internet connection.';
      }
      debugPrint('[BackendAuth] Login failed: $e');
      throw Exception(message);
    }
  }

  /// Get current user info from JWT token
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.dio.get('/auth/me');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[BackendAuth] Get user failed: $e');
      return null;
    }
  }

  /// Refresh the JWT token
  static Future<String?> refreshToken() async {
    try {
      final response = await ApiClient.dio.post('/auth/refresh');
      final token = response.data['access_token'] as String?;
      if (token != null) {
        await ApiClient.saveAuthToken(token);
      }
      return token;
    } catch (e) {
      debugPrint('[BackendAuth] Token refresh failed: $e');
      return null;
    }
  }

  /// Logout - clear auth state
  static Future<void> logout() async {
    try {
      await ApiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore logout errors
    }
    await ApiClient.clearAuth();
  }
}
