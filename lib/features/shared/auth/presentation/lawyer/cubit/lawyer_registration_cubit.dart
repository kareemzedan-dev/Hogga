import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/shared/auth/data/models/lawyer_registration_models.dart';
import 'package:hogga/features/shared/auth/data/models/login_success.dart';
import 'package:hogga/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:hogga/core/utils/app_strings.dart';

class LawyerRegistrationState extends Equatable {
  final bool isLoadingOptions;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isRegistering;
  final bool isCompletingProfile;
  final bool isPhoneVerified;
  final bool isCompleted;
  final String? verifiedPhone;
  final List<ProviderTypeModel> providerTypes;
  final List<LegalSpecializationModel> specializations;
  final ProviderTypeModel? selectedProviderType;
  final List<int> selectedSpecializationIds;
  final LawyerRegistrationDraft? draft;
  final String? errorMessage;
  final String? successMessage;
  final String? errorMessageKey;
  final String? successMessageKey;

  const LawyerRegistrationState({
    this.isLoadingOptions = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isRegistering = false,
    this.isCompletingProfile = false,
    this.isPhoneVerified = false,
    this.isCompleted = false,
    this.verifiedPhone,
    this.providerTypes = const [],
    this.specializations = const [],
    this.selectedProviderType,
    this.selectedSpecializationIds = const [],
    this.draft,
    this.errorMessage,
    this.successMessage,
    this.errorMessageKey,
    this.successMessageKey,
  });

  LawyerRegistrationState copyWith({
    bool? isLoadingOptions,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isRegistering,
    bool? isCompletingProfile,
    bool? isPhoneVerified,
    bool? isCompleted,
    String? verifiedPhone,
    bool clearVerifiedPhone = false,
    List<ProviderTypeModel>? providerTypes,
    List<LegalSpecializationModel>? specializations,
    ProviderTypeModel? selectedProviderType,
    bool clearSelectedProviderType = false,
    List<int>? selectedSpecializationIds,
    LawyerRegistrationDraft? draft,
    bool clearDraft = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessageKey,
    bool clearErrorKey = false,
    String? successMessageKey,
    bool clearSuccessKey = false,
  }) {
    return LawyerRegistrationState(
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isRegistering: isRegistering ?? this.isRegistering,
      isCompletingProfile: isCompletingProfile ?? this.isCompletingProfile,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isCompleted: isCompleted ?? this.isCompleted,
      verifiedPhone: clearVerifiedPhone ? null : (verifiedPhone ?? this.verifiedPhone),
      providerTypes: providerTypes ?? this.providerTypes,
      specializations: specializations ?? this.specializations,
      selectedProviderType: clearSelectedProviderType
          ? null
          : (selectedProviderType ?? this.selectedProviderType),
      selectedSpecializationIds: selectedSpecializationIds ?? this.selectedSpecializationIds,
      draft: clearDraft ? null : (draft ?? this.draft),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessageKey: clearErrorKey ? null : (errorMessageKey ?? this.errorMessageKey),
      successMessageKey: clearSuccessKey ? null : (successMessageKey ?? this.successMessageKey),
    );
  }

  @override
  List<Object?> get props => [
        isLoadingOptions,
        isSendingOtp,
        isVerifyingOtp,
        isRegistering,
        isCompletingProfile,
        isPhoneVerified,
        isCompleted,
        verifiedPhone,
        providerTypes,
        specializations,
        selectedProviderType,
        selectedSpecializationIds,
        draft,
        errorMessage,
        successMessage,
        errorMessageKey,
        successMessageKey,
      ];
}

class LawyerRegistrationCubit extends Cubit<LawyerRegistrationState> {
  final AuthRepository authRepository;

  LawyerRegistrationCubit({required this.authRepository})
      : super(const LawyerRegistrationState());

