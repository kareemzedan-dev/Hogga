class SubscriptionProgress {
  final int freeLimit;
  final int completed;
  final int remaining;
  final int durationLimit;
  final double completionPercentage;

  SubscriptionProgress({
    required this.freeLimit,
    required this.completed,
    required this.remaining,
    required this.durationLimit,
    required this.completionPercentage,
  });

  factory SubscriptionProgress.fromJson(Map<String, dynamic> json) {
    return SubscriptionProgress(
      freeLimit: int.tryParse(json['free_consultations_limit']?.toString() ?? '0') ?? 0,
      completed: int.tryParse(json['completed_free_consultations']?.toString() ?? '0') ?? 0,
      remaining: int.tryParse(json['remaining_free_consultations']?.toString() ?? '0') ?? 0,
      durationLimit: int.tryParse(json['consultation_duration_limit_minutes']?.toString() ?? '0') ?? 0,
      completionPercentage: double.tryParse(json['completion_percentage']?.toString() ?? '0') ?? 0.0,
    );
  }
}
