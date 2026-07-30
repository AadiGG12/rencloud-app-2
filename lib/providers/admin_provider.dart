import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pterodactyl/panel_user_model.dart';
import '../services/pterodactyl/admin_service.dart';
import '../services/pterodactyl/user_sync_service.dart';

// ─── Admin Auth State ────────────────────────────────────────────────

class AdminAuthState {
  final String? panelUrl;
  final String? apiKey;
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  const AdminAuthState({
    this.panelUrl,
    this.apiKey,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
  });

  AdminAuthState copyWith({
    String? panelUrl,
    String? apiKey,
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
  }) => AdminAuthState(
        panelUrl: panelUrl ?? this.panelUrl,
        apiKey: apiKey ?? this.apiKey,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  AdminAuthNotifier() : super(const AdminAuthState());

  Future<bool> login(String panelUrl, String apiKey) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = AdminService(panelUrl, apiKey);
      await service.listUsers();
      state = AdminAuthState(panelUrl: panelUrl, apiKey: apiKey, isLoggedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid Application API key');
      return false;
    }
  }

  void logout() => state = const AdminAuthState();
  void clearError() => state = state.copyWith(error: null);
}

final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) => AdminAuthNotifier());

// ─── Admin User List ─────────────────────────────────────────────────

class AdminUserListState {
  final List<PanelUser> users;
  final bool isLoading;
  final String? error;

  const AdminUserListState({this.users = const [], this.isLoading = false, this.error});

  AdminUserListState copyWith({
    List<PanelUser>? users,
    bool? isLoading,
    String? error,
  }) => AdminUserListState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AdminUserListNotifier extends StateNotifier<AdminUserListState> {
  AdminService? _service;
  UserSyncService? _syncService;

  AdminUserListNotifier() : super(const AdminUserListState());

  void setService(AdminService service) {
    _service = service;

    // Create and start the real-time sync service
    _syncService?.dispose();
    _syncService = UserSyncService(
      adminService: service,
      pollInterval: const Duration(seconds: 5),
    );

    // When sync detects changes, update state
    _syncService!.onUsersUpdated = (users) {
      if (mounted) {
        state = AdminUserListState(users: users);
      }
    };

    // Start real-time sync
    _syncService!.startSync();
  }

  /// Get the sync service for listening to events
  UserSyncService? get syncService => _syncService;

  Future<void> fetchUsers() async {
    if (_syncService != null) {
      // Use sync service for immediate refresh
      state = state.copyWith(isLoading: true, error: null);
      await _syncService!.syncNow();
      return;
    }
    if (_service == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _service!.listUsers();
      state = AdminUserListState(users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load users: $e');
    }
  }

  Future<bool> createUser({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    bool rootAdmin = false,
  }) async {
    if (_service == null) return false;
    try {
      await _service!.createUser(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        rootAdmin: rootAdmin,
      );
      // Force immediate sync to pick up the new user
      if (_syncService != null) {
        await _syncService!.syncNow();
      } else {
        await fetchUsers();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUser(int userId, {bool? rootAdmin}) async {
    if (_service == null) return false;
    try {
      await _service!.updateUser(userId, rootAdmin: rootAdmin);
      // Force immediate sync
      if (_syncService != null) {
        await _syncService!.syncNow();
      } else {
        await fetchUsers();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    if (_service == null) return false;
    try {
      await _service!.deleteUser(userId);
      // Force immediate sync
      if (_syncService != null) {
        await _syncService!.syncNow();
      } else {
        await fetchUsers();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _syncService?.dispose();
    super.dispose();
  }
}

final adminUserListProvider = StateNotifierProvider<AdminUserListNotifier, AdminUserListState>((ref) => AdminUserListNotifier());

// ─── Admin All Servers List ──────────────────────────────────────────

class AdminAllServersState {
  final List<AdminServer> servers;
  final bool isLoading;
  final String? error;

  const AdminAllServersState({this.servers = const [], this.isLoading = false, this.error});

  AdminAllServersState copyWith({
    List<AdminServer>? servers,
    bool? isLoading,
    String? error,
  }) => AdminAllServersState(
        servers: servers ?? this.servers,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AdminAllServersNotifier extends StateNotifier<AdminAllServersState> {
  AdminService? _service;

  AdminAllServersNotifier() : super(const AdminAllServersState());

  void setService(AdminService service) => _service = service;

  Future<void> fetchAllServers() async {
    if (_service == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final servers = await _service!.listAllServers();
      state = AdminAllServersState(servers: servers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load servers: $e');
    }
  }
}

final adminAllServersProvider = StateNotifierProvider<AdminAllServersNotifier, AdminAllServersState>((ref) => AdminAllServersNotifier());

// ─── Dashboard Stats ─────────────────────────────────────────────────

class AdminDashboardStats {
  final int totalServers;
  final int totalUsers;
  final int adminCount;
  final int suspendedServers;
  final int totalMemoryMb;
  final int totalDiskMb;

  const AdminDashboardStats({
    this.totalServers = 0,
    this.totalUsers = 0,
    this.adminCount = 0,
    this.suspendedServers = 0,
    this.totalMemoryMb = 0,
    this.totalDiskMb = 0,
  });
}

final adminDashboardStatsProvider = Provider<AdminDashboardStats>((ref) {
  final servers = ref.watch(adminAllServersProvider);
  final users = ref.watch(adminUserListProvider);

  int totalMemory = 0;
  int totalDisk = 0;
  int suspended = 0;

  for (final s in servers.servers) {
    totalMemory += s.limits.memory;
    totalDisk += s.limits.disk;
    if (s.isSuspended) suspended++;
  }

  return AdminDashboardStats(
    totalServers: servers.servers.length,
    totalUsers: users.users.length,
    adminCount: users.users.where((u) => u.isAdmin).length,
    suspendedServers: suspended,
    totalMemoryMb: totalMemory,
    totalDiskMb: totalDisk,
  );
});

// ─── User Sync Events Stream ─────────────────────────────────────────

final userSyncEventsProvider = StreamProvider<List<UserSyncEvent>>((ref) {
  final notifier = ref.watch(adminUserListProvider.notifier);
  final syncService = notifier.syncService;
  if (syncService == null) return const Stream.empty();
  return syncService.events;
});
