import 'dart:convert';
import 'package:http/http.dart' as http;

class PterodactylClient {
  final String panelUrl;
  final String apiKey;
  final String apiBase; // e.g., '/api/client' for Client API or '/api/application' for Application API

  PterodactylClient({required this.panelUrl, required this.apiKey, this.apiBase = '/api/client'});

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = panelUrl.endsWith('/') ? panelUrl.substring(0, panelUrl.length - 1) : panelUrl;
    return Uri.parse('$base$apiBase$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final response = await http.get(_uri(path, query), headers: _headers).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw PterodactylException('GET $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers,
      body: body != null ? json.encode(body) : null,
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw PterodactylException('POST $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(_uri(path), headers: _headers).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw PterodactylException('DELETE $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      _uri(path),
      headers: _headers,
      body: body != null ? json.encode(body) : null,
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw PterodactylException('PUT $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    final request = http.Request('PATCH', _uri(path));
    request.headers.addAll(_headers);
    if (body != null) request.body = json.encode(body);
    final streamed = await http.Client().send(request).timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw PterodactylException('PATCH $path failed: ${response.statusCode} ${response.body}');
  }

  Future<http.StreamedResponse> getStream(String path) async {
    final request = http.Request('GET', _uri(path));
    request.headers.addAll(_headers);
    return http.Client().send(request).timeout(const Duration(seconds: 30));
  }
}

class PterodactylException implements Exception {
  final String message;
  PterodactylException(this.message);
  @override
  String toString() => 'PterodactylException: $message';
}
