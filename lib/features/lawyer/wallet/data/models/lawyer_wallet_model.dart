import 'package:hogga/features/lawyer/wallet/domain/entities/lawyer_wallet.dart';

class LawyerWalletModel extends LawyerWallet {
  const LawyerWalletModel({
    required super.balance,
    required super.pendingBalance,
    required super.remainingBalance,
    required super.totalSent,
    required super.currency,
  });

  factory LawyerWalletModel.fromJson(Map<String, dynamic> json) {
    return LawyerWalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      pendingBalance: (json['pending_balance'] ?? 0).toDouble(),
      remainingBalance: (json['remaining_balance'] ?? 0).toDouble(),
      totalSent: (json['total_sent'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
    );
  }
}
