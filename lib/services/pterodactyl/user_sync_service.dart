import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/pterodactyl/panel_user_model.dart';
import 'admin_service.dart';

/// Callback types for user sync events
typedef UserSyncCallback = void Function(List<PanelUser> users);
typedef UserChangeCallback = void Function(UserSyncEvent event);

/// Types of user sync events
enum UserSyncEventType { added, removed, updated }

/// A single user sync event (a user was added, removed, or updated)
class UserSyncEvent {
  final UserSyncEventType type;
  final PanelUser user;
  final PanelUser? previousUser; // Only for 'updated' events

  const UserSyncEvent({
    required this.type,
    required this.user,
    this.previousUser,
  });

  String get description {
    switch (type) {
      case UserSyncEventType.added:
        return '${user.username} joined the panel';
      case UserSyncEventType.removed:
        return '${user.username} was removed';
      case UserSyncEventType.updated:
        return '${user.username} was updated';
    }
  }
}

/// Real-time user sync service that polls Pterodactyl Application API
/// and detects user changes (additions, removals, updates).
///
/// This enables bidirectional sync:
/// - Panel → App: Detects users created/deleted on the web panel
/// - App → Panel: Changes made via AdminService are immediately reflected
class UserSyncService {
  final AdminService _adminService;
  Timer? _pollTimer;
  bool _isRunning = false;
  List<PanelUser> _lastKnownUsers = [];
  final Duration _pollInterval;

  /// Called whenever the full user list is refreshed
  UserSyncCallback? onUsersUpdated;

  /// Called for each individual user change event
  UserChangeCallback? onUserChanged;

  /// Stream controller for sync events (for reactive listeners)
  final StreamController<List<UserSyncEvent>> _eventController =
      StreamController<List<UserSyncEvent>>.broadcast();

  /// Stream of sync events
  Stream<List<UserSyncEvent>> get events => _eventController.stream;

  /// Whether the sync service is actively polling
  bool get isRunning => _isRunning;

  /// The last known user list
  List<PanelUser> get lastKnownUsers => List.unmodifiable(_lastKnownUsers);

  UserSyncService({
    required AdminService adminService,
    Duration pollInterval = const Duration(seconds: 5),
  })  : _adminService = adminService,
        _pollInterval = pollInterval;

  /// Start real-time polling for user changes
  void startSync() {
    if (_isRunning) return;
    _isRunning = true;
    debugPrint('[UserSync] Starting real-time user sync (interval: ${_pollInterval.inSeconds}s)');

    // Do an immediate fetch, then start the timer
    _poll();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  /// Stop the sync service
  void stopSync() {
    _isRunning = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    debugPrint('[UserSync] Stopped real-time user sync');
  }

  /// Force an immediate sync (useful after creating/deleting a user from the app)
  Future<void> syncNow() async {
    await _poll();
  }

  /// Dispose of resources
  void dispose() {
    stopSync();
    _eventController.close();
  }

  /// Internal polling method that fetches users and diffs against last known state
  Future<void> _poll() async {
    try {
      // Fetch all users (paginated — fetch all pages)
      final allUsers = await _fetchAllUsers();

      // Diff against last known state
      final events = _diffUsers(_lastKnownUsers, allUsers);

      // Update last known state
      _lastKnownUsers = allUsers;

      // Always notify with the full list
      onUsersUpdated?.call(allUsers);

      // Notify about individual changes
      if (events.isNotEmpty) {
        for (final event in events) {
          debugPrint('[UserSync] ${event.description}');
          onUserChanged?.call(event);
        }
        _eventController.add(events);
      }
    } catch (e) {
      debugPrint('[UserSync] Poll error: $e');
    }
  }

  /// Fetch all users across all pages from Pterodactyl Application API
  Future<List<PanelUser>> _fetchAllUsers() async {
    final List<PanelUser> allUsers = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      final users = await _adminService.listUsers(page: page);
      allUsers.addAll(users);
      // Pterodactyl returns 50 users per page by default
      // If we got fewer than 50, we've reached the last page
      if (users.length < 50) {
        hasMore = false;
      } else {
        page++;
      }
    }

    return allUsers;
  }

  /// Diff two user lists and return sync events
  List<UserSyncEvent> _diffUsers(List<PanelUser> oldUsers, List<PanelUser> newUsers) {
    if (oldUsers.isEmpty && newUsers.isNotEmpty) {
      // Initial load — don't fire "added" events for every existing user
      return [];
    }

    final List<UserSyncEvent> events = [];
    final oldMap = {for (final u in oldUsers) u.id: u};
    final newMap = {for (final u in newUsers) u.id: u};

    // Check for added users
    for (final entry in newMap.entries) {
      if (!oldMap.containsKey(entry.key)) {
        events.add(UserSyncEvent(
          type: UserSyncEventType.added,
          user: entry.value,
        ));
      }
    }

    // Check for removed users
    for (final entry in oldMap.entries) {
      if (!newMap.containsKey(entry.key)) {
        events.add(UserSyncEvent(
          type: UserSyncEventType.removed,
          user: entry.value,
        ));
      }
    }

    // Check for updated users (compare updatedAt timestamp)
    for (final entry in newMap.entries) {
      final old = oldMap[entry.key];
      if (old != null && _hasUserChanged(old, entry.value)) {
        events.add(UserSyncEvent(
          type: UserSyncEventType.updated,
          user: entry.value,
          previousUser: old,
        ));
      }
    }

    return events;
  }

  /// Check if a user's data has changed
  bool _hasUserChanged(PanelUser old, PanelUser current) {
    return old.username != current.username ||
        old.email != current.email ||
        old.firstName != current.firstName ||
        old.lastName != current.lastName ||
        old.isAdmin != current.isAdmin ||
        old.hasTwoFactor != current.hasTwoFactor ||
        old.updatedAt != current.updatedAt;
  }
}
