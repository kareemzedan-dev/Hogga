import 'package:equatable/equatable.dart';

class LawyerServiceResponse extends Equatable {
  final bool status;
  final String message;
  final LawyerServiceData data;

  const LawyerServiceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LawyerServiceResponse.fromJson(Map<String, dynamic> json) {
    return LawyerServiceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: LawyerServiceData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [status, message, data];
}

class LawyerServiceData extends Equatable {
  final int currentPage;
  final List<LawyerService> services;
  final String? nextPageUrl;
  final int lastPage;
  final int total;

  const LawyerServiceData({
    required this.currentPage,
    required this.services,
    this.nextPageUrl,
    required this.lastPage,
    required this.total,
  });

  factory LawyerServiceData.fromJson(Map<String, dynamic> json) {
    return LawyerServiceData(
      currentPage: json['current_page'] ?? 1,
      services: (json['data'] as List?)
              ?.map((e) => LawyerService.fromJson(e))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentPage, services, nextPageUrl, lastPage, total];
}

class LawyerService extends Equatable {
  final int id;
  final int providerId;
  final int childCategoryId;
  final String name;
  final String price;
  final ProviderModel? provider;

  const LawyerService({
    required this.id,
    required this.providerId,
    required this.childCategoryId,
    required this.name,
    required this.price,
    this.provider,
  });

  factory LawyerService.fromJson(Map<String, dynamic> json) {
    return LawyerService(
      id: json['id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      childCategoryId: json['categories_child_id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      provider: json['provider'] != null ? ProviderModel.fromJson(json['provider']) : null,
    );
  }

  @override
  List<Object?> get props => [id, providerId, childCategoryId, name, price, provider];
}

class ProviderModel extends Equatable {
  final int id;
  final int userId;
  final String? city;
  final int experienceYears;
  final String? level;
  final bool isIdentityHidden;
  final UserModel? user;

  const ProviderModel({
    required this.id,
    required this.userId,
    this.city,
    required this.experienceYears,
    this.level,
    required this.isIdentityHidden,
    this.user,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      city: json['city'],
      experienceYears: json['experience_years'] ?? 0,
      level: json['level'],
      isIdentityHidden: json['is_identity_hidden'] == true || json['is_identity_hidden'] == 1,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  @override
  List<Object?> get props => [id, userId, city, experienceYears, level, isIdentityHidden, user];
}

class UserModel extends Equatable {
  final int id;
  final String name;
  final String? photo;

  const UserModel({
    required this.id,
    required this.name,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      photo: json['photo'],
    );
  }

  @override
  List<Object?> get props => [id, name, photo];
}

class ServiceDetailsModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final String price;
  final double avgRating;
  final int? providerId;
  final String? providerName;
  final String? providerImage;
  final String? categoryName;
  final String? subCategoryName;
  final String? childCategoryName;

  const ServiceDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.avgRating,
    this.providerId,
    this.providerName,
    this.providerImage,
    this.categoryName,
    this.subCategoryName,
    this.childCategoryName,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] ?? {};
    final cat = json['category'] ?? {};
    final subCat = json['sub_category'] ?? {};
    final childCat = json['child_category'] ?? {};

    return ServiceDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      providerId: provider['id'],
      providerName: provider['name'],
      providerImage: provider['image'],
      categoryName: cat['name'],
      subCategoryName: subCat['name'],
      childCategoryName: childCat['name'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        avgRating,
        providerId,
        providerName,
        providerImage,
        categoryName,
        subCategoryName,
        childCategoryName,
      ];
}

class ProviderProfileModel extends Equatable {
  final int id;
  final String name;
  final String? gender;
  final String? photo;
  final String? city;
  final String? level;
  final String bio;
  final double rating;
  final String experience;
  final int orders;
  final bool isVerified;
  final bool isOnline;
  final List<ProviderService> services;

  const ProviderProfileModel({
    required this.id,
    required this.name,
    this.gender,
    this.photo,
    this.city,
    this.level,
    required this.bio,
    required this.rating,
    required this.experience,
    required this.orders,
    this.isVerified = false,
    this.isOnline = false,
    required this.services,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return ProviderProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender']?.toString(),
      photo: json['photo'],
      city: json['city']?.toString(),
      level: json['level']?.toString() ?? json['title']?.toString(),
      bio: json['bio'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? (stats['rating'] as num?)?.toDouble() ?? 0.0,
      experience: json['experience_years']?.toString() ?? stats['experience']?.toString() ?? '',
      orders: stats['orders'] ?? 0,
      isVerified: json['is_verified'] == true,
      isOnline: json['is_online'] == true,
      services: _parseServices(json),
    );
  }

  static List<ProviderService> _parseServices(Map<String, dynamic> json) {
    try {
      if (json['service'] != null) {
        return [ProviderService.fromJson(Map<String, dynamic>.from(json['service']))];
      }
      if (json['provider_service'] != null) {
        return [ProviderService.fromJson(Map<String, dynamic>.from(json['provider_service']))];
      }
      if (json['services'] != null && json['services'] is List) {
        return (json['services'] as List).map((e) => ProviderService.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      // Ignored
    }
    return [];
  }

  @override
  List<Object?> get props => [id, name, gender, photo, city, level, bio, rating, experience, orders, isVerified, isOnline, services];
}

class ProviderService extends Equatable {
  final int id;
  final String name;
  final String price;
  final String currency;
  final String? taxStatusText;

  const ProviderService({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    this.taxStatusText,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      currency: json['currency'] ?? '',
      taxStatusText: json['tax_status_text']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, price, currency, taxStatusText];
}
