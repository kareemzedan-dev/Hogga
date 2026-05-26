import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_model.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_details_model.dart';

abstract class RequestsRemoteDataSource {
  Future<List<LawyerCaseRequestModel>> getCaseRequests();
  Future<LawyerCaseRequestDetailsModel> getCaseRequestDetails(int requestId);
  Future<String> acceptRequest(int requestId);
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

  @override
  Future<String> acceptRequest(int requestId) async {
    final response = await apiClient.post("${AppEndPoints.lawyerRequestsEndPoint}/$requestId/accept");
    return response.data['message'];
  }

  @override
  Future<String> rejectRequest(int requestId) async {
    final response = await apiClient.post("${AppEndPoints.lawyerRequestsEndPoint}/$requestId/reject");
    return response.data['message'];
  }
}
