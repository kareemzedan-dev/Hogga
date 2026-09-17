import 'package:dio/dio.dart';
import 'package:hogga/core/constants/end_points.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/core/network/api_client.dart';
import 'package:hogga/features/lawyer/consultations/data/models/lawyer_consultation_model.dart';

abstract class LawyerConsultationsRemoteDataSource {
  Future<List<LawyerConsultationModel>> getConsultations();
  Future<LawyerConsultationModel> getConsultationDetails(int id);
  Future<String> completeConsultation(int id);
  Future<List<Map<String, dynamic>>> getConsultationPricing();
  Future<String> saveConsultationPricing({
    required String typeKey,
    required List<Map<String, dynamic>> prices,
  });
}

class LawyerConsultationsRemoteDataSourceImpl
    implements LawyerConsultationsRemoteDataSource {
  final ApiClient apiClient;

  const LawyerConsultationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LawyerConsultationModel>> getConsultations() async {
    try {
      final response = await apiClient.get(
        AppEndPoints.lawyerMyConsultationsEndPoint,
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      final rawList = responseData['data'] as List<dynamic>? ?? const [];
      return rawList
          .whereType<Map>()
          .map(
            (item) => LawyerConsultationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(_extractMessage(e, 'Failed to load consultations'));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LawyerConsultationModel> getConsultationDetails(int id) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.lawyerConsultationDetailsEndPoint(id),
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      return LawyerConsultationModel.fromJson(
        Map<String, dynamic>.from(responseData['data'] as Map),
      );
    } on DioException catch (e) {
      throw ServerFailure(
        _extractMessage(e, 'Failed to load consultation details'),
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> completeConsultation(int id) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.lawyerCompleteConsultationEndPoint(id),
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      final message = responseData['message']?.toString() ?? 'Success';
      if (responseData['status'] != true && responseData['success'] != true) {
        throw ServerFailure(message);
      }
      return message;
    } on DioException catch (e) {
      throw ServerFailure(
        _extractMessage(e, 'Failed to complete consultation'),
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getConsultationPricing() async {
    try {
      final response = await apiClient.get(
        AppEndPoints.lawyerConsultationsPricingGetEndPoint,
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      return (responseData['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(
        _extractMessage(e, 'Failed to load consultation pricing'),
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> saveConsultationPricing({
    required String typeKey,
    required List<Map<String, dynamic>> prices,
  }) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.lawyerConsultationPricingEndPoint,
        data: {'type_key': typeKey, 'prices': prices},
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      final message = responseData['message']?.toString() ?? 'Success';
      if (responseData['status'] != true && responseData['success'] != true) {
        throw ServerFailure(message);
      }
      return message;
    } on DioException catch (e) {
      throw ServerFailure(
        _extractMessage(e, 'Failed to save consultation prices'),
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? fallback;
  }
}
