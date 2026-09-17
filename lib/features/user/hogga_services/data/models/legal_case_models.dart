import 'dart:io';

class CreateLegalCaseRequest {
  final int categoriesItemId;
  final int categoriesSubId;
  final String title;
  final String description;
  final String selectionType;
  final List<int> lawyerIds;
  final String? couponCode;
  final String? executionDate;
  final String paymentMethod;
  final double? minPrice;
  final double? maxPrice;
  final Map<String, dynamic> metadata;

  const CreateLegalCaseRequest({
    required this.categoriesItemId,
    required this.categoriesSubId,
    required this.title,
    required this.description,
    required this.selectionType,
    this.lawyerIds = const [],
    this.couponCode,
    this.executionDate,
    required this.paymentMethod,
    this.minPrice,
    this.maxPrice,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'categories_item_id': categoriesItemId,
      'categories_sub_id': categoriesSubId,
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

    for (final entry in metadata.entries) {
      final key = entry.key.trim();
      if (key.isNotEmpty && !payload.containsKey(key)) {
        payload[key] = entry.value;
      }
    }

    return payload;
  }
}

class BookConsultationRequest {
  final int categorySubId;
  final int categoriesItemId;
  final int providerId;
  final int priceId;
  final String title;
  final String description;
  final String? scheduledAt;
  final String? couponCode;
  final String paymentMethod;

  const BookConsultationRequest({
    required this.categorySubId,
    required this.categoriesItemId,
    required this.providerId,
    required this.priceId,
    required this.title,
    required this.description,
    this.scheduledAt,
    this.couponCode,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_sub_id': categorySubId,
      'categories_item_id': categoriesItemId,
      'provider_id': providerId,
      'price_id': priceId,
      'title': title,
      'description': description,
      if (scheduledAt != null && scheduledAt!.trim().isNotEmpty)
        'scheduled_at': scheduledAt,
      if (couponCode != null && couponCode!.trim().isNotEmpty)
        'coupon_code': couponCode,
      'payment_method': paymentMethod,
    };
  }
}

class ConsultationPriceModel {
  final int id;
  final int duration;
  final double price;

  const ConsultationPriceModel({
    required this.id,
    required this.duration,
    required this.price,
  });

  factory ConsultationPriceModel.fromJson(Map<String, dynamic> json) {
    return ConsultationPriceModel(
      id: _readInt(json['id']),
      duration: _readInt(json['duration']),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ConsultationLawyerModel {
  final int id;
  final String name;
  final String? photo;
  final String city;
  final String? level;
  final int experienceYears;
  final double? rating;
  final int totalRatesCount;
  final bool isVerified;
  final bool isOnline;
  final bool isWritten;
  final List<ConsultationPriceModel> prices;

  const ConsultationLawyerModel({
    required this.id,
    required this.name,
    this.photo,
    required this.city,
    this.level,
    required this.experienceYears,
    this.rating,
    required this.totalRatesCount,
    required this.isVerified,
    required this.isOnline,
    required this.isWritten,
    required this.prices,
  });

  factory ConsultationLawyerModel.fromJson(Map<String, dynamic> json) {
    return ConsultationLawyerModel(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      photo: _readNullableString(json['photo']),
      city: json['city']?.toString() ?? '',
      level: _readNullableString(json['level']),
      experienceYears: _readInt(json['experience_years']),
      rating: double.tryParse(
        (json['average_rating'] ?? json['rating'])?.toString() ?? '',
      ),
      totalRatesCount: _readInt(json['total_rates_count']),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      isWritten: json['is_written'] == true || json['is_written'] == 1,
      prices: (json['prices'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ConsultationPriceModel.fromJson)
          .toList(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _readNullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty || text == 'null' ? null : text;
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
      success: json['success'] == true || json['status'] == true,
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
  final double? discountAmount;
  final double? totalPrice;

  const CouponData({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.discountAmount,
    this.totalPrice,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      id: json['id'] ?? 0,
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? '',
      discountValue:
          double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0,
      discountAmount: _readDouble(
        json['discount_amount'] ?? json['discount'] ?? json['amount_saved'],
      ),
      totalPrice: _readDouble(
        json['total_price'] ?? json['final_price'] ?? json['amount'],
      ),
    );
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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
      ['consultation_id'],
      ['legal_case_id'],
      ['id'],
      ['case', 'id'],
      ['consultation', 'id'],
      ['legal_case', 'id'],
      ['order', 'id'],
    ]);
  }

  String? get caseNumber => _readString(data, const [
    ['case_number'],
    ['consultation_number'],
    ['number'],
    ['case', 'case_number'],
    ['consultation', 'consultation_number'],
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
      'consultation_id',
      'legal_case_id',
      'case_number',
      'consultation_number',
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
  final String? paymentUrl;
  final String? paymentStatus;

  const AcceptProposalResponse({
    required this.status,
    required this.message,
    this.acceptedLawyerId,
    this.caseId,
    this.paymentUrl,
    this.paymentStatus,
  });

  factory AcceptProposalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return AcceptProposalResponse(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      acceptedLawyerId: int.tryParse(data?['accepted_lawyer_id']?.toString() ?? '') ??
          (data?['accepted_lawyer_id'] is int ? data!['accepted_lawyer_id'] as int : null),
      caseId: int.tryParse(data?['case_id']?.toString() ?? '') ??
          (data?['case_id'] is int ? data!['case_id'] as int : null),
      paymentUrl: _readString(data, const [
        ['payment_url'],
        ['payment_link'],
        ['redirect_url'],
        ['checkout_url'],
        ['url'],
        ['payment', 'payment_url'],
        ['payment', 'url'],
      ]) ??
          _readString(json, const [
            ['payment_url'],
            ['payment_link'],
            ['redirect_url'],
            ['checkout_url'],
            ['url'],
          ]),
      paymentStatus: _readString(data, const [
        ['payment_status'],
        ['status_key'],
        ['payment', 'status'],
      ]),
    );
  }

  static String? _readString(
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
      final value = current?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return null;
  }
}
