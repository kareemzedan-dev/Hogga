class LawyerTasksResponseModel {
  final LawyerTaskStatsModel stats;
  final List<LawyerTaskModel> tasks;

  LawyerTasksResponseModel({
    required this.stats,
    required this.tasks,
  });

  factory LawyerTasksResponseModel.fromJson(Map<String, dynamic> json) {
    return LawyerTasksResponseModel(
      stats: LawyerTaskStatsModel.fromJson(json['stats'] ?? {}),
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((e) => LawyerTaskModel.fromJson(e))
          .toList(),
    );
  }
}

class LawyerTaskStatsModel {
  final int total;
  final int completed;
  final int pending;

  LawyerTaskStatsModel({
    required this.total,
    required this.completed,
    required this.pending,
  });

  factory LawyerTaskStatsModel.fromJson(Map<String, dynamic> json) {
    return LawyerTaskStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
    );
  }
}

class LawyerTaskModel {
  final int id;
  final String title;
  final String priority;
  final String priorityAr;
  final String dueDate;
  final String dueDateRaw;
  final String status;
  final bool isNotified;

  LawyerTaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.priorityAr,
    required this.dueDate,
    required this.dueDateRaw,
    required this.status,
    required this.isNotified,
  });

  factory LawyerTaskModel.fromJson(Map<String, dynamic> json) {
    dynamic notifyVal = json['is_notified'];
    bool notify = false;
    if (notifyVal is bool) {
      notify = notifyVal;
    } else if (notifyVal is num) {
      notify = notifyVal == 1;
    }

    return LawyerTaskModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      priorityAr: json['priority_ar']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      dueDateRaw: json['due_date_raw']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      isNotified: notify,
    );
  }
}
