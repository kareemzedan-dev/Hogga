import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/item_category_model.dart';
import '../models/legal_case_models.dart';

abstract class hoggaRemoteDataSource {
  Future<ItemCategoryModel> getItemCategories(int childCategoryId);
  Future<CouponVerificationModel> verifyCoupon(String code);
  Future<LegalCaseResponse> createLegalCase(CreateLegalCaseRequest request);
  Future<LegalCaseResponse> uploadLegalCaseDocuments(UploadLegalCaseDocumentsRequest request);
  Future<AcceptProposalResponse> acceptProposal(int proposalId);
  Future<LegalCaseResponse> cancelLegalCase(int caseId);
}

class hoggaRemoteDataSourceImpl implements hoggaRemoteDataSource {
  final ApiClient apiClient;

  hoggaRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ItemCategoryModel> getItemCategories(int childCategoryId) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.itemCategoriesEndPoint,
        queryParameters: {'categories_child_id': childCategoryId},
      );
      return ItemCategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to load items';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<CouponVerificationModel> verifyCoupon(String code) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.verifyServiceCouponEndPoint,
        data: {'code': code},
      );
      return CouponVerificationModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to verify coupon';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> createLegalCase(CreateLegalCaseRequest request) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.storeServiceEndPoint,
        data: request.toJson(),
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to create legal case';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> uploadLegalCaseDocuments(UploadLegalCaseDocumentsRequest request) async {
    if (request.files.isEmpty) {
      throw const ServerFailure('The files field is required.');
    }
    if (request.files.length != request.titles.length) {
      throw const ServerFailure('Titles count must match files count.');
    }

    for (final file in request.files) {
      final length = await file.length();
      if (length > 2 * 1024 * 1024) {
        throw const ServerFailure('Each file must be 2 MB or less.');
      }
    }

    try {
      final Map<String, dynamic> payload = {'case_id': request.caseId};
      for (var i = 0; i < request.titles.length; i++) {
        payload['titles[$i]'] = request.titles[i];
      }
      for (var i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        payload['files[$i]'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      }

      final response = await apiClient.post(
        AppEndPoints.uploadLegalCaseFilesEndPoint,
        data: FormData.fromMap(payload),
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to upload files';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AcceptProposalResponse> acceptProposal(int proposalId) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.acceptLegalCaseProposalEndPoint,
        data: {'proposal_id': proposalId},
      );
      return AcceptProposalResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to accept proposal';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> cancelLegalCase(int caseId) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.cancelLegalCaseEndPoint,
        data: {'case_id': caseId},
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to cancel legal case';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
