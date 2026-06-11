class PaymentModel {
  final int id;
  final String paymentNumber;
  final String amount;
  final String currency;
  final String paymentMethod;
  final String paymentMethodKey;
  final String status;
  final String statusKey;
  final String date;
  final PaymentCaseModel? caseDetails;

  PaymentModel({
    required this.id,
    required this.paymentNumber,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentMethodKey,
    required this.status,
    required this.statusKey,
    required this.date,
    this.caseDetails,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      paymentNumber: json['payment_number']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentMethodKey: json['payment_method_key']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusKey: json['status_key']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      caseDetails: json['case'] != null ? PaymentCaseModel.fromJson(json['case']) : null,
    );
  }
}

class PaymentCaseModel {
  final int id;
  final String title;
  final String caseNumber;
  final String status;
  final String? description;
  final String? createdAt;

  PaymentCaseModel({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.status,
    this.description,
    this.createdAt,
  });

  factory PaymentCaseModel.fromJson(Map<String, dynamic> json) {
    return PaymentCaseModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      caseNumber: json['case_number']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
