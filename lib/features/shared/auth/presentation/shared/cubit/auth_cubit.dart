import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/constants/constant_strings.dart';

import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/call_coordinator.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/shared/auth/data/models/login_success.dart';
import 'package:hogga/features/shared/auth/data/models/registratoin_success.dart';
import 'package:hogga/features/shared/auth/data/models/user_model.dart';
import 'package:hogga/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:hogga/core/network/fcm_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({
    required this.authRepository,
  }) : super(AuthInitial()) {
    try {
      _listenToTokenRefresh();
      _checkAndSyncToken();
    } catch (error, stackTrace) {
      log(
        'AuthCubit FCM bootstrap failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _checkAndSyncToken() {
    if (AppPreferences().isLoggedIn) {
      updateFcmToken();
    }
  }

  void _listenToTokenRefresh() {
    FcmService.instance.onTokenRefresh.listen((token) {
      if (AppPreferences().isLoggedIn) {
        updateFcmToken();
      }
    });
  }

  Future<void> login(String email, String password, {bool isLawyer = false}) async {
    emit(AuthLoading());
    final result = await authRepository.login(email, password, isLawyer: isLawyer);
    result.fold(
      (failure) {
        emit(AuthError(_mapErrorMessage(failure.message)));
      },
      (result) async {
        if (result is LoginNeedVerification) {
          emit(AuthNeedVerification(result.email));
        } else if (result is LoginSuccess) {
          await _persistAuthenticatedUser(result.user);
          updateFcmToken();
          await CallCoordinator.instance.syncAfterLogin();
          emit(Authenticated(result.user));
        }
      },
    );
  }

  Future<void> updateFcmToken() async {
    try {
      final fcmService = FcmService.instance;
      final token = await fcmService.getToken();
      if (token != null) {
        await authRepository.updateToken(token);
      }
    } catch (error, stackTrace) {
      log(
        'updateFcmToken failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String accountType,
    required bool termsAccepted,
    String? referralCode,
  }) async
  {
    emit(AuthLoading());

    final result = await authRepository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
      accountType: accountType,
      termsAccepted: termsAccepted,
      referralCode: referralCode,
    );

    result.fold(
      (failure) => emit(AuthError(_mapErrorMessage(failure.message))),
      (result) async {
        if (result is RegisterNeedVerification) {
          emit(AuthNeedVerification(result.email));
        } else if (result is RegisterSuccess) {
          await _persistAuthenticatedUser(result.user);
          updateFcmToken();
          await CallCoordinator.instance.syncAfterLogin();
          emit(Authenticated(result.user));
        }
      },
    );
  }

  String? _verifiedOtp;

  Future<void> verifyOtp(String phone, String otp, {bool isLawyer = false, bool isForReset = false}) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(phone, otp, isLawyer: isLawyer);
    result.fold(
      (failure) => emit(AuthError(_mapErrorMessage(failure.message))),
      (result) async {
        if (isForReset) {
          _verifiedOtp = otp;
          emit(AuthResetPasswordOtpVerified(otp));
          return;
        }
        if (result is LoginSuccess) {
          await _persistAuthenticatedUser(result.user);
          updateFcmToken();
          await CallCoordinator.instance.syncAfterLogin();
          emit(Authenticated(result.user));
          return;
        }
        emit(AuthVerified());
      },
    );
  }

  Future<void> resendOtp(String phone, type, {bool isLawyer = false}) async {
    emit(AuthLoading());
    final result = await authRepository.resendOtp(phone, type, isLawyer: isLawyer);
    result.fold(
      (failure) {
        if (failure.message == 'email_not_found') {
          emit(const AuthError(AppStrings.emailNotFound));
        } else {
          emit(AuthError(_mapErrorMessage(failure.message)));
        }
      },
      (_) => emit(const AuthOperationSuccess(AppStrings.otpResentSuccessfully)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.logout();
    await AppPreferences().clear();
    CallCoordinator.instance.reset();
    emit(Unauthenticated());
  }

  void updateUser(UserModel user) {
    if (state is Authenticated) {
      emit(Authenticated(user));
    }
  }

  Future<void> resetPassword({
    required String phone,
    String? otpCode,
    required String password,
  }) async
  {
    emit(AuthLoading());
    final finalOtp = otpCode ?? _verifiedOtp;
    if (finalOtp == null) {
      emit(const AuthError("OTP not verified"));
      return;
    }
    final result = await authRepository.resetPassword(
      phone: phone,
      otpCode: finalOtp,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthError(_mapErrorMessage(failure.message))),
      (_) {
        _verifiedOtp = null; // Clear after use
        emit(const AuthOperationSuccess(AppStrings.passwordChanged));
      },
    );
  }


  String _mapErrorMessage(String message) {
    // If the message is already in Arabic, return it as is
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(message)) {
      return message;
    }

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('email') && lowerMessage.contains('taken')) {
      return AppStrings.emailTaken;
    }
    if (lowerMessage.contains('phone') && lowerMessage.contains('taken')) {
      return AppStrings.phoneTaken;
    }
    if (lowerMessage.contains('credentials') || lowerMessage.contains('incorrect')) {
      return AppStrings.invalidCredentials;
    }
    if (lowerMessage.contains('unauthorized') || lowerMessage.contains('unauthenticated')) {
      return AppStrings.sessionExpired;
    }
    if (message == AppStrings.noInternetConnection ||
        message == AppStrings.requestTimedOut ||
        message == AppStrings.operationCancelled ||
        message == AppStrings.unexpectedError) {
      return message;
    }
    
    return message;
  }

  Future<void> _persistAuthenticatedUser(UserModel user) async {
    await AppPreferences().saveEmail(user.email);
    await AppPreferences().saveName(user.name);
    await AppPreferences().savePhone(user.phone);
    await AppPreferences().saveRole(user.role.toLowerCase());
    await AppPreferences().saveIsProvider(user.isProvider);
    await AppPreferences().saveImage(user.image);
    if (user.type != null) await AppPreferences().saveType(user.type!);
    if (user.accountType != null) await AppPreferences().saveAccountType(user.accountType!);
    await AppPreferences().setLoggedIn(true);
    AppConstants.userName = user.name;
  }
}
