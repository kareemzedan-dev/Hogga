import 'payment_model.dart';

class PaymentDetailsModel {
  final int id;
  final String paymentNumber;
  final String? invoiceNumber;
  final String? clientReferenceId;
  final String? expireAt;
  final String amount;
  final String? amountNumeric;
  final String currency;
  final String paymentMethod;
  final String paymentMethodKey;
  final String status;
  final String statusKey;
  final String date;
  final PaymentCaseModel? caseDetails;
  final List<PaymentProductModel> products;

  PaymentDetailsModel({
    required this.id,
    required this.paymentNumber,
    this.invoiceNumber,
    this.clientReferenceId,
    this.expireAt,
    required this.amount,
    this.amountNumeric,
    required this.currency,
    required this.paymentMethod,
    required this.paymentMethodKey,
    required this.status,
    required this.statusKey,
    required this.date,
    this.caseDetails,
    required this.products,
  });

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      id: json['id'] ?? 0,
      paymentNumber: json['payment_number']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString(),
      clientReferenceId: json['client_reference_id']?.toString(),
      expireAt: json['expire_at']?.toString(),
      amount: json['amount']?.toString() ?? '',
      amountNumeric: json['amount_numeric']?.toString(),
      currency: json['currency']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentMethodKey: json['payment_method_key']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusKey: json['status_key']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      caseDetails: json['case'] != null ? PaymentCaseModel.fromJson(json['case']) : null,
      products: (json['products'] as List?)
              ?.map((e) => PaymentProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

class PaymentProductModel {
  final String name;
  final int quantity;
  final String amount;

  PaymentProductModel({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  factory PaymentProductModel.fromJson(Map<String, dynamic> json) {
    return PaymentProductModel(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      amount: json['amount']?.toString() ?? '',
    );
  }
}
