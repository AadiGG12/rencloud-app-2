import 'package:http/http.dart' as http;
import '../../models/pterodactyl/file_model.dart';
import 'pterodactyl_client.dart';

class FileService {
  final PterodactylClient _client;
  final String _serverId;

  FileService(this._client, this._serverId);

  Future<List<ServerFile>> listFiles(String directory) async {
    final response = await _client.get('/servers/$_serverId/files/list', query: {'directory': directory});
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => ServerFile.fromJson(e['attributes'] ?? e)).toList();
  }

  Future<String> getFileContents(String path) async {
    final stream = await _client.getStream('/servers/$_serverId/files/contents?file=$path');
    return await stream.stream.bytesToString();
  }

  Future<void> writeFile(String path, String content) async {
    final base = _client.panelUrl.endsWith('/')
        ? _client.panelUrl.substring(0, _client.panelUrl.length - 1)
        : _client.panelUrl;
    final uri = Uri.parse('$base/api/client/servers/$_serverId/files/write?file=$path');
    final response = await http.Client().send(
      http.Request('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer ${_client.apiKey}',
          'Content-Type': 'text/plain',
        })
        ..body = content,
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 300) {
      throw PterodactylException('Write file failed: ${response.statusCode}');
    }
  }

  Future<void> deleteFiles(List<String> paths) async {
    await _client.post('/servers/$_serverId/files/delete', body: {'root': '/', 'files': paths});
  }

  Future<void> renameFile(String from, String to) async {
    await _client.put('/servers/$_serverId/files/rename', body: {'root': '/', 'from': from, 'to': to});
  }

  Future<void> createFolder(String name, String root) async {
    await _client.post('/servers/$_serverId/files/create', body: {'name': name, 'root': root});
  }

  Future<String> getDownloadUrl(String path) async {
    final response = await _client.get('/servers/$_serverId/files/download', query: {'file': path});
    return response['attributes']?['url'] as String? ?? '';
  }

  String getUploadUrl() {
    final base = _client.panelUrl.endsWith('/')
        ? _client.panelUrl.substring(0, _client.panelUrl.length - 1)
        : _client.panelUrl;
    return '$base/api/client/servers/$_serverId/files/upload';
  }

  Map<String, String> get uploadHeaders => {
    'Authorization': 'Bearer ${_client.apiKey}',
    'Accept': 'application/json',
  };
}
