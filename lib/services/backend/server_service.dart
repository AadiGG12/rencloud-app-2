/// Backend Server Service
///
/// All Pterodactyl operations are proxied through the backend.
/// The backend securely holds the PTLA key - it's NEVER in the Flutter app.
///
/// Endpoints called: /servers/* on the backend API.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/api_client.dart';
import '../../models/pterodactyl/server_model.dart';

class BackendServerService {
  /// List all servers for the authenticated user
  static Future<List<PterodactylServer>> listServers() async {
    try {
      final response = await ApiClient.dio.get('/servers');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => PterodactylServer.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[BackendServer] List servers failed: $e');
      return [];
    }
  }

  /// Get server details
  static Future<PterodactylServer?> getServer(String identifier) async {
    try {
      final response = await ApiClient.dio.get('/servers/$identifier');
      return PterodactylServer.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[BackendServer] Get server failed: $e');
      return null;
    }
  }

  /// Send power signal to server
  static Future<bool> sendPowerSignal(
      String identifier, String signal) async {
    try {
      final response = await ApiClient.dio.post(
        '/servers/$identifier/power',
        data: {'signal': signal},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[BackendServer] Power signal failed: $e');
      return false;
    }
  }

  /// Get server resources (CPU, RAM, Disk usage)
  static Future<ServerResources?> getResources(String serverId) async {
    try {
      final response = await ApiClient.dio.get('/servers/$serverId/resources');
      return ServerResources.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[BackendServer] Get resources failed: $e');
      return null;
    }
  }

  /// Get WebSocket credentials for live console
  static Future<Map<String, dynamic>> getWebSocketCredentials(
      String identifier) async {
    try {
      final response =
          await ApiClient.dio.get('/servers/$identifier/websocket');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[BackendServer] WebSocket credentials failed: $e');
      return {
        'token': '',
        'socket':
            'wss://panel.rencloud.online/api/client/servers/$identifier/ws',
      };
    }
  }

  /// Send console command
  static Future<bool> sendCommand(String identifier, String command) async {
    try {
      await ApiClient.dio.post(
        '/servers/$identifier/command',
        data: {'command': command},
      );
      return true;
    } catch (e) {
      debugPrint('[BackendServer] Send command failed: $e');
      return false;
    }
  }

  // ─── File Operations ─────────────────────────────────────────────

  /// List files in a directory
  static Future<List<Map<String, dynamic>>> listFiles(
      String identifier, String directory) async {
    try {
      final response = await ApiClient.dio.get(
        '/servers/$identifier/files/list',
        queryParameters: {'directory': directory},
      );
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[BackendServer] List files failed: $e');
      return [];
    }
  }

  /// Read file contents
  static Future<String> getFileContents(
      String identifier, String filePath) async {
    try {
      final response = await ApiClient.dio.get(
        '/servers/$identifier/files/contents',
        queryParameters: {'file_path': filePath},
      );
      return response.data['content']?.toString() ?? '';
    } catch (e) {
      debugPrint('[BackendServer] Get file contents failed: $e');
      return '';
    }
  }

  /// Write file contents
  static Future<bool> writeFileContents(
      String identifier, String filePath, String content) async {
    try {
      final response = await ApiClient.dio.post(
        '/servers/$identifier/files/write',
        data: {'file_path': filePath, 'content': content},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[BackendServer] Write file failed: $e');
      return false;
    }
  }

  /// Delete file(s)
  static Future<bool> deleteFiles(
      String identifier, String root, List<String> files) async {
    try {
      final response = await ApiClient.dio.post(
        '/servers/$identifier/files/delete',
        data: {'root': root, 'files': files},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[BackendServer] Delete files failed: $e');
      return false;
    }
  }

  // ─── Backup Operations ───────────────────────────────────────────

  /// List backups
  static Future<List<Map<String, dynamic>>> listBackups(
      String identifier) async {
    try {
      final response = await ApiClient.dio.get('/servers/$identifier/backups');
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[BackendServer] List backups failed: $e');
      return [];
    }
  }

  /// Create a backup
  static Future<Map<String, dynamic>> createBackup(String identifier) async {
    try {
      final response =
          await ApiClient.dio.post('/servers/$identifier/backups');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      debugPrint('[BackendServer] Create backup failed: $e');
      return {};
    }
  }

  /// Delete a backup
  static Future<bool> deleteBackup(
      String identifier, String backupId) async {
    try {
      await ApiClient.dio.delete('/servers/$identifier/backups/$backupId');
      return true;
    } catch (e) {
      debugPrint('[BackendServer] Delete backup failed: $e');
      return false;
    }
  }

  // ─── Database Operations ─────────────────────────────────────────

  /// List databases for a server
  static Future<List<Map<String, dynamic>>> listDatabases(
      String identifier) async {
    try {
      final response =
          await ApiClient.dio.get('/servers/$identifier/databases');
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[BackendServer] List databases failed: $e');
      return [];
    }
  }

  /// Create a database
  static Future<bool> createDatabase(
      String identifier, String databaseName, String remote) async {
    try {
      final response = await ApiClient.dio.post(
        '/servers/$identifier/databases',
        data: {'database': databaseName, 'remote': remote},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[BackendServer] Create database failed: $e');
      return false;
    }
  }

  /// Delete a database
  static Future<bool> deleteDatabase(
      String identifier, String databaseId) async {
    try {
      await ApiClient.dio.delete(
          '/servers/$identifier/databases/$databaseId');
      return true;
    } catch (e) {
      debugPrint('[BackendServer] Delete database failed: $e');
      return false;
    }
  }

  // ─── Admin Operations ────────────────────────────────────────────

  /// List all users (admin only)
  static Future<List<Map<String, dynamic>>> listUsers() async {
    try {
      final response = await ApiClient.dio.get('/admin/users');
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[BackendServer] List users failed: $e');
      return [];
    }
  }

  /// List all servers (admin only)
  static Future<List<Map<String, dynamic>>> listAllServers() async {
    try {
      final response = await ApiClient.dio.get('/admin/servers');
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[BackendServer] List all servers failed: $e');
      return [];
    }
  }

  /// Suspend a server (admin only)
  static Future<bool> suspendServer(int serverId) async {
    try {
      await ApiClient.dio.post('/admin/servers/$serverId/suspend');
      return true;
    } catch (e) {
      debugPrint('[BackendServer] Suspend server failed: $e');
      return false;
    }
  }

  /// Unsuspend a server (admin only)
  static Future<bool> unsuspendServer(int serverId) async {
    try {
      await ApiClient.dio.post('/admin/servers/$serverId/unsuspend');
      return true;
    } catch (e) {
      debugPrint('[BackendServer] Unsuspend server failed: $e');
      return false;
    }
  }
}
