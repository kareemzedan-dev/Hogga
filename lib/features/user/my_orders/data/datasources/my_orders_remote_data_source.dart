import 'package:dio/dio.dart';
import 'package:hogga/features/user/my_orders/data/models/order_details.dart';
import 'package:hogga/features/user/my_orders/data/models/order_model.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_strings.dart';

abstract class MyOrdersRemoteDataSource {
  Future<List<MyOrderData>> getOrder({required String type});
  Future<OrderDetailsData> getOrderDetails({required int orderId});
  Future<String> payLegalCase({required int orderId});
  Future<void> rateProvider({
    required int providerId,
    required int rating,
    required String comment,
  });
}

class MyOrdersRemoteDataSourceImpl implements MyOrdersRemoteDataSource {
  final ApiClient apiClient;

  MyOrdersRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MyOrderData>> getOrder({required String type}) async {
    try {
      final response = await apiClient.get(
        'services/legal-cases',
        queryParameters: {'type': type},
      );

      final orderResponse = MyOrderResponse.fromJson(response.data);
      return orderResponse.data;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load myOrders');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<OrderDetailsData> getOrderDetails({required int orderId}) async {
    try {
      final response = await apiClient.get('services/legal-cases/$orderId');

      final orderDetailsResponse = OrderDetailsResponse.fromJson(response.data);
      return orderDetailsResponse.data;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load order details');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> payLegalCase({required int orderId}) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.payLegalCaseEndPoint(orderId),
      );
      if (response.data['status'] == true) {
        final paymentUrl = _readPaymentUrl(response.data);
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          return paymentUrl;
        }
        throw const ServerFailure(AppStrings.paymentLinkUnavailable);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to initiate payment',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to initiate payment');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> rateProvider({
    required int providerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.rateProviderEndPoint(providerId),
        data: {'rating': rating.clamp(0, 5), 'comment': comment},
      );
      if (response.data is Map && response.data['status'] == false) {
        throw ServerFailure(
          response.data['message']?.toString() ?? 'Failed to submit rating',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to submit rating');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  String? _readPaymentUrl(dynamic responseData) {
    if (responseData is! Map) return null;

    final root = Map<String, dynamic>.from(responseData);
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    for (final key in const [
      'payment_url',
      'payment_link',
      'paymentUrl',
      'redirect_url',
      'checkout_url',
      'invoice_url',
      'url',
    ]) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }

    final payment = data['payment'];
    if (payment is Map) {
      for (final key in const [
        'payment_url',
        'payment_link',
        'redirect_url',
        'checkout_url',
        'invoice_url',
        'url',
      ]) {
        final value = payment[key]?.toString().trim();
        if (value != null && value.isNotEmpty && value != 'null') {
          return value;
        }
      }
    }

    return null;
  }
}
