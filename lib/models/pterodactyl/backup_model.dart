class ServerBackup {
  final int id;
  final String uuid;
  final String name;
  final bool isSuccessful;
  final bool isLocked;
  final int? bytes;
  final String? checksumType;
  final String? checksumHash;
  final DateTime createdAt;
  final DateTime? completedAt;

  ServerBackup({
    required this.id,
    required this.uuid,
    required this.name,
    required this.isSuccessful,
    required this.isLocked,
    this.bytes,
    this.checksumType,
    this.checksumHash,
    required this.createdAt,
    this.completedAt,
  });

  factory ServerBackup.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    return ServerBackup(
      id: attrs['id'] as int? ?? 0,
      uuid: attrs['uuid'] as String? ?? '',
      name: attrs['name'] as String? ?? '',
      isSuccessful: attrs['is_successful'] as bool? ?? false,
      isLocked: attrs['is_locked'] as bool? ?? false,
      bytes: attrs['bytes'] as int?,
      checksumType: attrs['checksum_type'] as String?,
      checksumHash: attrs['checksum_hash'] as String?,
      createdAt: DateTime.tryParse(attrs['created_at'] as String? ?? '') ?? DateTime.now(),
      completedAt: attrs['completed_at'] != null ? DateTime.tryParse(attrs['completed_at'] as String) : null,
    );
  }

  String get sizeFormatted {
    if (bytes == null) return 'Unknown';
    if (bytes! < 1024) return '$bytes B';
    if (bytes! < 1024 * 1024) return '${(bytes! / 1024).toStringAsFixed(1)} KB';
    if (bytes! < 1024 * 1024 * 1024) return '${(bytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
