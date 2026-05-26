class PrivacyPolicyModel {
  final bool status;
  final List<PrivacyData> data;

  PrivacyPolicyModel({required this.status, required this.data});

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => PrivacyData.fromJson(i)).toList()
          : [],
    );
  }
}

class PrivacyData {
  final int id;
  final String title;
  final String description;

  PrivacyData({
    required this.id,
    required this.title,
    required this.description,
  });

  factory PrivacyData.fromJson(Map<String, dynamic> json) {
    return PrivacyData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
