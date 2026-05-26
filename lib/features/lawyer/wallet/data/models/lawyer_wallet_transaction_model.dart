import 'package:hogga/features/lawyer/wallet/domain/entities/lawyer_wallet_transaction.dart';

class LawyerWalletTransactionModel extends LawyerWalletTransaction {
  LawyerWalletTransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.isIncome,
  });

  factory LawyerWalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return LawyerWalletTransactionModel(
      id: json['id'].toString(),
      title: json['title'],
      amount: json['amount'].toString(),
      date: json['date'],
      isIncome: json['isIncome'] ?? true,
    );
  }
}
