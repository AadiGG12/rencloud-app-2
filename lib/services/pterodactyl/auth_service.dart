import '../../models/pterodactyl/server_model.dart';
import 'pterodactyl_client.dart';
import '../backend/server_service.dart';

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

  @Deprecated('Use BackendServerService for secure backend-proxied operations')
  /// Fetch the authenticated user's account info (checks admin status).
  static Future<UserAccount> fetchAccount(String panelUrl, String apiKey) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/account');
    return UserAccount.fromJson(response);
  }

  /// Fetch servers through the secure backend proxy.
  /// NO Pterodactyl API keys are used on the client.
  static Future<List<PterodactylServer>> fetchServers(
    String panelUrl,
    String apiKey, {
    int? ownerId,
    String? userEmail,
  }) async {
    // SECURITY: All server fetching is done through the backend proxy.
    // The backend holds the PTLA key server-side.
    // This method is kept for API compatibility but delegates to BackendServerService.
    try {
      return await BackendServerService.listServers();
    } catch (e) {
      throw PterodactylException('Failed to fetch servers: $e');
    }
  }

  @Deprecated('Use BackendServerService for secure backend-proxied operations')
  static Future<PterodactylServer> fetchServerDetail(String panelUrl, String apiKey, String serverId) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/servers/$serverId');
    return PterodactylServer.fromJson(response);
  }

  @Deprecated('Use BackendServerService.getResources() instead')
  static Future<ServerResources> fetchResources(String panelUrl, String apiKey, String serverId) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/servers/$serverId/resources');
    return ServerResources.fromJson(response);
  }

  @Deprecated('Use BackendServerService.sendPowerSignal() instead')
  static Future<void> sendPowerAction(String panelUrl, String apiKey, String serverId, String action) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    await client.post('/servers/$serverId/power', body: {'signal': action});
  }

  @Deprecated('Use BackendServerService.sendCommand() instead')
  static Future<void> sendCommand(String panelUrl, String apiKey, String serverId, String command) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    await client.post('/servers/$serverId/command', body: {'command': command});
  }

  @Deprecated('Use BackendServerService.getWebSocketCredentials() instead')
  static Future<WebSocketCredentials> getWebSocketCredentials(String panelUrl, String apiKey, String serverId) async {
    final client = PterodactylClient(panelUrl: panelUrl, apiKey: apiKey);
    final response = await client.get('/servers/$serverId/websocket');
    return WebSocketCredentials.fromJson(response);
  }
}
