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

  static bool _determineIsIncome(Map<String, dynamic> json) {
    if (json['is_income'] is bool) return json['is_income'];
    if (json['isIncome'] is bool) return json['isIncome'];

    final type = json['type']?.toString().toLowerCase() ?? '';
    final transactionType =
        json['transaction_type']?.toString().toLowerCase() ?? '';

    // Check balance movement if available
    final double? before =
        double.tryParse(json['balance_before']?.toString() ?? '');
    final double? after =
        double.tryParse(json['balance_after']?.toString() ?? '');
    if (before != null && after != null && before != after) {
      return after > before;
    }

    // Explicit credit indicators (e.g. booking_credit, credit, deposit, earning)
    if (type.contains('credit') ||
        type == 'income' ||
        type == 'deposit' ||
        type == 'earning') {
      return true;
    }

    // Explicit debit indicators (e.g. payout_debit, debit, expense, withdrawal)
    if (type.contains('debit') ||
        type == 'expense' ||
        type == 'withdrawal' ||
        type == 'payout') {
      return false;
    }

    // Check transaction_type (e.g. project_earning, referral_bonus)
    if (transactionType.contains('earning') ||
        transactionType.contains('credit') ||
        transactionType.contains('bonus') ||
        transactionType.contains('deposit') ||
        transactionType.contains('income')) {
      return true;
    }

    if (transactionType.contains('withdrawal') ||
        transactionType.contains('debit') ||
        transactionType.contains('payout')) {
      return false;
    }

    // Check notes / title in Arabic keywords
    final notes = (json['notes']?.toString() ?? json['title']?.toString() ?? '')
        .toLowerCase();
    if (notes.contains('أرباح') ||
        notes.contains('ارباح') ||
        notes.contains('إيداع') ||
        notes.contains('ايداع') ||
        notes.contains('مكافأة') ||
        notes.contains('مكافاه')) {
      return true;
    }
    if (notes.contains('سحب') || notes.contains('خصم')) {
      return false;
    }

    return false;
  }

  factory LawyerWalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final transactionType = json['transaction_type']?.toString();
    final bool isIncome = _determineIsIncome(json);

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
