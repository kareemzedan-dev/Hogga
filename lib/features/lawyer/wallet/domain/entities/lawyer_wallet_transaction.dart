class LawyerWalletTransaction {
  final String id;
  final String title;
  final String amount;
  final String date;
  final bool isIncome;
  final String? transactionType;
  final String? notes;

  LawyerWalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.transactionType,
    this.notes,
  });

  bool get isReferralBonus => transactionType?.toLowerCase() == 'referral_bonus';
}
