import 'dart:convert';

/// Native RenCloud User Profile Model
class RenCloudUser {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'client' or 'admin'
  final String? avatarUrl;
  final DateTime createdAt;

  RenCloudUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'client',
    this.avatarUrl,
    required this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory RenCloudUser.fromJson(Map<String, dynamic> json) {
    return RenCloudUser(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['name'] ?? json['username'] ?? 'RenCloud User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String encode() => jsonEncode(toJson());

  factory RenCloudUser.decode(String rawJson) {
    return RenCloudUser.fromJson(jsonDecode(rawJson));
  }
}
