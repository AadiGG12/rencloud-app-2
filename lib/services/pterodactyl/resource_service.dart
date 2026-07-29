import '../../models/pterodactyl/server_model.dart';
import '../../models/pterodactyl/database_model.dart';
import '../../models/pterodactyl/schedule_model.dart';
import '../../models/pterodactyl/backup_model.dart';
import 'pterodactyl_client.dart';

class DatabaseService {
  final PterodactylClient _client;
  final String _serverId;
  DatabaseService(this._client, this._serverId);

  Future<List<ServerDatabase>> list() async {
    final res = await _client.get('/servers/$_serverId/databases');
    return (res['data'] as List?)?.map((e) => ServerDatabase.fromJson(e)).toList() ?? [];
  }

  Future<ServerDatabase> create(String name, {String? hostId}) async {
    final res = await _client.post('/servers/$_serverId/databases', body: {'database': name, 'remote': '%', 'host': hostId ?? 0});
    return ServerDatabase.fromJson(res);
  }

  Future<void> rotatePassword(int dbId) async {
    await _client.post('/servers/$_serverId/databases/$dbId/rotate-password');
  }

  Future<void> delete(int dbId) async {
    await _client.delete('/servers/$_serverId/databases/$dbId');
  }
}

class ScheduleService {
  final PterodactylClient _client;
  final String _serverId;
  ScheduleService(this._client, this._serverId);

  Future<List<ServerSchedule>> list() async {
    final res = await _client.get('/servers/$_serverId/schedules');
    return (res['data'] as List?)?.map((e) => ServerSchedule.fromJson(e)).toList() ?? [];
  }

  Future<ServerSchedule> create(String name, String minute, String hour, String dayOfMonth, String dayOfWeek) async {
    final res = await _client.post('/servers/$_serverId/schedules', body: {
      'name': name,
      'cron': {'minute': minute, 'hour': hour, 'day_of_month': dayOfMonth, 'day_of_week': dayOfWeek},
      'is_active': true,
    });
    return ServerSchedule.fromJson(res);
  }

  Future<void> update(int scheduleId, {bool? isActive, String? name}) async {
    final body = <String, dynamic>{};
    if (isActive != null) body['is_active'] = isActive;
    if (name != null) body['name'] = name;
    await _client.post('/servers/$_serverId/schedules/$scheduleId', body: body);
  }

  Future<void> execute(int scheduleId) async {
    await _client.post('/servers/$_serverId/schedules/$scheduleId/execute');
  }

  Future<void> delete(int scheduleId) async {
    await _client.delete('/servers/$_serverId/schedules/$scheduleId');
  }
}

class BackupService {
  final PterodactylClient _client;
  final String _serverId;
  BackupService(this._client, this._serverId);

  Future<List<ServerBackup>> list() async {
    final res = await _client.get('/servers/$_serverId/backups');
    return (res['data'] as List?)?.map((e) => ServerBackup.fromJson(e)).toList() ?? [];
  }

  Future<ServerBackup> create({bool isLocked = false}) async {
    final res = await _client.post('/servers/$_serverId/backups', body: {'is_locked': isLocked});
    return ServerBackup.fromJson(res);
  }

  Future<String> getDownloadUrl(int backupId) async {
    final res = await _client.get('/servers/$_serverId/backups/$backupId/download');
    return res['attributes']?['url'] as String? ?? '';
  }

  Future<void> delete(int backupId) async {
    await _client.delete('/servers/$_serverId/backups/$backupId');
  }
}

class NetworkService {
  final PterodactylClient _client;
  final String _serverId;
  NetworkService(this._client, this._serverId);

  Future<List<Allocation>> list() async {
    final res = await _client.get('/servers/$_serverId/network/allocations');
    return (res['data'] as List?)?.map((e) => Allocation.fromJson(e['attributes'] ?? e)).toList() ?? [];
  }

  Future<void> setPrimary(int allocationId) async {
    await _client.post('/servers/$_serverId/network/allocations/$allocationId/primary');
  }
}

class SubuserService {
  final PterodactylClient _client;
  final String _serverId;
  SubuserService(this._client, this._serverId);

  Future<List<Subuser>> list() async {
    final res = await _client.get('/servers/$_serverId/users');
    return (res['data'] as List?)?.map((e) => Subuser.fromJson(e['attributes'] ?? e)).toList() ?? [];
  }

  Future<void> create(String email, List<String> permissions) async {
    await _client.post('/servers/$_serverId/users', body: {'email': email, 'permissions': permissions});
  }

  Future<void> update(int userId, List<String> permissions) async {
    await _client.post('/servers/$_serverId/users/$userId', body: {'permissions': permissions});
  }

  Future<void> delete(int userId) async {
    await _client.delete('/servers/$_serverId/users/$userId');
  }
}

class Subuser {
  final int id;
  final String email;
  final String image;
  final String username;
  final DateTime createdAt;
  final List<String> permissions;

  Subuser({
    required this.id,
    required this.email,
    required this.image,
    required this.username,
    required this.createdAt,
    this.permissions = const [],
  });

  factory Subuser.fromJson(Map<String, dynamic> json) => Subuser(
    id: json['id'] as int? ?? 0,
    email: json['email'] as String? ?? '',
    image: json['image'] as String? ?? '',
    username: json['username'] as String? ?? '',
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    permissions: json['permissions'] != null ? List<String>.from(json['permissions'] as List) : [],
  );
}
