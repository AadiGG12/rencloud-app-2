import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pterodactyl/server_model.dart';
import '../services/backend/server_service.dart';
import '../services/pterodactyl/auth_service.dart';

// Auth State
class PterodactylAuthState {
  final String? panelUrl;
  final String? apiKey;
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final bool isAdmin;
  final String? userEmail;
  final String? username;

  const PterodactylAuthState({
    this.panelUrl,
    this.apiKey,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.isAdmin = false,
    this.userEmail,
    this.username,
  });

  PterodactylAuthState copyWith({
    String? panelUrl,
    String? apiKey,
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    bool? isAdmin,
    String? userEmail,
    String? username,
  }) => PterodactylAuthState(
    panelUrl: panelUrl ?? this.panelUrl,
    apiKey: apiKey ?? this.apiKey,
    isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isAdmin: isAdmin ?? this.isAdmin,
    userEmail: userEmail ?? this.userEmail,
    username: username ?? this.username,
  );
}

class PterodactylAuthNotifier extends StateNotifier<PterodactylAuthState> {
  PterodactylAuthNotifier() : super(const PterodactylAuthState());

  Future<bool> login(String panelUrl, String apiKey) async {
    state = state.copyWith(isLoading: true, error: null);
    final valid = await AuthService.validateKey(panelUrl, apiKey);
    if (valid) {
      state = PterodactylAuthState(panelUrl: panelUrl, apiKey: apiKey, isLoggedIn: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Invalid panel URL or API key');
      return false;
    }
  }

  void setAdminInfo({
    required bool isAdmin,
    required String email,
    required String username,
    String? panelUrl,
    String? apiKey,
  }) {
    state = state.copyWith(
      isAdmin: isAdmin,
      userEmail: email,
      username: username,
      isLoggedIn: true,
      panelUrl: panelUrl ?? state.panelUrl ?? 'https://panel.rencloud.online',
      apiKey: apiKey,  // NEVER use a hardcoded fallback API key - security critical!
    );
  }

  void logout() => state = const PterodactylAuthState();

  void clearError() => state = state.copyWith(error: null);
}

final pterodactylAuthProvider = StateNotifierProvider<PterodactylAuthNotifier, PterodactylAuthState>((ref) => PterodactylAuthNotifier());

// Server List
class ServerListState {
  final List<PterodactylServer> servers;
  final bool isLoading;
  final String? error;

  const ServerListState({this.servers = const [], this.isLoading = false, this.error});

  ServerListState copyWith({List<PterodactylServer>? servers, bool? isLoading, String? error}) =>
      ServerListState(servers: servers ?? this.servers, isLoading: isLoading ?? this.isLoading, error: error);
}

class ServerListNotifier extends StateNotifier<ServerListState> {
  ServerListNotifier() : super(const ServerListState());

  Future<void> fetchServers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final servers = await BackendServerService.listServers();
      state = ServerListState(servers: servers);
    } catch (e) {
      final cleanMsg = 'Failed to load servers. Please try again.';
      state = state.copyWith(isLoading: false, error: cleanMsg);
    }
  }
}

final pterodactylServerListProvider = StateNotifierProvider<ServerListNotifier, ServerListState>((ref) => ServerListNotifier());

// Server Resources - fetched through backend
final serverResourcesProvider = FutureProvider.family<ServerResources?, String>((ref, serverId) async {
  try {
    return await BackendServerService.getResources(serverId);
  } catch (_) {
    return null;
  }
});