  Future<void> loadOnboardingOptions() async {
    emit(state.copyWith(
      isLoadingOptions: true,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));

    final providerTypesResult = await authRepository.getLawyerProviderTypes();
    final specializationsResult = await authRepository.getLawyerSpecializations();

    providerTypesResult.fold(
      (failure) => emit(state.copyWith(
        isLoadingOptions: false,
        errorMessage: failure.message,
      )),
      (providerTypes) {
        specializationsResult.fold(
          (failure) => emit(state.copyWith(
            isLoadingOptions: false,
            errorMessage: failure.message,
          )),
          (specializations) => emit(state.copyWith(
            isLoadingOptions: false,
            providerTypes: providerTypes,
            specializations: specializations,
            clearSelectedProviderType: true,
          )),
        );
      },
    );
  }

  void selectProviderType(ProviderTypeModel providerType) {
    emit(state.copyWith(
      selectedProviderType: providerType,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));
  }

  void toggleSpecialization(int id) {
    final current = List<int>.from(state.selectedSpecializationIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }

    emit(state.copyWith(
      selectedSpecializationIds: current,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));
  }

  void resetPhoneVerification() {
    emit(state.copyWith(
      isPhoneVerified: false,
      clearVerifiedPhone: true,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));
  }

  Future<bool> sendOtp(String phone) async {
    emit(state.copyWith(
      isSendingOtp: true,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));

    final result = await authRepository.resendOtp(
      phone,
      'register',
      isLawyer: true,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isSendingOtp: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isSendingOtp: false,
          successMessageKey: AppStrings.verificationCodeSent,
        ));
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    emit(state.copyWith(
      isVerifyingOtp: true,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));

    final result = await authRepository.verifyOtp(
      phone,
      otp,
      isLawyer: true,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isVerifyingOtp: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (data) {
        final isVerified = data is OtpVerified || data is LoginSuccess;
        emit(state.copyWith(
          isVerifyingOtp: false,
          isPhoneVerified: isVerified,
          verifiedPhone: isVerified ? phone : null,
          successMessageKey: isVerified ? AppStrings.phoneVerifiedSuccess : null,
        ));
        return isVerified;
      },
    );
  }

  Future<bool> registerBasicInfo({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String civilId,
    required String city,
    required String level,
    required String experienceYears,
    required String imagePath,
  }) async {
    final providerType = state.selectedProviderType;
    if (providerType == null) {
      emit(state.copyWith(errorMessageKey: AppStrings.selectAccountTypeFirst));
      return false;
    }

    emit(state.copyWith(
      isRegistering: true,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));

    final result = await authRepository.registerLawyer(
      name: name,
      phone: phone,
      email: email,
      password: password,
      civilId: civilId,
      city: city,
      level: level,
      experienceYears: experienceYears,
      providerTypeId: providerType.id,
      specializationIds: state.selectedSpecializationIds,
      imagePath: imagePath,
    );

    return result.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(
            isRegistering: false,
            errorMessageKey: _mapFailureMessage(failure),
          ));
        }
        return false;
      },
      (draft) {
        if (!isClosed) {
          emit(state.copyWith(
            isRegistering: false,
            draft: draft,
            successMessageKey: AppStrings.basicInfoSaved,
          ));
        }
        return true;
      },
    );
  }

  Future<bool> completeProfile({
    required Map<String, dynamic> metadata,
  }) async {
    emit(state.copyWith(
      isCompletingProfile: true,
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));

    final result = await authRepository.completeLawyerProfile(metadata: metadata);

    return result.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(
            isCompletingProfile: false,
            errorMessageKey: _mapFailureMessage(failure),
          ));
        }
        return false;
      },
      (data) {
        if (!isClosed) {
          emit(state.copyWith(
            isCompletingProfile: false,
            isCompleted: true,
            successMessage: data.message,
          ));
        }
        return true;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(
      clearError: true,
      clearSuccess: true,
      clearErrorKey: true,
      clearSuccessKey: true,
    ));
  }

  String _mapFailureMessage(Failure failure) {
    final message = failure.message;
    if (message.contains('phone')) {
      return AppStrings.phoneAlreadyRegistered;
    }
    if (message.contains('email')) {
      return AppStrings.emailAlreadyRegistered;
    }
    return message;
  }
}
