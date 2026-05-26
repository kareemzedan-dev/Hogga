import 'package:dio/dio.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/contact_us_model.dart';
import '../models/instructions_model.dart';
import '../models/privacy_policy_model.dart';

abstract class MoreRemoteDataSource {
  Future<ContactUsModel> getContactInfo();
  Future<InstructionsModel> getInstructions();
  Future<PrivacyPolicyModel> getPrivacyPolicy();
}

class MoreRemoteDataSourceImpl implements MoreRemoteDataSource {
  final ApiClient apiClient;

  MoreRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ContactUsModel> getContactInfo() async {
    try {
      final response = await apiClient.get(AppEndPoints.contactUsEndPoint);
      return ContactUsModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to load contact info';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<InstructionsModel> getInstructions() async {
    try {
      final response = await apiClient.get(AppEndPoints.instructionsEndPoint);
      return InstructionsModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to load instructions';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PrivacyPolicyModel> getPrivacyPolicy() async {
    try {
      final response = await apiClient.get(AppEndPoints.privacyEndPoint);
      return PrivacyPolicyModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to load privacy policy';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
