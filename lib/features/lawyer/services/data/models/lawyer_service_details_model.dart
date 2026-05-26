import 'package:hogga/features/lawyer/services/data/models/lawyer_service_model.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service_details.dart';

class LawyerServiceDetailsModel extends LawyerServiceDetails {
  const LawyerServiceDetailsModel({
    required super.service,
    required super.statistics,
    required super.purchases,
  });

  factory LawyerServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return LawyerServiceDetailsModel(
      service: LawyerServiceModel.fromJson(json['service'] ?? {}),
      statistics: LawyerServiceStatisticsModel.fromJson(json['statistics'] ?? {}),
      purchases: json['purchases'] ?? [],
    );
  }
}

class LawyerServiceStatisticsModel extends LawyerServiceStatistics {
  const LawyerServiceStatisticsModel({
    required super.totalPurchases,
    required super.pendingPurchases,
    required super.completedPurchases,
    required super.totalIncome,
  });

  factory LawyerServiceStatisticsModel.fromJson(Map<String, dynamic> json) {
    return LawyerServiceStatisticsModel(
      totalPurchases: json['total_purchases'] ?? 0,
      pendingPurchases: json['pending_purchases'] ?? 0,
      completedPurchases: json['completed_purchases'] ?? 0,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
