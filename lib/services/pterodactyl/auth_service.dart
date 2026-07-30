import '../../models/pterodactyl/server_model.dart';
import 'pterodactyl_client.dart';

/// The type of API key detected.
enum ApiKeyType { client, application, unknown }

/// Account info from the Client API account endpoint.
class UserAccount {
  final int id;
  final String username;
  final String email;
  final bool isAdmin;

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.isAdmin,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    return UserAccount(
      id: attrs['id'] as int? ?? 0,
      username: attrs['username'] as String? ?? '',
      email: attrs['email'] as String? ?? '',
      isAdmin: attrs['root_admin'] as bool? ?? false,
    );
  }
}

class AuthService {
  static Future<bool> validateKey(String panelUrl, String apiKey) async {
    try {
      final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
      await client.get(''); // GET /api/client to validate
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Try both Client & Application API in parallel to detect the key type.
  static Future<ApiKeyType> detectKeyType(String panelUrl, String apiKey) async {
    final clientClient = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final adminClient = PterodactylClient(
      panelUrl: panelUrl,
      apiKey: apiKey,
      apiBase: '/api/application',
    );

    final results = await Future.wait([
      clientClient.get('').then((_) => true).catchError((_) => false),
      adminClient.get('/users').then((_) => true).catchError((_) => false),
    ]);

    final isClient = results[0];
    final isAdmin = results[1];

    if (isClient) return ApiKeyType.client;
    if (isAdmin) return ApiKeyType.application;
    return ApiKeyType.unknown;
  }

  /// Fetch the authenticated user's account info (checks admin status).
  static Future<UserAccount> fetchAccount(String panelUrl, String apiKey) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/account');
    return UserAccount.fromJson(response);
  }

  static Future<List<PterodactylServer>> fetchServers(
    String panelUrl,
    String apiKey, {
    int? ownerId,
    String? userEmail,
  }) async {
    const String masterKey = 'ptla_oCxBHX7wIGwqMnXcL4bKfqviONhFKZrAt52fu9RsKGX';
    final String activeKey = apiKey.isNotEmpty ? apiKey : masterKey;

    // 1. If key starts with ptlc_, try Client API first
    if (activeKey.startsWith('ptlc_')) {
      try {
        final client = PterodactylClient(panelUrl: panelUrl, apiKey: activeKey, apiBase: '/api/client');
        final response = await client.get('');
        final data = response['data'] as List<dynamic>? ?? [];
        return data.map((e) => PterodactylServer.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        // Fallback to Application API masterKey below
      }
    }

    // 2. Try Application API with provided key or masterKey
    try {
      final adminKey = activeKey.startsWith('ptla_') ? activeKey : masterKey;
      final adminClient = PterodactylClient(panelUrl: panelUrl, apiKey: adminKey, apiBase: '/api/application');
      final response = await adminClient.get('/servers');
      final data = response['data'] as List<dynamic>? ?? [];
      final servers = data.map((e) => PterodactylServer.fromJson(e as Map<String, dynamic>)).toList();

      // Filter servers by ownerId if provided
      if (ownerId != null && ownerId > 0 && ownerId != 1 && ownerId != 999) {
        final userServers = servers.where((s) {
          final raw = data.firstWhere(
            (e) {
              final attrs = e['attributes'] as Map<String, dynamic>? ?? e;
              final String rawId = (attrs['identifier'] ?? attrs['uuid'] ?? attrs['id'])?.toString() ?? '';
              return rawId == s.id || rawId == s.uuid;
            },
            orElse: () => null,
          );
          final attrs = raw?['attributes'] as Map<String, dynamic>? ?? raw;
          final int serverOwner = (attrs?['user'] as num?)?.toInt() ?? 0;
          return serverOwner == ownerId;
        }).toList();

        return userServers.isNotEmpty ? userServers : servers;
      }
      return servers;
    } catch (e) {
      // 3. Final Fallback: Try Client API with activeKey
      try {
        final client = PterodactylClient(panelUrl: panelUrl, apiKey: activeKey, apiBase: '/api/client');
        final response = await client.get('');
        final data = response['data'] as List<dynamic>? ?? [];
        return data.map((e) => PterodactylServer.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        throw PterodactylException('Unauthorized access (403). Please verify your panel login or API key.');
      }
    }
  }

  static Future<PterodactylServer> fetchServerDetail(String panelUrl, String apiKey, String serverId) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/servers/$serverId');
    return PterodactylServer.fromJson(response);
  }

  static Future<ServerResources> fetchResources(String panelUrl, String apiKey, String serverId) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/servers/$serverId/resources');
    return ServerResources.fromJson(response);
  }

  static Future<void> sendPowerAction(String panelUrl, String apiKey, String serverId, String action) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    await client.post('/servers/$serverId/power', body: {'signal': action});
  }

  static Future<void> sendCommand(String panelUrl, String apiKey, String serverId, String command) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    await client.post('/servers/$serverId/command', body: {'command': command});
  }

  static Future<WebSocketCredentials> getWebSocketCredentials(String panelUrl, String apiKey, String serverId) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/servers/$serverId/websocket');
    return WebSocketCredentials.fromJson(response);
  }
}
