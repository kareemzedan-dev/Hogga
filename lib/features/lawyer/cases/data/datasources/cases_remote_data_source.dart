import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_model.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_details_model.dart';

abstract class CasesRemoteDataSource {
  Future<List<LawyerCaseModel>> getCases({String? type});
  Future<LawyerCaseDetailsModel> getCaseDetails(int caseId);
  Future<bool> addCaseSession({
    required int caseId,
    required String title,
    required String date,
    required String details,
  });
  Future<bool> uploadCaseDocument({
    required int caseId,
    required String title,
    required File document,
  });
}

class CasesRemoteDataSourceImpl implements CasesRemoteDataSource {
  final ApiClient apiClient;

  CasesRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<LawyerCaseModel>> getCases({String? type}) async {
    final response = await apiClient.get(
      AppEndPoints.lawyerCasesEndPoint,
      queryParameters: type != null ? {'type': type} : null,
    );
    return (response.data['data'] as List).map((e) => LawyerCaseModel.fromJson(e)).toList();
  }

  @override
  Future<LawyerCaseDetailsModel> getCaseDetails(int caseId) async {
    final response = await apiClient.get("${AppEndPoints.lawyerCasesEndPoint}/$caseId");
    return LawyerCaseDetailsModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> addCaseSession({
    required int caseId,
    required String title,
    required String date,
    required String details,
  }) async {
    final response = await apiClient.post(
      "${AppEndPoints.lawyerCasesEndPoint}/$caseId/updates",
      data: {
        'title': title,
        'session_date': date,
        'details': details,
      },
    );
    return response.data['status'] == true;
  }

  @override
  Future<bool> uploadCaseDocument({
    required int caseId,
    required String title,
    required File document,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'document': await MultipartFile.fromFile(document.path),
    });

    final response = await apiClient.post(
      "${AppEndPoints.lawyerCasesEndPoint}/documents/$caseId",
      data: formData,
    );
    return response.data['status'] == true;
  }
}
