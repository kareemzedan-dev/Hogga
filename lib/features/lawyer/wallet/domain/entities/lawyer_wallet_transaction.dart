class LawyerWalletTransaction {
  final String id;
  final String title;
  final String amount;
  final String date;
  final bool isIncome;

  LawyerWalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}
