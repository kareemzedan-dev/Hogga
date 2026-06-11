class MyOrderResponse {
  final List<MyOrderData> data;

  MyOrderResponse({required this.data});

  factory MyOrderResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = rawData is List ? rawData : <dynamic>[];
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
  // Payment status
  final String paymentStatus;
  final String paymentStatusText;
  // Service type
  final String serviceTypeKey;
  final String serviceTypeText;
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
    this.paymentStatus = 'pending',
    this.paymentStatusText = '',
    this.serviceTypeKey = 'article',
    this.serviceTypeText = '',
    this.chatRoomId,
    this.paymentUrl,
  });

  bool get isPaid => paymentStatus == 'paid';
  bool get hasChatRoom => chatRoomId != null;
  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;

  factory MyOrderData.fromJson(Map<String, dynamic> json) {
    final dateString = json['date']?.toString();
    return MyOrderData(
      id: json['id'] ?? 0,
      caseNumber: json['case_number']?.toString() ?? '',
      productName: json['title']?.toString() ?? '',
      status: json['status_key']?.toString() ?? 'pending',
      statusText: json['status_text']?.toString() ?? '',
      total: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      lawyersCount: json['lawyers_count'] ?? 0,
      createdAt: dateString != null && dateString.isNotEmpty
          ? DateTime.tryParse(dateString) ?? DateTime.now()
          : DateTime.now(),
      formattedDate: json['formatted_date']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      paymentStatusText: json['payment_status_text']?.toString() ?? '',
      serviceTypeKey: json['service_type_key']?.toString() ?? 'article',
      serviceTypeText: json['service_type_text']?.toString() ?? '',
      chatRoomId: json['chat_room_id'] as int?,
      paymentUrl: json['payment_url']?.toString(),
    );
  }
}
