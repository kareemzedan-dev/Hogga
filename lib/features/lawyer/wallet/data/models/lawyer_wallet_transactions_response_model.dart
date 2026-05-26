import 'lawyer_wallet_transaction_model.dart';

class LawyerWalletTransactionsResponseModel {
  final int currentPage;
  final int lastPage;
  final List<LawyerWalletTransactionModel> data;
  final int total;

  LawyerWalletTransactionsResponseModel({
    required this.currentPage,
    required this.lastPage,
    required this.data,
    required this.total,
  });

  factory LawyerWalletTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return LawyerWalletTransactionsResponseModel(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => LawyerWalletTransactionModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}
