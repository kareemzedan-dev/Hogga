class PackageModel {
  final int id;
  final String name;
  final String subtitle;
  final double price;
  final String currency;
  final int durationDays;
  final bool isDefault;
  final PackageEntitlements entitlements;

  PackageModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.isDefault,
    required this.entitlements,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      isDefault: json['is_default'] ?? false,
      entitlements: PackageEntitlements.fromJson(json['entitlements'] ?? {}),
    );
  }
}

class PackageEntitlements {
  final int freeConsultationsLimit;
  final int consultationDurationLimitMinutes;
  final int visibilityRank;
  final int leadPriority;

  PackageEntitlements({
    required this.freeConsultationsLimit,
    required this.consultationDurationLimitMinutes,
    required this.visibilityRank,
    required this.leadPriority,
  });

  factory PackageEntitlements.fromJson(Map<String, dynamic> json) {
    return PackageEntitlements(
      freeConsultationsLimit: int.tryParse(json['free_consultations_limit']?.toString() ?? '0') ?? 0,
      consultationDurationLimitMinutes: int.tryParse(json['consultation_duration_limit_minutes']?.toString() ?? '0') ?? 0,
      visibilityRank: int.tryParse(json['visibility_rank']?.toString() ?? '0') ?? 0,
      leadPriority: int.tryParse(json['lead_priority']?.toString() ?? '0') ?? 0,
    );
  }
}
