import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';

class AvailableServiceDetailsModel extends AvailableServiceDetails {
  const AvailableServiceDetailsModel({
    required super.id,
    required super.title,
    super.description,
    super.minPrice,
    super.maxPrice,
    super.executionDate,
    required super.categoryItemName,
    required super.user,
    required super.proposalsCount,
    required super.documents,
    required super.recentProposals,
  });

  factory AvailableServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return AvailableServiceDetailsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      minPrice: json['min_price']?.toString(),
      maxPrice: json['max_price']?.toString(),
      executionDate: json['execution_date'],
      categoryItemName: json['category_item_name'] ?? '',
      user: AvailableServiceUserModel.fromJson(json['user'] ?? {}),
      proposalsCount: json['proposals_count'] ?? 0,
      documents: json['documents'] ?? [],
      recentProposals: json['recent_proposals'] ?? [],
    );
  }
}

class AvailableServiceUserModel extends AvailableServiceUser {
  const AvailableServiceUserModel({required super.name, super.photo});

  factory AvailableServiceUserModel.fromJson(Map<String, dynamic> json) {
    return AvailableServiceUserModel(
      name: json['name'] ?? '',
      photo: json['photo'],
    );
  }
}
