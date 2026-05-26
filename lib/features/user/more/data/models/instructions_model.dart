class InstructionsModel {
  final bool status;
  final List<InstructionData> data;

  InstructionsModel({required this.status, required this.data});

  factory InstructionsModel.fromJson(Map<String, dynamic> json) {
    return InstructionsModel(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => InstructionData.fromJson(i)).toList()
          : [],
    );
  }
}

class InstructionData {
  final int id;
  final String title;
  final String description;

  InstructionData({
    required this.id,
    required this.title,
    required this.description,
  });

  factory InstructionData.fromJson(Map<String, dynamic> json) {
    return InstructionData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
