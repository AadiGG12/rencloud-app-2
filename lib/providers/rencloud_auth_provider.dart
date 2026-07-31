import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_user.dart';
import '../services/rencloud_auth_service.dart';

class RenCloudAuthState {
  final RenCloudUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  RenCloudAuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  RenCloudAuthState copyWith({
    RenCloudUser? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RenCloudAuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RenCloudAuthNotifier extends StateNotifier<RenCloudAuthState> {
  RenCloudAuthNotifier() : super(RenCloudAuthState()) {
    restoreSession();
  }

  /// Restore user session on startup
  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await RenCloudAuthService.restoreSession();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Register with guaranteed loading reset
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await RenCloudAuthService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        state = state.copyWith(
          user: result.user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
      }
      return result;
    } catch (e) {
      final errorResult = AuthResult(success: false, message: 'Registration failed: $e');
      state = state.copyWith(isLoading: false, errorMessage: errorResult.message);
      return errorResult;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login with guaranteed loading reset
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await RenCloudAuthService.login(email: email, password: password);
      if (result.success && result.user != null) {
        state = state.copyWith(
          user: result.user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
      }
      return result;
    } catch (e) {
      final errorResult = AuthResult(success: false, message: 'Login failed: $e');
      state = state.copyWith(isLoading: false, errorMessage: errorResult.message);
      return errorResult;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Logout
  Future<void> logout() async {
    await RenCloudAuthService.logout();
    state = RenCloudAuthState();
  }
}

final rencloudAuthProvider = StateNotifierProvider<RenCloudAuthNotifier, RenCloudAuthState>((ref) {
  return RenCloudAuthNotifier();
});
