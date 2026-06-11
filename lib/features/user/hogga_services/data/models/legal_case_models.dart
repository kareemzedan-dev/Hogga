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
      if (couponCode != null && couponCode!.trim().isNotEmpty) 'coupon_code': couponCode,
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
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0,
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
    return LegalCaseResponse(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  int? get caseId {
    final raw = data?['case_id'] ?? data?['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  String? get caseNumber => data?['case_number']?.toString();
  double? get minPrice => double.tryParse(data?['min_price']?.toString() ?? '');
  double? get maxPrice => double.tryParse(data?['max_price']?.toString() ?? '');
  String? get paymentUrl => data?['payment_url']?.toString();
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
