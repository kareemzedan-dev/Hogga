import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/bainah_services/data/models/legal_case_models.dart';
import 'package:hogga/features/user/bainah_services/data/repositories/bainah_repository.dart';

class ServiceRequestState extends Equatable {
  final bool isSubmitting;
  final bool isVerifyingCoupon;
  final CouponData? coupon;
  final LegalCaseResponse? createdCase;
  final String? errorMessage;

  const ServiceRequestState({
    this.isSubmitting = false,
    this.isVerifyingCoupon = false,
    this.coupon,
    this.createdCase,
    this.errorMessage,
  });

  ServiceRequestState copyWith({
    bool? isSubmitting,
    bool? isVerifyingCoupon,
    CouponData? coupon,
    bool clearCoupon = false,
    LegalCaseResponse? createdCase,
    bool clearCreatedCase = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ServiceRequestState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isVerifyingCoupon: isVerifyingCoupon ?? this.isVerifyingCoupon,
      coupon: clearCoupon ? null : (coupon ?? this.coupon),
      createdCase: clearCreatedCase ? null : (createdCase ?? this.createdCase),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isVerifyingCoupon, coupon, createdCase, errorMessage];
}

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final BainahRepository repository;

  ServiceRequestCubit({required this.repository}) : super(const ServiceRequestState());

  Future<void> verifyCoupon(String code) async {
    emit(state.copyWith(isVerifyingCoupon: true, clearError: true));
    final result = await repository.verifyCoupon(code);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isVerifyingCoupon: false,
          clearCoupon: true,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          isVerifyingCoupon: false,
          coupon: response.data,
          errorMessage: response.success ? null : response.message,
        ),
      ),
    );
  }

  void clearCoupon() {
    emit(state.copyWith(clearCoupon: true, clearError: true));
  }

  Future<void> submitRequest(CreateLegalCaseRequest request) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearCreatedCase: true));
    final result = await repository.createLegalCase(request);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          isSubmitting: false,
          createdCase: response,
          errorMessage: response.status ? null : response.message,
        ),
      ),
    );
  }
}
