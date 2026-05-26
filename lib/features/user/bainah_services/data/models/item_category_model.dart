class ItemCategoryModel {
  final bool status;
  final String message;
  final List<ItemCategoryData> data;

  ItemCategoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((i) => ItemCategoryData.fromJson(i)).toList()
          : [],
    );
  }
}

class ItemCategoryData {
  final int id;
  final int childCategoryId;
  final String name;
  final String? description;
  final String price;

  ItemCategoryData({
    required this.id,
    required this.childCategoryId,
    required this.name,
    this.description,
    required this.price,
  });

  factory ItemCategoryData.fromJson(Map<String, dynamic> json) {
    return ItemCategoryData(
      id: json['id'] ?? 0,
      childCategoryId: json['categories_child_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toString() ?? '0.00',
    );
  }
}
