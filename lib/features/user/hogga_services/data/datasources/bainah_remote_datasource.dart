import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_strings.dart';
import '../models/item_category_model.dart';
import '../models/legal_case_models.dart';

abstract class HoggaRemoteDataSource {
  Future<ItemCategoryModel> getItemCategories({
    required int childCategoryId,
    int? subCategoryId,
  });
  Future<CouponVerificationModel> verifyCoupon(String code);
  Future<List<ConsultationLawyerModel>> getConsultationLawyers(
    int categorySubId, {
    String? coupon,
  });
  Future<List<ConsultationLawyerModel>> getCouponLawyers(String code);
  Future<List<ConsultationPriceModel>> getConsultationLawyerPrices({
    required int lawyerId,
    required int categorySubId,
  });
  Future<LegalCaseResponse> bookConsultation(BookConsultationRequest request);
  Future<LegalCaseResponse> completeConsultation(int consultationId);
  Future<LegalCaseResponse> createLegalCase(CreateLegalCaseRequest request);
  Future<LegalCaseResponse> uploadLegalCaseDocuments(
    UploadLegalCaseDocumentsRequest request,
  );
  Future<AcceptProposalResponse> acceptProposal(
    int proposalId, {
    String paymentMethod = 'card',
  });
  Future<LegalCaseResponse> completeLegalCase(int caseId);
  Future<LegalCaseResponse> cancelLegalCase(int caseId);
}

class HoggaRemoteDataSourceImpl implements HoggaRemoteDataSource {
  final ApiClient apiClient;

  HoggaRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ItemCategoryModel> getItemCategories({
    required int childCategoryId,
    int? subCategoryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'categories_child_id': childCategoryId,
        if (subCategoryId != null && subCategoryId > 0)
          'categories_sub_id': subCategoryId,
      };
      final response = await apiClient.get(
        AppEndPoints.itemCategoriesEndPoint,
        queryParameters: queryParameters,
      );
      return ItemCategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Failed to load items';
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
      final message =
          e.response?.data['message'] ?? e.message ?? 'Failed to verify coupon';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ConsultationLawyerModel>> getConsultationLawyers(
    int categorySubId, {
    String? coupon,
  }) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.consultationLawyersEndPoint,
        queryParameters: {
          'category_sub_id': categorySubId,
          if (coupon != null && coupon.trim().isNotEmpty)
            'coupon': coupon.trim(),
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ConsultationLawyerModel.fromJson)
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to load consultation lawyers';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ConsultationLawyerModel>> getCouponLawyers(String code) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.couponLawyersEndPoint,
        queryParameters: {'code': code},
      );
      final responseData = response.data as Map<String, dynamic>;
      return _readLawyersList(
        responseData['data'],
      ).map(ConsultationLawyerModel.fromJson).toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to load coupon lawyers';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  List<Map<String, dynamic>> _readLawyersList(dynamic data) {
    if (data is List<dynamic>) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      for (final key in const ['lawyers', 'providers', 'items', 'data']) {
        final value = data[key];
        if (value is List<dynamic>) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  @override
  Future<List<ConsultationPriceModel>> getConsultationLawyerPrices({
    required int lawyerId,
    required int categorySubId,
  }) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.consultationLawyerPricesEndPoint(lawyerId),
        queryParameters: {'category_sub_id': categorySubId},
      );
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? const {};
      return (data['prices'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ConsultationPriceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to load consultation prices';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> bookConsultation(
    BookConsultationRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.bookConsultationEndPoint,
        data: request.toJson(),
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to book consultation';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> completeConsultation(int consultationId) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.completeConsultationEndPoint(consultationId),
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to complete consultation';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> createLegalCase(
    CreateLegalCaseRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.storeServiceEndPoint,
        data: request.toJson(),
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to create legal case';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> uploadLegalCaseDocuments(
    UploadLegalCaseDocumentsRequest request,
  ) async {
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
      var message =
          e.response?.data['message']?.toString() ??
          e.message ??
          'Failed to upload files';
      if (message.contains('must be a file of type') ||
          (message.contains('files.') && message.contains('type'))) {
        message = AppStrings.unsupportedFileFormat;
      }
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AcceptProposalResponse> acceptProposal(
    int proposalId, {
    String paymentMethod = 'card',
  }) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.acceptLegalCaseProposalEndPoint,
        data: {'proposal_id': proposalId, 'payment_method': paymentMethod},
      );
      return AcceptProposalResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to accept proposal';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LegalCaseResponse> completeLegalCase(int caseId) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.completeLegalCaseEndPoint(caseId),
      );
      return LegalCaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to complete service';
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
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Failed to cancel legal case';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
