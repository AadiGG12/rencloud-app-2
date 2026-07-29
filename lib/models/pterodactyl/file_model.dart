class ServerFile {
  final String name;
  final String path;
  final bool isFile;
  final bool isSymlink;
  final String? mimetype;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;

  ServerFile({
    required this.name,
    required this.path,
    required this.isFile,
    required this.isSymlink,
    this.mimetype,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory ServerFile.fromJson(Map<String, dynamic> json) => ServerFile(
    name: json['name'] as String? ?? '',
    path: json['path'] as String? ?? json['name'] as String? ?? '',
    isFile: json['is_file'] as bool? ?? true,
    isSymlink: json['is_symlink'] as bool? ?? false,
    mimetype: json['mimetype'] as String?,
    size: json['size'] as int? ?? 0,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    modifiedAt: DateTime.tryParse(json['modified_at'] as String? ?? '') ?? DateTime.now(),
  );

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isImage => ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'].any((ext) => name.toLowerCase().endsWith('.$ext'));
  bool get isText => ['txt', 'json', 'yml', 'yaml', 'xml', 'cfg', 'conf', 'log', 'md', 'sh', 'bat', 'env', 'properties', 'ini', 'toml', 'csv', 'js', 'ts', 'dart', 'py', 'java', 'cpp', 'c', 'h', 'html', 'css', 'scss', 'php', 'rb', 'go', 'rs'].any((ext) => name.toLowerCase().endsWith('.$ext'));
}
