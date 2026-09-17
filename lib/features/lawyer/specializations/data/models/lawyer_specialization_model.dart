class LawyerSpecializationCategoryModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final bool isActive;
  final bool isSubscribed;
  final List<LawyerSpecializationItemModel> items;

  const LawyerSpecializationCategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.isActive = true,
    this.isSubscribed = false,
    required this.items,
  });

  String getLocalizedName(bool isArabic) =>
      isArabic ? nameAr : (nameEn.isNotEmpty ? nameEn : nameAr);

  factory LawyerSpecializationCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LawyerSpecializationCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      isActive: _readBool(json['is_active'], defaultValue: true),
      isSubscribed: _readBool(json['is_subscribed']),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LawyerSpecializationItemModel.fromJson)
          .toList(),
    );
  }

  static bool _readBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value == 1;
    final text = value.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}

class LawyerSpecializationItemModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final int? categoryChildId;
  final bool isActive;
  final bool isSubscribed;
  final bool isSelected;

  const LawyerSpecializationItemModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.categoryChildId,
    this.isActive = true,
    this.isSubscribed = false,
    this.isSelected = false,
  });

  String getLocalizedName(bool isArabic) =>
      isArabic ? nameAr : (nameEn.isNotEmpty ? nameEn : nameAr);

  LawyerSpecializationItemModel copyWith({bool? isSelected}) {
    return LawyerSpecializationItemModel(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      categoryChildId: categoryChildId,
      isActive: isActive,
      isSubscribed: isSubscribed,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory LawyerSpecializationItemModel.fromJson(Map<String, dynamic> json) {
    final hasPivot = json['pivot'] != null;
    final isSubscribed = _readBool(json['is_subscribed']);
    final isSelectedVal =
        isSubscribed ||
        json['is_selected'] == true ||
        json['selected'] == true ||
        json['is_selected'] == 1 ||
        json['selected'] == 1 ||
        hasPivot;

    return LawyerSpecializationItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      categoryChildId: json['categories_child_id'] is int
          ? json['categories_child_id']
          : int.tryParse(json['categories_child_id']?.toString() ?? ''),
      isActive: _readBool(json['is_active'], defaultValue: true),
      isSubscribed: isSubscribed,
      isSelected: isSelectedVal,
    );
  }

  static bool _readBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value == 1;
    final text = value.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
