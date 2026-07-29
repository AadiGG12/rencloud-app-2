class PanelUser {
  final int id;
  final String? externalId;
  final String uuid;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String language;
  final bool isAdmin;
  final bool hasTwoFactor;
  final DateTime createdAt;
  final DateTime updatedAt;

  PanelUser({
    required this.id,
    this.externalId,
    required this.uuid,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.language,
    required this.isAdmin,
    required this.hasTwoFactor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PanelUser.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    return PanelUser(
      id: attrs['id'] as int? ?? 0,
      externalId: attrs['external_id'] as String?,
      uuid: attrs['uuid'] as String? ?? '',
      username: attrs['username'] as String? ?? '',
      email: attrs['email'] as String? ?? '',
      firstName: attrs['first_name'] as String? ?? '',
      lastName: attrs['last_name'] as String? ?? '',
      language: attrs['language'] as String? ?? 'en',
      isAdmin: attrs['root_admin'] as bool? ?? false,
      hasTwoFactor: attrs['2fa'] as bool? ?? false,
      createdAt: DateTime.tryParse(attrs['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(attrs['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'language': language,
    'root_admin': isAdmin,
  };

  String get fullName => '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName' : username;

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return username[0].toUpperCase();
  }
}
