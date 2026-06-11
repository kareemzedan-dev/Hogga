import '../../data/models/payment_model.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<PaymentModel> payments;

  WalletLoaded(this.payments);
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
