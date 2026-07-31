import '../../models/pterodactyl/panel_user_model.dart';
import '../../models/pterodactyl/server_model.dart';
import 'pterodactyl_client.dart';

/// A server as returned by the Application API (includes owner info).
class AdminServer {
  final String id;
  final String uuid;
  final String name;
  final String? description;
  final String node;
  final bool isSuspended;
  final bool isInstalling;
  final ServerLimits limits;
  final ServerFeatureLimits featureLimits;
  final int ownerId;
  final String? ownerEmail;
  final String? ownerUsername;
  final DateTime createdAt;

  AdminServer({
    required this.id,
    required this.uuid,
    required this.name,
    this.description,
    required this.node,
    required this.isSuspended,
    required this.isInstalling,
    required this.limits,
    required this.featureLimits,
    required this.ownerId,
    this.ownerEmail,
    this.ownerUsername,
    required this.createdAt,
  });

  factory AdminServer.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    final rel = attrs['relationships'] as Map<String, dynamic>?;
    final userAttrs = rel?['user']?['attributes'] as Map<String, dynamic>?;

    return AdminServer(
      id: attrs['identifier'] as String? ?? '',
      uuid: attrs['uuid'] as String? ?? '',
      name: attrs['name'] as String? ?? '',
      description: attrs['description'] as String?,
      node: attrs['node'] as String? ?? '',
      isSuspended: attrs['suspended'] as bool? ?? false,
      isInstalling: attrs['installing'] as bool? ?? false,
      limits: ServerLimits.fromJson(attrs['limits'] as Map<String, dynamic>? ?? {}),
      featureLimits: ServerFeatureLimits.fromJson(attrs['feature_limits'] as Map<String, dynamic>? ?? {}),
      ownerId: attrs['user'] as int? ?? userAttrs?['id'] as int? ?? 0,
      ownerEmail: userAttrs?['email'] as String?,
      ownerUsername: userAttrs?['username'] as String?,
      createdAt: DateTime.tryParse(attrs['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class AdminService {
  static const String defaultPanelUrl = 'https://panel.rencloud.online';
  static const String defaultPtlaKey = 'ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0';

  final PterodactylClient _client;

  AdminService([String? panelUrl, String? apiKey])
      : _client = PterodactylClient(
          panelUrl: panelUrl ?? defaultPanelUrl,
          apiKey: apiKey ?? defaultPtlaKey,
          apiBase: '/api/application',
        );

  factory AdminService.defaultInstance() {
    return AdminService(defaultPanelUrl, defaultPtlaKey);
  }

  /// List all users in the panel
  Future<List<PanelUser>> listUsers({int? page}) async {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    final response = await _client.get('/users', query: query.isNotEmpty ? query : null);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => PanelUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// List all servers across all users
  Future<List<AdminServer>> listAllServers({int? page}) async {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    final response = await _client.get('/servers', query: query.isNotEmpty ? query : null);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => AdminServer.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get a single user by ID
  Future<PanelUser> getUser(int userId) async {
    final response = await _client.get('/users/$userId');
    return PanelUser.fromJson(response);
  }

  /// Create a new panel user
  Future<PanelUser> createUser({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String language = 'en',
    bool rootAdmin = false,
  }) async {
    final response = await _client.post('/users', body: {
      'username': username,
      'email': email,
      'first_name': firstName ?? '',
      'last_name': lastName ?? '',
      'language': language,
      'root_admin': rootAdmin,
    });
    return PanelUser.fromJson(response);
  }

  /// Update an existing user
  Future<PanelUser> updateUser(int userId, {
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? language,
    bool? rootAdmin,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (language != null) body['language'] = language;
    if (rootAdmin != null) body['root_admin'] = rootAdmin;

    final response = await _client.patch('/users/$userId', body: body);
    return PanelUser.fromJson(response);
  }

  /// Delete a user from the panel
  Future<void> deleteUser(int userId) async {
    await _client.delete('/users/$userId');
  }
}
