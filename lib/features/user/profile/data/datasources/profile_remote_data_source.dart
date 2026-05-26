import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../shared/auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? gender,
    String? accountType,
  });
  Future<String> updateAvatar(File image);
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get(AppEndPoints.getProfileEndPoint);
      final data = response.data['data'] ?? response.data['user'] ?? response.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to load profile';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? gender,
    String? accountType,
  }) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.updateProfileEndPoint,
        data: {
          'name': name,
          'email': email,
          'gender': gender,
          'account_type': accountType,
        },
      );
      final data = response.data['user'] ?? response.data['data'] ?? response.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to update profile';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> updateAvatar(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await apiClient.post(
        AppEndPoints.updateAvatarEndPoint,
        data: formData,
      );
      return response.data['photo_url'];
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to upload image';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.updatePasswordEndPoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );
      return response.data['message'] ?? 'Password changed successfully.';
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Failed to update password';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
