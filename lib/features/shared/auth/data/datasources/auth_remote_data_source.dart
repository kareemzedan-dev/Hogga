import 'package:dio/dio.dart';

import '../../../../../config/shared_preference/shared_preference.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/login_success.dart';
import '../models/lawyer_registration_models.dart';
import '../models/registratoin_success.dart';
import '../models/user_model.dart';
import '../models/app_config.dart';
import '../../../../../core/utils/app_strings.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResult> login(String identifier, String password, {bool isLawyer = false});
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String accountType,
    required bool termsAccepted,
    required String registerAs,
  });
  Future<void> logout();
  Future<void> resetPassword({required String phone, required String otpCode, required String password});
  Future<LoginResult> verifyOtp(String phone, String otp, {bool isLawyer = false});
  Future<void> resendOtp(String phone, type, {bool isLawyer = false});
  Future<List<ProviderTypeModel>> getLawyerProviderTypes();
  Future<List<LegalSpecializationModel>> getLawyerSpecializations();
  Future<LawyerRegistrationDraft> registerLawyer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String civilId,
    required String city,
    required String level,
    required String experienceYears,
    required int providerTypeId,
    required List<int> specializationIds,
    required String imagePath,
  });
  Future<LawyerProfileCompletionResult> completeLawyerProfile({
    required Map<String, dynamic> metadata,
  });
  Future<void> updateToken(String fcmToken);
  Future<AppConfig> getAppConfig();
  // Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LoginResult> login(String identifier, String password, {bool isLawyer = false}) async {
    try {
      final response = await apiClient.post(
        isLawyer ? AppEndPoints.lawyerLoginEndPoint : AppEndPoints.loginEndPoint,
        data: {
          'phone': identifier,
          'password': password,
        },
      );

      final responseData = response.data;
      
      if (responseData['success'] == true) {
        final data = responseData['data'];
        if (data != null && data['token'] != null) {
          await AppPreferences().saveToken(data['token']);
          
          final userMap = Map<String, dynamic>.from(data['user']);
          userMap['token'] = data['token'];
          userMap['is_provider'] = data['is_provider'] == true;
          userMap['provider_type_name'] = userMap['provider_type_name'] ?? data['provider_type_name'];
          userMap['specializations'] = userMap['specializations'] ?? const [];
          if (data['is_provider'] == true && (userMap['role'] == null || userMap['role'].toString().isEmpty)) {
            userMap['role'] = 'provider';
          }

          return LoginSuccess(
            UserModel.fromJson(userMap),
          );
        } else if (data != null && data['email'] != null) {
          return LoginNeedVerification(data['email']);
        } else {
          throw AuthFailure(responseData['message'] ?? AppStrings.loginFailed);
        }
      } else {
        throw AuthFailure(responseData['message'] ?? AppStrings.loginFailed);
      }

    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final msg = _extractErrorMessage(e, AppStrings.errorUnrecognized);

        if (msg.contains('غير مفعل')) {
          return LoginNeedVerification(identifier);
        }

        throw AuthFailure(msg);
      }

      throw ServerFailure(e.message ?? AppStrings.errorServer);

    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
  @override
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String accountType,
    required bool termsAccepted,
    required String registerAs,
  }) async
  {
    try {
      final response = await apiClient.post(
        AppEndPoints.registerEndPoint,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'account_type': accountType,
          'terms_accepted': termsAccepted,
          'register': registerAs,
        },
      );

      final responseData = response.data;

      if (responseData['success'] == true) {
        final message = responseData['message']?.toString() ?? '';

        if (message.contains('تفعيل') || message.contains('verify')) {
          return RegisterNeedVerification(phone);
        }

        final data = responseData['data'];
        if (data != null && data['user'] != null) {
          if (data['token'] != null) {
            await AppPreferences().saveToken(data['token']);
          }
          final userMap = Map<String, dynamic>.from(data['user']);
          if (data['token'] != null) {
            userMap['token'] = data['token'];
          }
          return RegisterSuccess(
            UserModel.fromJson(userMap),
          );
        }

        throw AuthFailure(responseData['message'] ?? AppStrings.errorRegistrationFailed);
      } else {
        throw AuthFailure(responseData['message'] ?? AppStrings.errorRegistrationFailed);
      }

    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw AuthFailure(_extractErrorMessage(e, AppStrings.errorRegistrationFailed));
      }
      throw ServerFailure(
        e.message ?? AppStrings.errorRegistrationFailed,
      );
    } catch (e) {
      throw ServerFailure(AppStrings.errorServer);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(AppEndPoints.logoutEndPoint);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Logout failed');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String phone, required String otpCode, required String password}) async {
    try {
      await apiClient.post(
        AppEndPoints.resetPasswordEndPoint,
        data: {
          'phone': phone,
          'otp_code': otpCode,
          'password': password,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 || e.response?.statusCode == 403) {
        throw AuthFailure(_extractErrorMessage(e, AppStrings.errorResetPasswordFailed));
      }
      throw ServerFailure(e.message ?? AppStrings.errorResetPasswordFailed);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LoginResult> verifyOtp(String phone, String otp, {bool isLawyer = false}) async {
    try {
      final respond = await apiClient.post(
        isLawyer ? AppEndPoints.lawyerVerifyOtpEndPoint : AppEndPoints.verifyOtpEndPoint,
        data: {
          'phone': phone,
          'otp_code': otp,
        },
      );
      if (respond.data['success'] == true) {
        final responseData = respond.data;
        final data = responseData['data'];

        if (data != null && data['token'] != null) {
          await AppPreferences().saveToken(data['token']);
          final userMap = Map<String, dynamic>.from(data['user']);
          userMap['token'] = data['token'];
          userMap['is_provider'] = data['is_provider'] == true;
          if (data['is_provider'] == true && (userMap['role'] == null || userMap['role'].toString().isEmpty)) {
            userMap['role'] = 'provider';
          }
          return LoginSuccess(
            UserModel.fromJson(userMap),
          );
        } else {
          return OtpVerified();
        }
      } else {
        throw AuthFailure(respond.data['message'] ?? AppStrings.errorVerificationFailed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw AuthFailure(_extractErrorMessage(e, AppStrings.errorVerificationFailed));
      }
      throw ServerFailure(e.message ?? AppStrings.errorVerificationFailed);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resendOtp(String phone, type, {bool isLawyer = false}) async {
    try {
      final response = await apiClient.post(
        isLawyer ? AppEndPoints.lawyerSendOtpEndPoint : AppEndPoints.resendOtpEndPoint,
        data: {
          'phone': phone,
          'type': type,
        },
      );
      if (response.data['success'] != true) {
        throw AuthFailure(response.data['message'] ?? AppStrings.errorResendOtpFailed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && e.response?.data['message'] == 'User not found') {
        throw const AuthFailure('email_not_found');
      }
      if (e.response?.statusCode == 422) {
        throw AuthFailure(_extractErrorMessage(e, AppStrings.errorResendOtpFailed));
      }
      throw ServerFailure(e.message ?? AppStrings.errorResendOtpFailed);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateToken(String fcmToken) async {
    try {
      await apiClient.put(
        AppEndPoints.updateToken,
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to update FCM token');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ProviderTypeModel>> getLawyerProviderTypes() async {
    try {
      final response = await apiClient.get(AppEndPoints.lawyerProviderTypesEndPoint);
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw AuthFailure(responseData['message']?.toString() ?? AppStrings.errorServer);
      }

      return (responseData['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderTypeModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw AuthFailure(_extractErrorMessage(e, AppStrings.errorServer));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<LegalSpecializationModel>> getLawyerSpecializations() async {
    try {
      final response = await apiClient.get(AppEndPoints.lawyerSpecializationsEndPoint);
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['status'] != true && responseData['success'] != true) {
        throw AuthFailure(responseData['message']?.toString() ?? AppStrings.errorServer);
      }

      return (responseData['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LegalSpecializationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw AuthFailure(_extractErrorMessage(e, AppStrings.errorServer));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LawyerRegistrationDraft> registerLawyer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String civilId,
    required String city,
    required String level,
    required String experienceYears,
    required int providerTypeId,
    required List<int> specializationIds,
    required String imagePath,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('phone', phone),
        MapEntry('email', email),
        MapEntry('password', password),
        MapEntry('civil_id', civilId),
        MapEntry('city', city),
        MapEntry('level', level),
        MapEntry('experience_years', experienceYears),
        MapEntry('provider_type_id', providerTypeId.toString()),
      ]);

      for (var i = 0; i < specializationIds.length; i++) {
        formData.fields.add(
          MapEntry('legal_specializations[$i]', specializationIds[i].toString()),
        );
      }

      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(imagePath),
        ),
      );

      final response = await apiClient.post(
        AppEndPoints.lawyerRegisterEndPoint,
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw AuthFailure(responseData['message']?.toString() ?? AppStrings.errorRegistrationFailed);
      }

      final draft = LawyerRegistrationDraft.fromJson(responseData);
      if (draft.token.isNotEmpty) {
        await AppPreferences().saveToken(draft.token);
      }
      return draft;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 || e.response?.statusCode == 403) {
        throw AuthFailure(_extractErrorMessage(e, AppStrings.errorRegistrationFailed));
      }
      throw ServerFailure(e.message ?? AppStrings.errorRegistrationFailed);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LawyerProfileCompletionResult> completeLawyerProfile({
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final formData = FormData();

      for (final entry in metadata.entries) {
        final key = 'metadata[${entry.key}]';
        final value = entry.value;

        if (value is String) {
          formData.fields.add(MapEntry(key, value));
          continue;
        }

        if (value is List<String>) {
          for (final item in value) {
            formData.fields.add(MapEntry(key, item));
          }
          continue;
        }

        if (value is MultipartFile) {
          formData.files.add(MapEntry(key, value));
          continue;
        }

        if (value is List<MultipartFile>) {
          for (final item in value) {
            formData.files.add(MapEntry(key, item));
          }
        }
      }

      final response = await apiClient.post(
        AppEndPoints.lawyerCompleteProfileEndPoint,
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true && responseData['status'] != true) {
        throw AuthFailure(responseData['message']?.toString() ?? AppStrings.errorServer);
      }

      await AppPreferences().saveIsProvider(true);
      await AppPreferences().saveRole('provider');
      await AppPreferences().setLoggedIn(true);

      return LawyerProfileCompletionResult.fromJson(responseData);
    } on DioException catch (e) {
      throw AuthFailure(_extractErrorMessage(e, AppStrings.errorServer));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AppConfig> getAppConfig() async {
    // Return hardcoded fallback as endpoint doesn't exist
    return AppConfig(
      latestVersion: '1.0.0',
      minimumVersion: '1.0.0',
      forceUpdate: false,
      isMaintenance: false,
      storeUrl: '',
    );
  }

  String _extractErrorMessage(DioException e, String defaultMessage) {
    if (e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map) {
        // 1. Check for specific validation errors in 'errors' map
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final errorList = errors[firstKey];
          if (errorList is List && errorList.isNotEmpty) {
            return errorList.first.toString();
          }
        }
        // 2. Fallback to the top-level 'message' field
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
    }
    // 3. Fallback to Dio's default message or the provided default
    return e.message ?? defaultMessage;
  }

}
