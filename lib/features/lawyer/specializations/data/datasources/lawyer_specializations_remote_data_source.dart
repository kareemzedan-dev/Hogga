import 'package:dio/dio.dart';
import 'package:hogga/core/constants/end_points.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/core/network/api_client.dart';
import 'package:hogga/features/lawyer/specializations/data/models/lawyer_specialization_model.dart';

abstract class LawyerSpecializationsRemoteDataSource {
  Future<List<LawyerSpecializationCategoryModel>> getSpecializations();
  Future<String> updateSpecializations(List<int> specializationIds);
}

class LawyerSpecializationsRemoteDataSourceImpl
    implements LawyerSpecializationsRemoteDataSource {
  final ApiClient apiClient;

  const LawyerSpecializationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LawyerSpecializationCategoryModel>> getSpecializations() async {
    try {
      final response = await apiClient.get(
        AppEndPoints.lawyerMySpecializationsEndPoint,
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      return (responseData['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LawyerSpecializationCategoryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(_extractMessage(e, 'Failed to load specializations'));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> updateSpecializations(List<int> specializationIds) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.lawyerUpdateSpecializationsEndPoint,
        data: {'legal_specializations': specializationIds},
      );
      final responseData = Map<String, dynamic>.from(response.data as Map);
      final message =
          responseData['message']?.toString() ?? 'تم تحديث تخصصاتك بنجاح.';
      if (responseData['status'] != true && responseData['success'] != true) {
        throw ServerFailure(message);
      }
      return message;
    } on DioException catch (e) {
      throw ServerFailure(
        _extractMessage(e, 'Failed to update specializations'),
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        for (final val in errors.values) {
          if (val is List && val.isNotEmpty) {
            return val.first.toString();
          } else if (val != null) {
            return val.toString();
          }
        }
      }
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
    }
    return e.message ?? fallback;
  }
}
