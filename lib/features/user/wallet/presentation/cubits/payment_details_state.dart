import '../../data/models/payment_details_model.dart';

abstract class PaymentDetailsState {}

class PaymentDetailsInitial extends PaymentDetailsState {}

class PaymentDetailsLoading extends PaymentDetailsState {}

class PaymentDetailsLoaded extends PaymentDetailsState {
  final PaymentDetailsModel paymentDetails;

  PaymentDetailsLoaded(this.paymentDetails);
}

class PaymentDetailsError extends PaymentDetailsState {
  final String message;

  PaymentDetailsError(this.message);
}
