class PterodactylServer {
  final String id;
  final String uuid;
  final String name;
  final String node;
  final String sftpDetails;
  final String description;
  final bool isSuspended;
  final bool isInstalling;
  final bool isTransferring;
  final ServerLimits limits;
  final ServerFeatureLimits featureLimits;
  final ServerRelationships? relationships;

  PterodactylServer({
    required this.id,
    required this.uuid,
    required this.name,
    required this.node,
    required this.sftpDetails,
    required this.description,
    required this.isSuspended,
    required this.isInstalling,
    required this.isTransferring,
    required this.limits,
    required this.featureLimits,
    this.relationships,
  });

  factory PterodactylServer.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] as Map<String, dynamic>? ?? json;
    return PterodactylServer(
      id: attrs['identifier'] as String? ?? '',
      uuid: attrs['uuid'] as String? ?? '',
      name: attrs['name'] as String? ?? '',
      node: attrs['node'] as String? ?? '',
      sftpDetails: attrs['sftp_details'] as String? ?? '',
      description: attrs['description'] as String? ?? '',
      isSuspended: attrs['is_suspended'] as bool? ?? attrs['suspended'] as bool? ?? false,
      isInstalling: attrs['is_installing'] as bool? ?? attrs['installing'] as bool? ?? false,
      isTransferring: attrs['is_transferring'] as bool? ?? false,
      limits: ServerLimits.fromJson(attrs['limits'] as Map<String, dynamic>? ?? {}),
      featureLimits: ServerFeatureLimits.fromJson(attrs['feature_limits'] as Map<String, dynamic>? ?? {}),
      relationships: attrs['relationships'] != null
          ? ServerRelationships.fromJson(attrs['relationships'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'identifier': id,
    'uuid': uuid,
    'name': name,
    'node': node,
    'description': description,
    'is_suspended': isSuspended,
    'is_installing': isInstalling,
  };
}

class ServerLimits {
  final int memory; // MB
  final int swap; // MB
  final int disk; // MB
  final int io;
  final int cpu;

  ServerLimits({
    required this.memory,
    required this.swap,
    required this.disk,
    required this.io,
    required this.cpu,
  });

  factory ServerLimits.fromJson(Map<String, dynamic> json) => ServerLimits(
    memory: json['memory'] as int? ?? 0,
    swap: json['swap'] as int? ?? 0,
    disk: json['disk'] as int? ?? 0,
    io: json['io'] as int? ?? 500,
    cpu: json['cpu'] as int? ?? 0,
  );
}

class ServerFeatureLimits {
  final int databases;
  final int allocations;
  final int backups;

  ServerFeatureLimits({
    required this.databases,
    required this.allocations,
    required this.backups,
  });

  factory ServerFeatureLimits.fromJson(Map<String, dynamic> json) => ServerFeatureLimits(
    databases: json['databases'] as int? ?? 0,
    allocations: json['allocations'] as int? ?? 0,
    backups: json['backups'] as int? ?? 0,
  );
}

class ServerRelationships {
  final List<Allocation>? allocations;
  final List<ServerVariable>? variables;

  ServerRelationships({this.allocations, this.variables});

  factory ServerRelationships.fromJson(Map<String, dynamic> json) => ServerRelationships(
    allocations: json['allocations'] != null
        ? (json['allocations']['data'] as List? ?? [])
            .map((e) => Allocation.fromJson(e['attributes'] ?? e))
            .toList()
        : null,
    variables: json['variables'] != null
        ? (json['variables']['data'] as List? ?? [])
            .map((e) => ServerVariable.fromJson(e['attributes'] ?? e))
            .toList()
        : null,
  );
}

class Allocation {
  final int id;
  final String ip;
  final String ipAlias;
  final int port;
  final bool isPrimary;

  Allocation({
    required this.id,
    required this.ip,
    required this.ipAlias,
    required this.port,
    required this.isPrimary,
  });

  factory Allocation.fromJson(Map<String, dynamic> json) => Allocation(
    id: json['id'] as int? ?? 0,
    ip: json['ip'] as String? ?? '',
    ipAlias: json['ip_alias'] as String? ?? '',
    port: json['port'] as int? ?? 0,
    isPrimary: json['is_primary'] as bool? ?? false,
  );

  String get label => '$ip:$port${isPrimary ? ' (Primary)' : ''}';
}

class ServerVariable {
  final String name;
  final String value;
  final String defaultValue;
  final String description;
  final bool isEditable;
  final List<String>? rules;

  ServerVariable({
    required this.name,
    required this.value,
    required this.defaultValue,
    required this.description,
    required this.isEditable,
    this.rules,
  });

  factory ServerVariable.fromJson(Map<String, dynamic> json) => ServerVariable(
    name: json['name'] as String? ?? '',
    value: json['value'] as String? ?? '',
    defaultValue: json['default_value'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isEditable: json['is_editable'] as bool? ?? false,
    rules: json['rules'] != null ? List<String>.from(json['rules'] as List) : null,
  );
}

class ServerResources {
  final double currentMemory;
  final double memoryLimit;
  final double currentCpu;
  final double currentDisk;
  final double diskLimit;
  final int currentTx;
  final int currentRx;
  final String uptime;

  ServerResources({
    required this.currentMemory,
    required this.memoryLimit,
    required this.currentCpu,
    required this.currentDisk,
    required this.diskLimit,
    required this.currentTx,
    required this.currentRx,
    required this.uptime,
  });

  factory ServerResources.fromJson(Map<String, dynamic> json) {
    final res = json['attributes']?['resources'] ?? json['resources'] ?? json;
    return ServerResources(
      currentMemory: (res['memory_bytes'] as num? ?? 0) / (1024 * 1024),
      memoryLimit: (res['memory_limit_bytes'] as num? ?? 0) / (1024 * 1024),
      currentCpu: (res['cpu_absolute'] as num? ?? 0).toDouble(),
      currentDisk: (res['disk_bytes'] as num? ?? 0) / (1024 * 1024),
      diskLimit: (res['disk_limit_bytes'] as num? ?? 0) / (1024 * 1024),
      currentTx: (res['tx_bytes'] as num? ?? 0).toInt(),
      currentRx: (res['rx_bytes'] as num? ?? 0).toInt(),
      uptime: res['uptime'] as String? ?? '0',
    );
  }

  double get memoryPercent => memoryLimit > 0 ? (currentMemory / memoryLimit * 100).clamp(0, 100) : 0;
  double get diskPercent => diskLimit > 0 ? (currentDisk / diskLimit * 100).clamp(0, 100) : 0;
  double get cpuPercent => currentCpu.clamp(0, 100);
}

class WebSocketCredentials {
  final String token;
  final String socket;

  WebSocketCredentials({required this.token, required this.socket});

  factory WebSocketCredentials.fromJson(Map<String, dynamic> json) => WebSocketCredentials(
    token: json['data']?['token'] as String? ?? json['token'] as String? ?? '',
    socket: json['data']?['socket'] as String? ?? json['socket'] as String? ?? '',
  );
}
