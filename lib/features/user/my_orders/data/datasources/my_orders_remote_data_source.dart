import 'package:dio/dio.dart';
import 'package:hogga/features/user/my_orders/data/models/order_details.dart';
import 'package:hogga/features/user/my_orders/data/models/order_model.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_strings.dart';

abstract class MyOrdersRemoteDataSource {
  Future<List<MyOrderData>> getOrder({required String type});
  Future<OrderDetailsData> getOrderDetails({
    required int orderId,
    String? recordType,
  });
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
        queryParameters: {'type': 'all', 'status': 'all'},
      );

      final orderResponse = MyOrderResponse.fromJson(response.data);
      return _filterOrdersByTab(orderResponse.data, type);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load myOrders');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<OrderDetailsData> getOrderDetails({
    required int orderId,
    String? recordType,
  }) async {
    DioException? lastDioError;

    for (final candidate in _detailsEndpointCandidates(orderId, recordType)) {
      try {
        final response = await apiClient.get(candidate.path);
        final orderDetailsResponse = OrderDetailsResponse.fromJson(
          response.data,
        );
        var orderData = orderDetailsResponse.data;
        if (!orderData.isConsultation) {
          try {
            final proposalsResponse = await apiClient.get(
              AppEndPoints.legalCaseProposalsEndPoint(orderId),
            );
            dynamic listData = proposalsResponse.data;
            if (listData is Map && listData['data'] is List) {
              listData = listData['data'];
            }
            if (listData is List) {
              final proposals = listData
                  .whereType<Map>()
                  .map((e) =>
                      CaseProposal.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
              if (proposals.isNotEmpty || orderData.proposals.isEmpty) {
                orderData = orderData.copyWith(
                  proposals:
                      proposals.isNotEmpty ? proposals : orderData.proposals,
                );
              }
            }
          } catch (_) {}
        }
        return orderData;
      } on DioException catch (e) {
        lastDioError = e;
        if (!_shouldTryNextDetailsEndpoint(e)) {
          throw ServerFailure(
            _extractMessage(e.response?.data) ??
                e.message ??
                'Failed to load order details',
          );
        }
      }
    }

    throw ServerFailure(
      _extractMessage(lastDioError?.response?.data) ??
          lastDioError?.message ??
          'Failed to load order details',
    );
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
        data: {'rating': rating.clamp(1, 5), 'comment': comment},
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

  List<_DetailsEndpointCandidate> _detailsEndpointCandidates(
    int orderId,
    String? recordType,
  ) {
    final normalizedType = _normalizeRecordType(recordType);
    final candidates = <_DetailsEndpointCandidate>[];

    if (normalizedType == 'consultation') {
      candidates.add(_DetailsEndpointCandidate('consultations/$orderId'));
      candidates.add(
        _DetailsEndpointCandidate('services/legal-cases/$orderId'),
      );
      return candidates;
    }

    if (normalizedType == 'service') {
      candidates.add(
        _DetailsEndpointCandidate('services/legal-cases/$orderId'),
      );
      candidates.add(_DetailsEndpointCandidate('consultations/$orderId'));
      return candidates;
    }

    candidates.add(_DetailsEndpointCandidate('services/legal-cases/$orderId'));
    candidates.add(_DetailsEndpointCandidate('consultations/$orderId'));

    return candidates;
  }

  String? _normalizeRecordType(String? recordType) {
    final normalized = recordType?.trim().toLowerCase();
    if (normalized == 'consultation') return 'consultation';
    if (normalized == 'service' || normalized == 'legal_case') return 'service';
    return null;
  }

  bool _shouldTryNextDetailsEndpoint(DioException error) {
    final code = error.response?.statusCode;
    return code == null || code == 404 || code == 405;
  }

  String? _extractMessage(dynamic responseData) {
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }
    return null;
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

  List<MyOrderData> _filterOrdersByTab(List<MyOrderData> orders, String type) {
    switch (type.trim().toLowerCase()) {
      case 'ongoing':
      case 'active':
        return orders
            .where((order) => !_isTerminalStatus(order.status))
            .toList();
      case 'finished':
      case 'completed':
        return orders
            .where((order) => _isTerminalStatus(order.status))
            .toList();
      case 'all':
      default:
        return orders;
    }
  }

  bool _isTerminalStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'finished' ||
        normalized == 'completed' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'rejected' ||
        normalized == 'declined';
  }
}

class _DetailsEndpointCandidate {
  final String path;

  const _DetailsEndpointCandidate(this.path);
}
