import 'dart:io';

class CreateLegalCaseRequest {
  final int categoriesItemId;
  final String title;
  final String description;
  final String selectionType;
  final List<int> lawyerIds;
  final String? couponCode;
  final String? executionDate;
  final String paymentMethod;
  final double? minPrice;
  final double? maxPrice;

  const CreateLegalCaseRequest({
    required this.categoriesItemId,
    required this.title,
    required this.description,
    required this.selectionType,
    this.lawyerIds = const [],
    this.couponCode,
    this.executionDate,
    required this.paymentMethod,
    this.minPrice,
    this.maxPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'categories_item_id': categoriesItemId,
      'title': title,
      'description': description,
      'selection_type': selectionType,
      if (lawyerIds.isNotEmpty) 'lawyer_ids': lawyerIds,
      if (couponCode != null && couponCode!.trim().isNotEmpty)
        'coupon_code': couponCode,
      if (executionDate != null) 'execution_date': executionDate,
      'payment_method': paymentMethod,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
    };
  }
}

class CouponVerificationModel {
  final bool success;
  final CouponData? data;
  final String? message;

  const CouponVerificationModel({
    required this.success,
    this.data,
    this.message,
  });

  factory CouponVerificationModel.fromJson(Map<String, dynamic> json) {
    return CouponVerificationModel(
      success: json['success'] == true,
      data: json['data'] is Map<String, dynamic>
          ? CouponData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class CouponData {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;

  const CouponData({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      id: json['id'] ?? 0,
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? '',
      discountValue:
          double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0,
    );
  }
}

class LegalCaseResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  const LegalCaseResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory LegalCaseResponse.fromJson(Map<String, dynamic> json) {
    final normalizedData = _normalizedData(json);
    return LegalCaseResponse(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: normalizedData.isEmpty ? null : normalizedData,
    );
  }

  int? get caseId {
    return _readInt(data, const [
      ['case_id'],
      ['legal_case_id'],
      ['id'],
      ['case', 'id'],
      ['legal_case', 'id'],
      ['order', 'id'],
    ]);
  }

  String? get caseNumber => _readString(data, const [
    ['case_number'],
    ['number'],
    ['case', 'case_number'],
    ['legal_case', 'case_number'],
    ['order', 'case_number'],
  ]);
  double? get minPrice => double.tryParse(data?['min_price']?.toString() ?? '');
  double? get maxPrice => double.tryParse(data?['max_price']?.toString() ?? '');
  String? get paymentUrl => _readString(data, const [
    ['payment_url'],
    ['payment_link'],
    ['paymentUrl'],
    ['redirect_url'],
    ['checkout_url'],
    ['invoice_url'],
    ['url'],
    ['payment', 'payment_url'],
    ['payment', 'payment_link'],
    ['payment', 'redirect_url'],
    ['payment', 'checkout_url'],
    ['payment', 'invoice_url'],
    ['payment', 'url'],
  ]);

  static Map<String, dynamic> _normalizedData(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};

    for (final key in const [
      'case_id',
      'legal_case_id',
      'case_number',
      'payment_url',
      'payment_link',
      'paymentUrl',
      'redirect_url',
      'checkout_url',
      'invoice_url',
      'url',
      'payment',
      'case',
      'legal_case',
      'order',
    ]) {
      if (!data.containsKey(key) && json.containsKey(key)) {
        data[key] = json[key];
      }
    }

    return data;
  }

  static int? _readInt(Map<String, dynamic>? source, List<List<String>> paths) {
    final raw = _readValue(source, paths);
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  static String? _readString(
    Map<String, dynamic>? source,
    List<List<String>> paths,
  ) {
    final raw = _readValue(source, paths)?.toString().trim();
    return raw == null || raw.isEmpty || raw == 'null' ? null : raw;
  }

  static dynamic _readValue(
    Map<String, dynamic>? source,
    List<List<String>> paths,
  ) {
    if (source == null) return null;

    for (final path in paths) {
      dynamic current = source;
      for (final key in path) {
        if (current is! Map || !current.containsKey(key)) {
          current = null;
          break;
        }
        current = current[key];
      }
      if (current != null) return current;
    }

    return null;
  }
}

class UploadLegalCaseDocumentsRequest {
  final int caseId;
  final List<String> titles;
  final List<File> files;

  const UploadLegalCaseDocumentsRequest({
    required this.caseId,
    required this.titles,
    required this.files,
  });
}

class AcceptProposalResponse {
  final bool status;
  final String message;
  final int? acceptedLawyerId;
  final int? caseId;

  const AcceptProposalResponse({
    required this.status,
    required this.message,
    this.acceptedLawyerId,
    this.caseId,
  });

  factory AcceptProposalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return AcceptProposalResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      acceptedLawyerId: data?['accepted_lawyer_id'] as int?,
      caseId: data?['case_id'] as int?,
    );
  }
}
