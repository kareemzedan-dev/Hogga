import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';

class LawyerServiceModel extends LawyerService {
  const LawyerServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.priceStatus,
    required super.status,
    required super.categoriesItemId,
    required super.categoriesItemName,
    required super.createdAt,
  });

  factory LawyerServiceModel.fromJson(Map<String, dynamic> json) {
    return LawyerServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      priceStatus: json['price_status'] ?? '',
      status: json['status'] ?? '',
      categoriesItemId: json['categories_item_id'] ?? 0,
      categoriesItemName: json['categories_item_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
