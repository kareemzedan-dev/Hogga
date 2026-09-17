class MyOrderResponse {
  final List<MyOrderData> data;

  MyOrderResponse({required this.data});

  factory MyOrderResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = rawData is List
        ? rawData
        : rawData is Map
        ? rawData['items'] as List? ?? <dynamic>[]
        : <dynamic>[];
    return MyOrderResponse(
      data: list
          .whereType<Map>()
          .map((e) => MyOrderData.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class MyOrderData {
  final int id;
  final String caseNumber;
  final String productName;
  final String status;
  final String statusText;
  final double total;
  final String categoryName;
  final int lawyersCount;
  final DateTime createdAt;
  final String formattedDate;
  final String recordType;
  final String recordTypeText;
  final bool isCompletedByUser;
  final bool isCompletedByProvider;
  // Payment status
  final String paymentStatus;
  final String paymentStatusText;
  // Service type
  final String serviceTypeKey;
  final String serviceTypeText;
  // Duration (for audio/video calls)
  final int? duration;
  final CallDuration? callDuration;
  // Chat
  final int? chatRoomId;
  final String? paymentUrl;

  MyOrderData({
    required this.id,
    required this.caseNumber,
    required this.productName,
    required this.status,
    required this.statusText,
    required this.total,
    required this.categoryName,
    required this.lawyersCount,
    required this.createdAt,
    required this.formattedDate,
    this.recordType = 'service',
    this.recordTypeText = '',
    this.isCompletedByUser = false,
    this.isCompletedByProvider = false,
    this.paymentStatus = 'pending',
    this.paymentStatusText = '',
    this.serviceTypeKey = '',
    this.serviceTypeText = '',
    this.duration,
    this.callDuration,
    this.chatRoomId,
    this.paymentUrl,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isConsultation =>
      recordType.toLowerCase() == 'consultation' ||
      caseNumber.toUpperCase().startsWith('CONS') ||
      recordTypeText.contains('استشارة') ||
      recordTypeText.contains('استشاره');
  bool get hasChatRoom => chatRoomId != null;
  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;
  bool get isCallType {
    final key = serviceTypeKey.toLowerCase();
    return key.contains('audio') ||
        key.contains('video') ||
        key.contains('phone') ||
        key.contains('voice');
  }

  factory MyOrderData.fromJson(Map<String, dynamic> json) {
    final dateString = (json['date'] ?? json['created_at'])?.toString();
    return MyOrderData(
      id: _readInt(json['id']) ?? 0,
      caseNumber: json['case_number']?.toString() ?? '',
      productName: json['title']?.toString() ?? '',
      status: json['status_key']?.toString() ?? 'pending',
      statusText: json['status_text']?.toString() ?? '',
      total: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      lawyersCount: _readInt(json['lawyers_count']) ?? 0,
      createdAt: dateString != null && dateString.isNotEmpty
          ? DateTime.tryParse(dateString) ?? DateTime.now()
          : DateTime.now(),
      formattedDate: json['formatted_date']?.toString() ?? '',
      recordType: json['record_type']?.toString() ?? 'service',
      recordTypeText: json['record_type_text']?.toString() ?? '',
      isCompletedByUser: json['is_completed_by_user'] == true,
      isCompletedByProvider: json['is_completed_by_provider'] == true,
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      paymentStatusText: json['payment_status_text']?.toString() ?? '',
      serviceTypeKey: json['service_type_key']?.toString() ?? '',
      serviceTypeText: json['service_type_text']?.toString() ?? '',
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
          _readInt(json['chat_info'] is Map ? json['chat_info']['id'] : null),
      paymentUrl: json['payment_url']?.toString(),
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class CallDuration {
  final double totalMinutes;
  final double usedMinutes;
  final double usedSeconds;
  final double remainingMinutes;

  const CallDuration({
    required this.totalMinutes,
    required this.usedMinutes,
    required this.usedSeconds,
    required this.remainingMinutes,
  });

  factory CallDuration.fromJson(Map<String, dynamic> json) {
    return CallDuration(
      totalMinutes: (json['total_minutes'] as num?)?.toDouble() ?? 0,
      usedMinutes: (json['used_minutes'] as num?)?.toDouble() ?? 0,
      usedSeconds: (json['used_seconds'] as num?)?.toDouble() ?? 0,
      remainingMinutes: (json['remaining_minutes'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Returns remaining minutes (never negative)
  double get safeRemainingMinutes => remainingMinutes.clamp(0, double.infinity);
  double get safeTotalMinutes => totalMinutes.clamp(0, double.infinity);
  double get safeUsedMinutes => usedMinutes.clamp(0, double.infinity);
}
