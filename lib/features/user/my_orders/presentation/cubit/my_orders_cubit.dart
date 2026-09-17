import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domin/repositories/my_orders_repository.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_details.dart';
import 'my_orders_states.dart';

class MyOrdersCubit extends Cubit<MyOrdersState> {
  final MyOrderRepository repository;
  List<MyOrderData>? currentOrders;
  Map<String, List<MyOrderData>> cachedOrders = {};
  OrderDetailsData? lastLoadedDetails;

  MyOrdersCubit({required this.repository}) : super(MyOrdersInitial());

  Future<void> getMyOrders({
    required String type,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && cachedOrders.containsKey(type)) {
      currentOrders = cachedOrders[type];
      emit(MyOrdersLoaded(cachedOrders[type]!));
      return;
    }

    emit(MyOrdersLoading());
    final result = await repository.getOrder(type: type);
    result.fold((failure) => emit(MyOrdersError(failure.message)), (orders) {
      cachedOrders[type] = orders;
      currentOrders = orders;
      emit(MyOrdersLoaded(orders));
    });
  }

  Future<void> getOrderDetails({
    required int orderId,
    String? recordType,
  }) async {
    emit(MyOrderDetailsLoading());
    final result = await repository.getOrderDetails(
      orderId: orderId,
      recordType: recordType,
    );
    result.fold((failure) => emit(MyOrderDetailsError(failure.message)), (
      details,
    ) {
      lastLoadedDetails = details;
      emit(MyOrderDetailsLoaded(details));
    });
  }

  void restoreOrdersList() {
    if (currentOrders != null) {
      emit(MyOrdersLoaded(currentOrders!));
    } else {
      getMyOrders(type: 'ongoing');
    }
  }

  /// Immediately removes an order from the local cache and updates the UI.
  void removeOrderById(int orderId) {
    if (currentOrders != null) {
      currentOrders = currentOrders!.where((o) => o.id != orderId).toList();
      // Also update all cached tabs
      cachedOrders.updateAll(
        (key, list) => list.where((o) => o.id != orderId).toList(),
      );
      emit(MyOrdersLoaded(currentOrders!));
    }
  }

  Future<void> payLegalCase({
    required int orderId,
    required String caseNumber,
    String recordType = 'service',
  }) async {
    emit(MyOrderPaymentLoading());
    final result = await repository.payLegalCase(orderId: orderId);
    result.fold(
      (failure) {
        emit(MyOrderPaymentError(failure.message));
        restoreOrdersList();
      },
      (paymentUrl) {
        emit(
          MyOrderPaymentSuccess(paymentUrl, caseNumber, orderId, recordType),
        );
        restoreOrdersList();
      },
    );
  }

  Future<String?> rateProvider({
    required int providerId,
    required int rating,
    required String comment,
  }) async {
    final result = await repository.rateProvider(
      providerId: providerId,
      rating: rating,
      comment: comment,
    );
    return result.fold((failure) => failure.message, (_) => null);
  }
}
