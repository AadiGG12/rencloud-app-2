import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../models/rencloud_user.dart';

class AuthResult {
  final bool success;
  final String message;
  final RenCloudUser? user;

  AuthResult({required this.success, required this.message, this.user});
}

/// Custom RenCloud Auth Service connecting to app.rencloud.online/api
class RenCloudAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Register new RenCloud user account
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        final userData = response.data['user'] ?? response.data['data'];

        if (token != null) {
          await ApiClient.saveAuthToken(token.toString());
        }

        RenCloudUser? user;
        if (userData != null) {
          user = RenCloudUser.fromJson(userData);
          await _storage.write(key: 'user_data', value: user.encode());
        }

        return AuthResult(
          success: true,
          message: response.data['message'] ?? 'Account created successfully!',
          user: user,
        );
      }

      return AuthResult(
        success: false,
        message: response.data['message'] ?? 'Failed to create account.',
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Registration failed. Please check network connection.';
      return AuthResult(success: false, message: errorMsg.toString());
    } catch (e) {
      return AuthResult(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  /// Login with RenCloud user credentials
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['access_token'];
        final userData = response.data['user'] ?? response.data['data'];

        if (token != null) {
          await ApiClient.saveAuthToken(token.toString());
        }

        RenCloudUser? user;
        if (userData != null) {
          user = RenCloudUser.fromJson(userData);
          await _storage.write(key: 'user_data', value: user.encode());
        }

        return AuthResult(
          success: true,
          message: response.data['message'] ?? 'Logged in successfully!',
          user: user,
        );
      }

      return AuthResult(
        success: false,
        message: response.data['message'] ?? 'Invalid credentials.',
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Login failed. Please check credentials or network connection.';
      return AuthResult(success: false, message: errorMsg.toString());
    } catch (e) {
      return AuthResult(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  /// Restore active user session from local secure storage or API profile call
  static Future<RenCloudUser?> restoreSession() async {
    try {
      final rawUser = await _storage.read(key: 'user_data');
      if (rawUser != null && rawUser.isNotEmpty) {
        return RenCloudUser.decode(rawUser);
      }

      final token = await ApiClient.getAuthToken();
      if (token != null && token.isNotEmpty) {
        final response = await ApiClient.dio.get('/user/profile');
        if (response.statusCode == 200) {
          final user = RenCloudUser.fromJson(response.data);
          await _storage.write(key: 'user_data', value: user.encode());
          return user;
        }
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
