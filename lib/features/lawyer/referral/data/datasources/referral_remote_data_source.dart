import 'package:dio/dio.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/referral_code_model.dart';
import '../models/referral_history_model.dart';

abstract class ReferralRemoteDataSource {
  Future<ReferralCodeModel> getMyReferralCode();
  Future<ReferralHistoryPageModel> getReferralHistory({int page = 1});
}

class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  final ApiClient apiClient;

  ReferralRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReferralCodeModel> getMyReferralCode() async {
    try {
      final response = await apiClient.get(AppEndPoints.lawyerReferralMyCodeEndPoint);
      final responseData = response.data;
      if (responseData['status'] == true || responseData['success'] == true) {
        final data = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(responseData['data'] ?? {});
        return ReferralCodeModel.fromJson(data);
      } else {
        throw ServerFailure(responseData['message']?.toString() ?? 'Failed to get referral code');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final msg = e.response?.data['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          throw ServerFailure(msg);
        }
      }
      throw ServerFailure(e.message ?? 'Unknown error occurred');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ReferralHistoryPageModel> getReferralHistory({int page = 1}) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.lawyerReferralHistoryEndPoint,
        queryParameters: {'page': page},
      );
      final responseData = response.data;
      if (responseData['status'] == true || responseData['success'] == true) {
        final data = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(responseData['data'] ?? {});
        return ReferralHistoryPageModel.fromJson(data);
      } else {
        throw ServerFailure(responseData['message']?.toString() ?? 'Failed to get referral history');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final msg = e.response?.data['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          throw ServerFailure(msg);
        }
      }
      throw ServerFailure(e.message ?? 'Unknown error occurred');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}
