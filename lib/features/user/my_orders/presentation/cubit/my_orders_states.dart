import 'package:hogga/features/user/my_orders/data/models/order_model.dart';
import 'package:hogga/features/user/my_orders/data/models/order_details.dart';

abstract class MyOrdersState {}

class MyOrdersInitial extends MyOrdersState {}

class MyOrdersLoading extends MyOrdersState {}

class MyOrdersLoaded extends MyOrdersState {
  final List<MyOrderData> orders;
  MyOrdersLoaded(this.orders);
}

class MyOrdersError extends MyOrdersState {
  final String message;
  MyOrdersError(this.message);
}

class MyOrderDetailsLoading extends MyOrdersState {}

class MyOrderDetailsLoaded extends MyOrdersState {
  final OrderDetailsData orderDetails;
  MyOrderDetailsLoaded(this.orderDetails);
}

class MyOrderDetailsError extends MyOrdersState {
  final String message;
  MyOrderDetailsError(this.message);
}

class MyOrderPaymentLoading extends MyOrdersState {}

class MyOrderPaymentSuccess extends MyOrdersState {
  final String paymentUrl;
  final String caseNumber;
  final int caseId;

  MyOrderPaymentSuccess(this.paymentUrl, this.caseNumber, this.caseId);
}

class MyOrderPaymentError extends MyOrdersState {
  final String message;
  MyOrderPaymentError(this.message);
}
