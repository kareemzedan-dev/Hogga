import 'package:equatable/equatable.dart';

class LawyerWallet extends Equatable {
  final double balance;
  final double pendingBalance;
  final double remainingBalance;
  final double totalSent;
  final String currency;

  const LawyerWallet({
    required this.balance,
    required this.pendingBalance,
    required this.remainingBalance,
    required this.totalSent,
    required this.currency,
  });

  @override
  List<Object?> get props => [balance, pendingBalance, remainingBalance, totalSent, currency];
}
