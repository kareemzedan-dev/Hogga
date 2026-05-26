class LawyerLibraryItemModel {
  final int id;
  final String name;
  final String type; // 'category' or 'article'

  LawyerLibraryItemModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory LawyerLibraryItemModel.fromJson(Map<String, dynamic> json) {
    return LawyerLibraryItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      type: json['type'] ?? 'article',
    );
  }
}

class LawyerLibraryArticleModel {
  final int id;
  final String title;
  final int categoryId;
  final int views;
  final String createdAt;

  LawyerLibraryArticleModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.views,
    required this.createdAt,
  });

  factory LawyerLibraryArticleModel.fromJson(Map<String, dynamic> json) {
    return LawyerLibraryArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryId: json['legal_category_id'] ?? 0,
      views: json['views'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class LawyerLibraryArticleDetailsModel {
  final int id;
  final int categoryId;
  final String title;
  final String content;
  final int views;
  final String createdAt;
  final String updatedAt;
  final LawyerLibraryCategoryShortModel category;

  LawyerLibraryArticleDetailsModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory LawyerLibraryArticleDetailsModel.fromJson(Map<String, dynamic> json) {
    return LawyerLibraryArticleDetailsModel(
      id: json['id'] ?? 0,
      categoryId: json['legal_category_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      views: json['views'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      category: LawyerLibraryCategoryShortModel.fromJson(json['category'] ?? {}),
    );
  }
}

class LawyerLibraryCategoryShortModel {
  final int id;
  final String name;

  LawyerLibraryCategoryShortModel({
    required this.id,
    required this.name,
  });

  factory LawyerLibraryCategoryShortModel.fromJson(Map<String, dynamic> json) {
    return LawyerLibraryCategoryShortModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
