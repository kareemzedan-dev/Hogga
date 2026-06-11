import 'payment_model.dart';

class WalletResponseModel {
  final List<PaymentModel> data;

  WalletResponseModel({required this.data});

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = rawData is List ? rawData : <dynamic>[];
    return WalletResponseModel(
      data: list
          .whereType<Map>()
          .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
