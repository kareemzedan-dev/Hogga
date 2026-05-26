class SubscriptionSummary {
  final String status;
  final String planName;
  final bool isVisibleToClients;
  final int? remainingConsultations;
  final double? completionPercentage;

  SubscriptionSummary({
    required this.status,
    required this.planName,
    required this.isVisibleToClients,
    this.remainingConsultations,
    this.completionPercentage,
  });

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return SubscriptionSummary(
      status: json['status'] ?? '',
      planName: json['plan_name'] ?? '',
      isVisibleToClients: json['is_visible_to_clients'] ?? false,
      remainingConsultations: json['remaining_consultations'],
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
    );
  }
  
  bool get isActive => status == 'active';
  bool get isExpiringSoon => status == 'expiring_soon';
}
