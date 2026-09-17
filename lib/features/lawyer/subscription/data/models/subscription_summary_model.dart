class SubscriptionSummary {
  final String status;
  final String planName;
  final bool isVisibleToClients;
  final bool isSubscribed;
  final bool isDefaultFree;
  final bool isPackageLinkActive;
  final String? packageLink;
  final String? endDate;
  final int remainingDays;
  final int? remainingConsultations;
  final double? completionPercentage;

  SubscriptionSummary({
    required this.status,
    required this.planName,
    required this.isVisibleToClients,
    this.isSubscribed = false,
    this.isDefaultFree = false,
    this.isPackageLinkActive = false,
    this.packageLink,
    this.endDate,
    this.remainingDays = 0,
    this.remainingConsultations,
    this.completionPercentage,
  });

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) {
    final isSubscribed = json['is_subscribed'] == true;
    final isDefaultFree = json['is_default_free'] == true;

    return SubscriptionSummary(
      status:
          json['status']?.toString() ??
          (isSubscribed || isDefaultFree ? 'active' : 'inactive'),
      planName:
          json['package_name']?.toString() ??
          json['plan_name']?.toString() ??
          '',
      isVisibleToClients:
          json['is_visible_to_clients'] ?? (isSubscribed || isDefaultFree),
      isSubscribed: isSubscribed,
      isDefaultFree: isDefaultFree,
      isPackageLinkActive: _readBool(json['is_active']),
      packageLink: _cleanUrl(json['link']?.toString()),
      endDate: json['end_date']?.toString(),
      remainingDays:
          int.tryParse(json['remaining_days']?.toString() ?? '') ?? 0,
      remainingConsultations: json['remaining_consultations'],
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
    );
  }

  bool get isActive => status == 'active' || isSubscribed || isDefaultFree;
  bool get isExpiringSoon =>
      status == 'expiring_soon' ||
      (isSubscribed && remainingDays > 0 && remainingDays <= 7);
  bool get canOpenPackages =>
      isPackageLinkActive && packageLink != null && packageLink!.isNotEmpty;

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _cleanUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return null;
    }
    final markdownMatch = RegExp(r'\]\((.*?)\)').firstMatch(trimmed);
    final url = markdownMatch?.group(1) ?? trimmed;
    return url.trim().isEmpty ? null : url.trim();
  }
}
