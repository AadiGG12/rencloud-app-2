class ServerSchedule {
  final int id;
  final String name;
  final String cronMinute;
  final String cronHour;
  final String cronDayOfWeek;
  final String cronDayOfMonth;
  final bool isActive;
  final bool isProcessing;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;
  final DateTime createdAt;
  final List<ScheduleTask> tasks;

  ServerSchedule({
    required this.id,
    required this.name,
    required this.cronMinute,
    required this.cronHour,
    required this.cronDayOfWeek,
    required this.cronDayOfMonth,
    required this.isActive,
    required this.isProcessing,
    this.lastRunAt,
    this.nextRunAt,
    required this.createdAt,
    this.tasks = const [],
  });

  factory ServerSchedule.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    final cron = attrs['cron'] as Map<String, dynamic>? ?? {};
    final rel = attrs['relationships'] as Map<String, dynamic>?;
    final tasksData = rel?['tasks']?['data'] as List<dynamic>? ?? [];
    return ServerSchedule(
      id: attrs['id'] as int? ?? 0,
      name: attrs['name'] as String? ?? '',
      cronMinute: cron['minute'] as String? ?? '*',
      cronHour: cron['hour'] as String? ?? '*',
      cronDayOfWeek: cron['day_of_week'] as String? ?? '*',
      cronDayOfMonth: cron['day_of_month'] as String? ?? '*',
      isActive: attrs['is_active'] as bool? ?? true,
      isProcessing: attrs['is_processing'] as bool? ?? false,
      lastRunAt: attrs['last_run_at'] != null ? DateTime.tryParse(attrs['last_run_at'] as String) : null,
      nextRunAt: attrs['next_run_at'] != null ? DateTime.tryParse(attrs['next_run_at'] as String) : null,
      createdAt: DateTime.tryParse(attrs['created_at'] as String? ?? '') ?? DateTime.now(),
      tasks: tasksData.map((e) => ScheduleTask.fromJson(e['attributes'] ?? e)).toList(),
    );
  }

  String get cronExpression => '$cronMinute $cronHour $cronDayOfMonth * $cronDayOfWeek';
}

class ScheduleTask {
  final int id;
  final int sequenceId;
  final String action;
  final String payload;
  final bool isQueued;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ScheduleTask({
    required this.id,
    required this.sequenceId,
    required this.action,
    required this.payload,
    required this.isQueued,
    required this.createdAt,
    this.updatedAt,
  });

  factory ScheduleTask.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? json;
    return ScheduleTask(
      id: attrs['id'] as int? ?? 0,
      sequenceId: attrs['sequence_id'] as int? ?? 1,
      action: attrs['action'] as String? ?? '',
      payload: attrs['payload'] as String? ?? '',
      isQueued: attrs['is_queued'] as bool? ?? false,
      createdAt: DateTime.tryParse(attrs['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: attrs['updated_at'] != null ? DateTime.tryParse(attrs['updated_at'] as String) : null,
    );
  }
}
