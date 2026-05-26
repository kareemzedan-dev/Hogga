import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_strings.dart';

import '../../domin/repositories/my_orders_repository.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_details.dart';
import 'my_orders_states.dart';

class MyOrdersCubit extends Cubit<MyOrdersState> {
  final MyOrderRepository repository;
  List<MyOrderData>? currentOrders;
  Map<String, List<MyOrderData>> cachedOrders = {};
  OrderDetailsData? lastLoadedDetails;
  
  MyOrdersCubit({
    required this.repository,
  }) : super(MyOrdersInitial());

  Future<void> getMyOrders({required String type, bool forceRefresh = false}) async {
    if (!forceRefresh && cachedOrders.containsKey(type)) {
      currentOrders = cachedOrders[type];
      emit(MyOrdersLoaded(cachedOrders[type]!));
      return;
    }

    emit(MyOrdersLoading());
    final result = await repository.getOrder(type: type);
    result.fold(
      (failure) => emit(MyOrdersError(failure.message)),
      (orders) {
        cachedOrders[type] = orders;
        currentOrders = orders;
        emit(MyOrdersLoaded(orders));
      },
    );
  }

  Future<void> getOrderDetails({required int orderId}) async {
    emit(MyOrderDetailsLoading());
    final result = await repository.getOrderDetails(orderId: orderId);
    result.fold(
      (failure) => emit(MyOrderDetailsError(failure.message)),
      (details) {
        lastLoadedDetails = details;
        emit(MyOrderDetailsLoaded(details));
      },
    );
  }

  void restoreOrdersList() {
    if (currentOrders != null) {
      emit(MyOrdersLoaded(currentOrders!));
    } else {
      getMyOrders(type: 'ongoing');
    }
  }
}
