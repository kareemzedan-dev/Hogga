import 'package_model.dart';
import 'subscription_progress_model.dart';

class SubscriptionModel {
  final int id;
  final PackageModel packageSnapshot;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool isVisibleToClients;
  final SubscriptionProgress progress;

  SubscriptionModel({
    required this.id,
    required this.packageSnapshot,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isVisibleToClients,
    required this.progress,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['subscription_id'] ?? 0,
      packageSnapshot: PackageModel.fromJson(json['package_snapshot'] ?? {}),
      status: json['status'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      isVisibleToClients: json['is_visible_to_clients'] ?? false,
      progress: SubscriptionProgress.fromJson(json['progress'] ?? {}),
    );
  }

  bool get isActive => status == 'active';
  bool get isExpiringSoon {
    if (!isActive) return false;
    return endDate.difference(DateTime.now()).inDays <= 7;
  }
}
