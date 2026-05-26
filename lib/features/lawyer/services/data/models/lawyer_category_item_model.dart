import 'package:hogga/features/lawyer/services/domain/entities/lawyer_category_item.dart';

class LawyerCategoryItemModel extends LawyerCategoryItem {
  const LawyerCategoryItemModel({
    required super.id,
    required super.name,
    required super.description,
    super.suggestedPrice,
    super.categoriesChildId,
  });

  factory LawyerCategoryItemModel.fromJson(Map<String, dynamic> json) {
    return LawyerCategoryItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      suggestedPrice: json['suggested_price'] != null
          ? double.tryParse(json['suggested_price'].toString())
          : null,
      categoriesChildId: json['categories_child_id'],
    );
  }
}
