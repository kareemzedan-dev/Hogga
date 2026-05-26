class ProviderTypeFieldModel {
  final String name;
  final String type;
  final bool isRequired;
  final String key;

  const ProviderTypeFieldModel({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.key,
  });

  factory ProviderTypeFieldModel.fromJson(Map<String, dynamic> json) {
    return ProviderTypeFieldModel(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'string',
      isRequired: json['is_required'] == true,
      key: json['key']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}

class ProviderTypeModel {
  final int id;
  final String name;
  final List<ProviderTypeFieldModel> fields;

  const ProviderTypeModel({
    required this.id,
    required this.name,
    required this.fields,
  });

  factory ProviderTypeModel.fromJson(Map<String, dynamic> json) {
    return ProviderTypeModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      fields: (json['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderTypeFieldModel.fromJson)
          .toList(),
    );
  }
}

class LegalSpecializationModel {
  final int id;
  final String name;

  const LegalSpecializationModel({
    required this.id,
    required this.name,
  });

  factory LegalSpecializationModel.fromJson(Map<String, dynamic> json) {
    return LegalSpecializationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class LawyerRegistrationDraft {
  final String token;
  final String status;

  const LawyerRegistrationDraft({
    required this.token,
    required this.status,
  });

  factory LawyerRegistrationDraft.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return LawyerRegistrationDraft(
      token: data['token']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
    );
  }
}

class LawyerProfileCompletionResult {
  final bool success;
  final String message;
  final String status;

  const LawyerProfileCompletionResult({
    required this.success,
    required this.message,
    required this.status,
  });

  factory LawyerProfileCompletionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return LawyerProfileCompletionResult(
      success: json['success'] == true || json['status'] == true,
      message: json['message']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
    );
  }
}
