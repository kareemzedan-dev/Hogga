import 'package:hogga/features/user/my_orders/data/models/order_model.dart';

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
  final String recordType;
  final String recordTypeText;
  final String serviceTypeKey;
  final String serviceTypeText;
  final String selectionType;
  final Financials financials;
  final CaseCategory category;
  final List<CaseDocument> documents;
  final List<CaseProposal> proposals;
  final String createdAt;
  final int? duration;
  final CallDuration? callDuration;
  final int? chatRoomId;
  final int? lawyerId;
  final String lawyerName;
  final OrderLawyer? lawyer;
  final CaseProposal? acceptedProposal;
  final bool hasAcceptedProposal;
  final bool isCompletedByUser;
  final bool isCompletedByProvider;

  OrderDetailsData({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.statusText,
    this.recordType = 'service',
    this.recordTypeText = '',
    this.serviceTypeKey = '',
    this.serviceTypeText = '',
    required this.selectionType,
    required this.financials,
    required this.category,
    required this.documents,
    required this.proposals,
    required this.createdAt,
    this.duration,
    this.callDuration,
    this.chatRoomId,
    this.lawyerId,
    this.lawyerName = '',
    this.lawyer,
    this.acceptedProposal,
    this.hasAcceptedProposal = false,
    this.isCompletedByUser = false,
    this.isCompletedByProvider = false,
  });

  OrderDetailsData copyWith({
    int? id,
    String? caseNumber,
    String? title,
    String? description,
    String? status,
    String? statusText,
    String? recordType,
    String? recordTypeText,
    String? serviceTypeKey,
    String? serviceTypeText,
    String? selectionType,
    Financials? financials,
    CaseCategory? category,
    List<CaseDocument>? documents,
    List<CaseProposal>? proposals,
    String? createdAt,
    int? duration,
    CallDuration? callDuration,
    int? chatRoomId,
    int? lawyerId,
    String? lawyerName,
    OrderLawyer? lawyer,
    CaseProposal? acceptedProposal,
    bool? hasAcceptedProposal,
    bool? isCompletedByUser,
    bool? isCompletedByProvider,
  }) {
    return OrderDetailsData(
      id: id ?? this.id,
      caseNumber: caseNumber ?? this.caseNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      recordType: recordType ?? this.recordType,
      recordTypeText: recordTypeText ?? this.recordTypeText,
      serviceTypeKey: serviceTypeKey ?? this.serviceTypeKey,
      serviceTypeText: serviceTypeText ?? this.serviceTypeText,
      selectionType: selectionType ?? this.selectionType,
      financials: financials ?? this.financials,
      category: category ?? this.category,
      documents: documents ?? this.documents,
      proposals: proposals ?? this.proposals,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      callDuration: callDuration ?? this.callDuration,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      lawyer: lawyer ?? this.lawyer,
      acceptedProposal: acceptedProposal ?? this.acceptedProposal,
      hasAcceptedProposal: hasAcceptedProposal ?? this.hasAcceptedProposal,
      isCompletedByUser: isCompletedByUser ?? this.isCompletedByUser,
      isCompletedByProvider:
          isCompletedByProvider ?? this.isCompletedByProvider,
    );
  }

  bool get hasAcceptedLawyer {
    if (isPending) return false;
    final normalized = status.toLowerCase();
    return hasAcceptedProposal ||
        acceptedProposal != null ||
        normalized == 'accepted' ||
        normalized == 'approved' ||
        normalized == 'in_progress' ||
        normalized == 'active' ||
        normalized == 'ongoing' ||
        ((lawyer != null || lawyerId != null) &&
            (normalized == 'completed' ||
             normalized == 'complete' ||
             normalized == 'done' ||
             normalized == 'finished'));
  }

  bool get canRateLawyer {
    final normalizedStatus = status.toLowerCase();
    return normalizedStatus == 'completed' ||
        normalizedStatus == 'complete' ||
        normalizedStatus == 'done' ||
        (normalizedStatus == 'finished' &&
            isCompletedByUser &&
            isCompletedByProvider);
  }

  bool get isAcceptedOrActive {
    final normalizedStatus = status.toLowerCase();
    return normalizedStatus == 'accepted' ||
        normalizedStatus == 'approved' ||
        normalizedStatus == 'in_progress' ||
        normalizedStatus == 'completed' ||
        normalizedStatus == 'complete' ||
        normalizedStatus == 'done' ||
        normalizedStatus == 'finished' ||
        normalizedStatus == 'canceled' ||
        normalizedStatus == 'cancelled' ||
        proposals.any((p) => p.isAccepted);
  }

  CaseProposal? get ratableProposal {
    const preferredStatuses = {
      'accepted',
      'approved',
      'selected',
      'completed',
      'complete',
      'done',
      'finished',
    };

    for (final proposal in proposals) {
      if (proposal.providerId > 0 &&
          preferredStatuses.contains(proposal.status.toLowerCase())) {
        return proposal;
      }
    }

    for (final proposal in proposals) {
      if (proposal.providerId > 0) return proposal;
    }

    return null;
  }

  CaseProposal? get consultationRatableProposal {
    if (lawyerId == null || lawyerId! <= 0) return null;
    return CaseProposal(
      id: 0,
      status: status,
      lawyerId: lawyerId!,
      providerId: lawyerId!,
      lawyerName: lawyerName,
      description: description,
      price: financials.totalPrice.toStringAsFixed(2),
    );
  }

  CaseProposal? get ratingTarget =>
      acceptedProposal ??
      ratableProposal ??
      consultationRatableProposal;

  bool get isConsultation =>
      recordType.toLowerCase() == 'consultation' ||
      serviceTypeKey.toLowerCase().contains('consultation') ||
      recordTypeText.contains('استشارة') ||
      recordTypeText.contains('استشاره');

  bool get isPending {
    final s = status.toLowerCase();
    return s == 'pending' ||
        s == 'waiting_for_lawyer' ||
        s == 'waiting' ||
        s == 'under_review';
  }

  bool get hasChatRoom => chatRoomId != null;

  bool get canCompleteByUser {
    if (isCompletedByUser) return false;
    if (financials.paymentStatus.toLowerCase() != 'paid') return false;

    final normalizedStatus = status.toLowerCase();
    return normalizedStatus == 'accepted' ||
        normalizedStatus == 'approved' ||
        normalizedStatus == 'active' ||
        normalizedStatus == 'in_progress' ||
        normalizedStatus == 'ongoing';
  }

  bool get isCallType {
    final key = serviceTypeKey.toLowerCase();
    return key.contains('audio') ||
        key.contains('video') ||
        key.contains('phone') ||
        key.contains('voice');
  }

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) {
    final financialsJson = json['financials'] is Map
        ? Map<String, dynamic>.from(json['financials'] as Map)
        : json;
    final categoryJson = json['category'] is Map
        ? Map<String, dynamic>.from(json['category'] as Map)
        : <String, dynamic>{
            'id': json['category_id'],
            'name': json['category_name'],
          };
    final lawyerJson = json['lawyer'] is Map
        ? Map<String, dynamic>.from(json['lawyer'] as Map)
        : null;
    final acceptedProposalJson = json['accepted_proposal'] is Map
        ? Map<String, dynamic>.from(json['accepted_proposal'] as Map)
        : null;
    final lawyer = lawyerJson != null
        ? OrderLawyer.fromJson(lawyerJson)
        : null;
    final acceptedProposal = acceptedProposalJson != null
        ? CaseProposal.fromJson(acceptedProposalJson)
        : null;
    final hasAcceptedProposal = json['has_accepted_proposal'] == true ||
        acceptedProposalJson != null ||
        (json['status_key']?.toString().toLowerCase() == 'accepted');

    return OrderDetailsData(
      id: json['id'] ?? 0,
      caseNumber: json['case_number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status_key']?.toString() ?? 'pending',
      statusText: json['status_text']?.toString() ?? '',
      recordType: json['record_type']?.toString() ?? 'service',
      recordTypeText: json['record_type_text']?.toString() ?? '',
      serviceTypeKey: json['service_type_key']?.toString() ?? '',
      serviceTypeText: json['service_type_text']?.toString() ?? '',
      selectionType: json['selection_type']?.toString() ?? '',
      financials: Financials.fromJson(financialsJson),
      category: CaseCategory.fromJson(categoryJson),
      documents: (json['documents'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CaseDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      proposals: (json['proposals'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CaseProposal.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString() ?? '',
      duration: _readInt(json['duration']),
      callDuration: json['call_duration'] != null || json['call'] != null
          ? CallDuration.fromJson(
              Map<String, dynamic>.from(
                (json['call_duration'] ?? json['call']) as Map,
              ),
            )
          : null,
      chatRoomId:
          _readInt(json['chat_room_id']) ??
          _readInt(json['chat_info'] is Map ? json['chat_info']['id'] : null) ??
          _readInt(financialsJson['chat_room_id']),
      lawyerId: _readInt(json['lawyer_id']) ??
          lawyer?.id ??
          acceptedProposal?.lawyerId,
      lawyerName: json['lawyer_name']?.toString() ??
          lawyer?.name ??
          acceptedProposal?.lawyerName ??
          '',
      lawyer: lawyer,
      acceptedProposal: acceptedProposal,
      hasAcceptedProposal: hasAcceptedProposal,
      isCompletedByUser: json['is_completed_by_user'] == true,
      isCompletedByProvider: json['is_completed_by_provider'] == true,
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class OrderLawyer {
  final int id;
  final int? userId;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String? email;
  final String? city;
  final int experienceYears;
  final String? providerType;
  final String? specialization;
  final double rating;
  final int reviewsCount;

  OrderLawyer({
    required this.id,
    this.userId,
    required this.name,
    this.photoUrl,
    this.phone,
    this.email,
    this.city,
    this.experienceYears = 0,
    this.providerType,
    this.specialization,
    this.rating = 5.0,
    this.reviewsCount = 0,
  });

  factory OrderLawyer.fromJson(Map<String, dynamic> json) {
    return OrderLawyer(
      id: _readInt(json['id']) ?? 0,
      userId: _readInt(json['user_id']),
      name: json['name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ??
          json['photo']?.toString() ??
          json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      city: json['city']?.toString(),
      experienceYears: _readInt(json['experience_years']) ?? 0,
      providerType: json['provider_type']?.toString(),
      specialization: json['specialization']?.toString(),
      rating: double.tryParse(
            (json['rating'] ?? json['average_rating'])?.toString() ?? '',
          ) ??
          5.0,
      reviewsCount: _readInt(json['reviews_count']) ?? 0,
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class Financials {
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final String paymentStatusText;
  final String? paymentUrl;

  Financials({
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentStatusText,
    this.paymentUrl,
  });

  String get displayPaymentStatus =>
      paymentStatusText.isNotEmpty ? paymentStatusText : paymentStatus;

  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;

  factory Financials.fromJson(Map<String, dynamic> json) {
    final total = double.tryParse(json['total_price']?.toString() ?? '0') ?? 0;
    return Financials(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? total,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      totalPrice: total,
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      paymentStatusText: json['payment_status_text']?.toString() ?? '',
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
  final int providerId;
  final String lawyerName;
  final String? lawyerPhoto;
  final String? lawyerPhone;
  final String description;
  final String price;
  final String days;
  final String lawyerRating;
  final String lawyerExperience;
  final String? paymentStatus;

  CaseProposal({
    required this.id,
    required this.status,
    required this.lawyerId,
    required this.providerId,
    required this.lawyerName,
    this.lawyerPhoto,
    this.lawyerPhone,
    required this.description,
    this.price = '0',
    this.days = '0',
    this.lawyerRating = '5.0',
    this.lawyerExperience = '0',
    this.paymentStatus,
  });

  bool get isAccepted {
    final normalizedStatus = status.toLowerCase();
    return normalizedStatus == 'accepted' || normalizedStatus == 'approved';
  }

  bool get isPaid {
    final normalized = paymentStatus?.toLowerCase();
    return normalized == 'paid' || normalized == 'completed';
  }

  factory CaseProposal.fromJson(Map<String, dynamic> json) {
    final lawyerInside =
        json['lawyer'] is Map ? json['lawyer'] as Map : null;
    final lawyerId = _readInt(json['lawyer_id']) ??
        _readInt(lawyerInside?['id']);
    final providerId =
        _readInt(json['provider_id']) ??
        _readInt(json['provider'] is Map ? json['provider']['id'] : null) ??
        _readInt(json['lawyer_provider_id']) ??
        _readInt(json['providerId']) ??
        lawyerId ??
        0;

    return CaseProposal(
      id: json['id'] ?? 0,
      status: json['status']?.toString() ?? '',
      lawyerId: lawyerId ?? 0,
      providerId: providerId,
      lawyerName: json['lawyer_name']?.toString() ??
          lawyerInside?['name']?.toString() ??
          '',
      lawyerPhoto: json['lawyer_photo']?.toString() ??
          lawyerInside?['photo_url']?.toString() ??
          lawyerInside?['photo']?.toString(),
      lawyerPhone: json['lawyer_phone']?.toString() ??
          lawyerInside?['phone']?.toString(),
      description: json['description']?.toString() ?? '',
      price:
          json['price']?.toString() ??
          json['offer_price']?.toString() ??
          json['total_price']?.toString() ??
          '0',
      days: json['delivery_time']?.toString() ??
          json['days']?.toString() ??
          '0',
      lawyerRating: json['lawyer_rating']?.toString() ?? '5.0',
      lawyerExperience: json['lawyer_experience']?.toString() ?? '0',
      paymentStatus: json['payment_status']?.toString(),
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
