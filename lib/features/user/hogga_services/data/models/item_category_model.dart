import 'package:hogga/features/user/hogga_services/domain/models/service_required_input.dart';

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
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
        : rawData is Map
        ? [rawData]
        : const <dynamic>[];

    return ItemCategoryModel(
      status: json['status'] == true || json['success'] == true,
      message: json['message'] ?? '',
      data: items
          .whereType<Map>()
          .map((i) => ItemCategoryData.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
    );
  }
}

class ItemCategoryData {
  final int id;
  final int childCategoryId;
  final int? subCategoryId;
  final String name;
  final String? description;
  final String? price;
  final double? publishingFee;
  final String? serviceType;
  final String? consultationType;
  final bool isConsultation;
  final int? duration;
  final List<ServiceRequiredInput> requiredInputs;

  ItemCategoryData({
    required this.id,
    required this.childCategoryId,
    this.subCategoryId,
    required this.name,
    this.description,
    this.price,
    this.publishingFee,
    this.serviceType,
    this.consultationType,
    this.isConsultation = false,
    this.duration,
    this.requiredInputs = const [],
  });

  bool get isCallType {
    final normalized = serviceType?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized.contains('audio') ||
        normalized.contains('video') ||
        normalized.contains('phone') ||
        normalized.contains('call');
  }

  factory ItemCategoryData.fromJson(Map<String, dynamic> json) {
    final inputs = (json['required_inputs'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => ServiceRequiredInput.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.isUsable)
        .toList();

    return ItemCategoryData(
      id: json['id'] ?? 0,
      childCategoryId: json['categories_child_id'] ?? 0,
      subCategoryId: json['categories_sub_id'] as int? ??
          json['sub_category_id'] as int? ??
          json['category_sub_id'] as int?,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toString(),
      publishingFee: _readDouble(json['publishing_fee']),
      serviceType: json['service_type']?.toString(),
      consultationType: json['consultation_type']?.toString(),
      isConsultation:
          json['is_consultation'] == true || json['is_consultation'] == 1,
      duration: json['duration'] as int?,
      requiredInputs: inputs,
    );
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
