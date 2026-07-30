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
  }

  /// Register
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
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
    } else if (result.success) {
      // Automatic login if register returned success
      final loginResult = await RenCloudAuthService.login(email: email, password: password);
      if (loginResult.success) {
        state = state.copyWith(
          user: loginResult.user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
      }
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
    }
    return result;
  }

  /// Login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
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
