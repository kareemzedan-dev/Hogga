class OrderDetailsResponse {
  final OrderDetailsData data;

  OrderDetailsResponse({required this.data});

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      data: OrderDetailsData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      ),
    );
  }
}

class OrderDetailsData {
  final int id;
  final String caseNumber;
  final String title;
  final String description;
  final String status;
  final String statusText;
  final String selectionType;
  final Financials financials;
  final CaseCategory category;
  final List<CaseDocument> documents;
  final List<CaseProposal> proposals;
  final String createdAt;

  OrderDetailsData({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.statusText,
    required this.selectionType,
    required this.financials,
    required this.category,
    required this.documents,
    required this.proposals,
    required this.createdAt,
  });

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) {
    return OrderDetailsData(
      id: json['id'] ?? 0,
      caseNumber: json['case_number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status_key']?.toString() ?? 'pending',
      statusText: json['status_text']?.toString() ?? '',
      selectionType: json['selection_type']?.toString() ?? '',
      financials: Financials.fromJson(
        Map<String, dynamic>.from(json['financials'] as Map? ?? {}),
      ),
      category: CaseCategory.fromJson(
        Map<String, dynamic>.from(json['category'] as Map? ?? {}),
      ),
      documents: (json['documents'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CaseDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      proposals: (json['proposals'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CaseProposal.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class Financials {
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentUrl;

  Financials({
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentUrl,
  });

  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentUrl: json['payment_url']?.toString(),
    );
  }
}

class CaseCategory {
  final int id;
  final String name;

  CaseCategory({required this.id, required this.name});

  factory CaseCategory.fromJson(Map<String, dynamic> json) {
    return CaseCategory(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class CaseDocument {
  final int id;
  final String title;
  final String url;
  final String name;

  CaseDocument({
    required this.id,
    required this.title,
    required this.url,
    required this.name,
  });

  factory CaseDocument.fromJson(Map<String, dynamic> json) {
    return CaseDocument(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class CaseProposal {
  final int id;
  final String status;
  final int lawyerId;
  final String lawyerName;
  final String? lawyerPhoto;
  final String? lawyerPhone;
  final String description;
  // New fields for UI (to be populated by backend later)
  final String price;
  final String days;
  final String lawyerRating;
  final String lawyerExperience;

  CaseProposal({
    required this.id,
    required this.status,
    required this.lawyerId,
    required this.lawyerName,
    this.lawyerPhoto,
    this.lawyerPhone,
    required this.description,
    this.price = '0',
    this.days = '0',
    this.lawyerRating = '5.0',
    this.lawyerExperience = '0',
  });

  factory CaseProposal.fromJson(Map<String, dynamic> json) {
    return CaseProposal(
      id: json['id'] ?? 0,
      status: json['status']?.toString() ?? '',
      lawyerId: json['lawyer_id'] ?? 0,
      lawyerName: json['lawyer_name']?.toString() ?? '',
      lawyerPhoto: json['lawyer_photo']?.toString(),
      lawyerPhone: json['lawyer_phone']?.toString(),
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      days: json['delivery_time']?.toString() ?? '0',
      lawyerRating: json['lawyer_rating']?.toString() ?? '5.0',
      lawyerExperience: json['lawyer_experience']?.toString() ?? '0',
    );
  }
}
