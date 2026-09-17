import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_model.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_details_model.dart';

abstract class RequestsRemoteDataSource {
  Future<List<LawyerCaseRequestModel>> getCaseRequests();
  Future<LawyerCaseRequestDetailsModel> getCaseRequestDetails(int requestId);
  Future<String> acceptRequest({
    required int requestId,
    required double price,
    String? description,
  });
  Future<String> rejectRequest(int requestId);
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final ApiClient apiClient;

  RequestsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<LawyerCaseRequestModel>> getCaseRequests() async {
    final response = await apiClient.get(AppEndPoints.lawyerRequestsEndPoint);
    return (response.data['data'] as List).map((e) => LawyerCaseRequestModel.fromJson(e)).toList();
  }

  @override
  Future<LawyerCaseRequestDetailsModel> getCaseRequestDetails(int requestId) async {
    final response = await apiClient.get("${AppEndPoints.lawyerRequestsEndPoint}/$requestId");
    return LawyerCaseRequestDetailsModel.fromJson(response.data['data']);
  }

  bool _isSuccess(dynamic data, int? statusCode) {
    if (data is Map) {
      final status = data['status'];
      final success = data['success'];
      if (status == false || status == 0 || status == 'error' || status == 'false') {
        return false;
      }
      if (success == false || success == 0 || success == 'false') {
        return false;
      }
      if (status == true ||
          status == 1 ||
          status == 'success' ||
          status == 'true' ||
          success == true ||
          success == 1 ||
          success == 'success' ||
          success == 'true') {
        return true;
      }
    }
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        } else if (first != null) {
          return first.toString();
        }
      }
      final msg = data['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    }
    return fallback;
  }

  String _extractSuccessMessage(dynamic data, String fallback) {
    if (data is Map) {
      final msg = data['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    }
    return fallback;
  }

  @override
  Future<String> acceptRequest({
    required int requestId,
    required double price,
    String? description,
  }) async {
    final response = await apiClient.post(
      "${AppEndPoints.lawyerRequestsEndPoint}/$requestId/accept",
      data: {
        'price': price,
        'offer_price': price,
        if (description != null && description.trim().isNotEmpty) ...{
          'description': description.trim(),
          'notes': description.trim(),
        },
      },
    );
    final data = response.data;
    if (!_isSuccess(data, response.statusCode)) {
      throw ServerFailure(
        _extractErrorMessage(data, 'هذا الطلب لم يعد متاحاً'),
      );
    }
    return _extractSuccessMessage(data, 'تم قبول الطلب بنجاح');
  }

  @override
  Future<String> rejectRequest(int requestId) async {
    final response = await apiClient.post(
      "${AppEndPoints.lawyerRequestsEndPoint}/$requestId/reject",
    );
    final data = response.data;
    if (!_isSuccess(data, response.statusCode)) {
      throw ServerFailure(
        _extractErrorMessage(data, 'فشل رفض الطلب'),
      );
    }
    return _extractSuccessMessage(data, 'تم رفض الطلب بنجاح');
  }
}
