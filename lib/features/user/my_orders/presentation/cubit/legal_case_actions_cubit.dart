import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/user/hogga_services/data/models/legal_case_models.dart';
import 'package:hogga/features/user/hogga_services/data/repositories/hogga_repository.dart';

class LegalCaseActionsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? actionType;
  final String? paymentUrl;
  final int? caseId;

  const LegalCaseActionsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.actionType,
    this.paymentUrl,
    this.caseId,
  });

  LegalCaseActionsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? actionType,
    bool clearActionType = false,
    String? paymentUrl,
    bool clearPaymentUrl = false,
    int? caseId,
    bool clearCaseId = false,
  }) {
    return LegalCaseActionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      actionType: clearActionType ? null : (actionType ?? this.actionType),
      paymentUrl: clearPaymentUrl ? null : (paymentUrl ?? this.paymentUrl),
      caseId: clearCaseId ? null : (caseId ?? this.caseId),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    actionType,
    paymentUrl,
    caseId,
  ];
}

class LegalCaseActionsCubit extends Cubit<LegalCaseActionsState> {
  final HoggaRepository repository;

  LegalCaseActionsCubit({required this.repository})
    : super(const LegalCaseActionsState());

  Future<void> uploadDocuments({
    required int caseId,
    required List<String> titles,
    required List<File> files,
  }) async {
    _emitActionLoading(actionType: 'upload');
    final result = await repository.uploadLegalCaseDocuments(
      UploadLegalCaseDocumentsRequest(
        caseId: caseId,
        titles: titles,
        files: files,
      ),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          successMessage: AppStrings.documentUploadedSuccessfully,
          actionType: 'upload',
        ),
      ),
    );
  }

  Future<void> cancelCase(int caseId) async {
    _emitActionLoading(actionType: 'cancel');
    final result = await repository.cancelLegalCase(caseId);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          successMessage: AppStrings.operationSuccess,
          actionType: 'cancel',
        ),
      ),
    );
  }

  Future<void> acceptProposal(
    int proposalId, {
    String paymentMethod = 'card',
  }) async {
    _emitActionLoading(actionType: 'accept');
    final result = await repository.acceptProposal(
      proposalId,
      paymentMethod: paymentMethod,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) {
        if (!response.status) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: response.message.isNotEmpty
                  ? response.message
                  : 'فشل قبول العرض',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            isLoading: false,
            successMessage: response.message.isNotEmpty
                ? response.message
                : AppStrings.operationSuccess,
            actionType: 'accept',
            paymentUrl: response.paymentUrl,
            caseId: response.caseId,
          ),
        );
      },
    );
  }

  Future<void> completeRecord({
    required int recordId,
    required bool isConsultation,
  }) async {
    _emitActionLoading(actionType: 'complete');
    final result = isConsultation
        ? await repository.completeConsultation(recordId)
        : await repository.completeLegalCase(recordId);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) {
        if (!response.status) {
          emit(
            state.copyWith(isLoading: false, errorMessage: response.message),
          );
          return;
        }

        emit(
          state.copyWith(
            isLoading: false,
            successMessage: response.message.isNotEmpty
                ? response.message
                : AppStrings.operationSuccess,
            actionType: 'complete',
          ),
        );
      },
    );
  }

  void clearMessages() {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
        clearActionType: true,
        clearPaymentUrl: true,
        clearCaseId: true,
      ),
    );
  }

  void _emitActionLoading({String? actionType}) {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
        actionType: actionType,
        clearActionType: actionType == null,
        clearPaymentUrl: true,
        clearCaseId: true,
      ),
    );
  }
}
