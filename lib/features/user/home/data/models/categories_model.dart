import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? description;
  final List<SubCategory>? subCategories;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      subCategories: (json['categories_sub'] as List?)
          ?.map((e) => SubCategory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories_sub': subCategories?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, description, subCategories];
}

class SubCategory extends Equatable {
  final int? id;
  final int? categoryId;
  final String name;        // fallback plain name (from home API)
  final String? nameAr;    // from child-categories API
  final String? nameEn;    // from child-categories API
  final String? description;
  final String? descriptionAr;
  final String? descriptionEn;
  final int? sortOrder;
  final bool? isActive;
  final String? price;
  final String? serviceType;

  const SubCategory({
    this.id,
    this.categoryId,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.description,
    this.descriptionAr,
    this.descriptionEn,
    this.sortOrder,
    this.isActive,
    this.price,
    this.serviceType,
  });

  /// Returns the correct name based on locale ('ar' or 'en')
  String localizedName(String languageCode) {
    if (languageCode == 'ar') return nameAr ?? name;
    return nameEn ?? name;
  }

  /// Returns the correct description based on locale
  String? localizedDescription(String languageCode) {
    if (languageCode == 'ar') return descriptionAr ?? description;
    return descriptionEn ?? description;
  }

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as int? ?? json['categories_sub_id'] as int?,
      categoryId: json['category_id'] as int? ?? json['categories_id'] as int? ?? json['categories_sub_id'] as int?,
      // Support both APIs: home (name) and child-categories (name_ar/name_en)
      name: json['name'] as String? ?? json['name_en'] as String? ?? json['name_ar'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      sortOrder: json['sort_order'] as int?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      price: json['price']?.toString(),
      serviceType: json['service_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description': description,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'sort_order': sortOrder,
      'is_active': isActive,
      'price': price,
      'service_type': serviceType,
    };
  }

  @override
  List<Object?> get props => [id, categoryId, name, nameAr, nameEn, description, sortOrder, isActive, price, serviceType];
}
