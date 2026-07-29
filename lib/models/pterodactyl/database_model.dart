class ServerDatabase {
  final int id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String? password;
  final int maxConnections;
  final DateTime createdAt;

  ServerDatabase({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    this.password,
    required this.maxConnections,
    required this.createdAt,
  });

  factory ServerDatabase.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    return ServerDatabase(
      id: attrs['id'] as int? ?? 0,
      name: attrs['name'] as String? ?? '',
      host: (attrs['host'] as Map<String, dynamic>?)?['address'] as String? ?? '',
      port: (attrs['host'] as Map<String, dynamic>?)?['port'] as int? ?? 3306,
      username: attrs['username'] as String? ?? '',
      password: attrs['password'] as String?,
      maxConnections: attrs['max_connections'] as int? ?? 0,
      createdAt: DateTime.tryParse(attrs['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
