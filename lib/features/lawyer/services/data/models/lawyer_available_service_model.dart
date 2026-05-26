import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';

class LawyerAvailableServiceModel extends LawyerAvailableService {
  const LawyerAvailableServiceModel({
    required super.id,
    required super.title,
    super.minPrice,
    super.maxPrice,
    required super.categoryItemName,
    required super.proposalsCount,
    required super.createdAt,
  });

  factory LawyerAvailableServiceModel.fromJson(Map<String, dynamic> json) {
    return LawyerAvailableServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      minPrice: json['min_price']?.toString(),
      maxPrice: json['max_price']?.toString(),
      categoryItemName: json['category_item_name'] ?? '',
      proposalsCount: json['proposals_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
