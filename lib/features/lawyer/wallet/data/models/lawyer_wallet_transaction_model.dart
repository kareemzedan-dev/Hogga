import 'package:hogga/features/lawyer/wallet/domain/entities/lawyer_wallet_transaction.dart';

class LawyerWalletTransactionModel extends LawyerWalletTransaction {
  LawyerWalletTransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.isIncome,
    super.transactionType,
    super.notes,
  });

  factory LawyerWalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString().toLowerCase();
    final transactionType = json['transaction_type']?.toString();
    final bool isIncome = json['isIncome'] ??
        (type == 'credit' ||
            json['is_income'] == true ||
            transactionType == 'referral_bonus');

    final String title = json['notes']?.toString() ??
        json['title']?.toString() ??
        json['description']?.toString() ??
        '';

    final String date = json['date']?.toString() ??
        json['created_at']?.toString() ??
        '';

    return LawyerWalletTransactionModel(
      id: json['id']?.toString() ?? '',
      title: title,
      amount: json['amount']?.toString() ?? '0',
      date: date.length >= 10 ? date.substring(0, 10) : date,
      isIncome: isIncome,
      transactionType: transactionType,
      notes: json['notes']?.toString(),
    );
  }
}
