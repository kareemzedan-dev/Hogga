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

  const LegalCaseActionsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.actionType,
  });

  LegalCaseActionsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? actionType,
    bool clearActionType = false,
  }) {
    return LegalCaseActionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      actionType: clearActionType ? null : (actionType ?? this.actionType),
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, successMessage, actionType];
}

class LegalCaseActionsCubit extends Cubit<LegalCaseActionsState> {
  final hoggaRepository repository;

  LegalCaseActionsCubit({required this.repository}) : super(const LegalCaseActionsState());

  Future<void> uploadDocuments({
    required int caseId,
    required List<String> titles,
    required List<File> files,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true, clearActionType: true));
    final result = await repository.uploadLegalCaseDocuments(
      UploadLegalCaseDocumentsRequest(
        caseId: caseId,
        titles: titles,
        files: files,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          successMessage: response.message.isNotEmpty ? response.message : AppStrings.documentUploadedSuccessfully,
          actionType: 'upload',
        ),
      ),
    );
  }

  Future<void> cancelCase(int caseId) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true, clearActionType: true));
    final result = await repository.cancelLegalCase(caseId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          successMessage: response.message.isNotEmpty ? response.message : AppStrings.operationSuccess,
          actionType: 'cancel',
        ),
      ),
    );
  }

  Future<void> acceptProposal(int proposalId) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true, clearActionType: true));
    final result = await repository.acceptProposal(proposalId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          successMessage: response.message.isNotEmpty ? response.message : AppStrings.operationSuccess,
          actionType: 'accept',
        ),
      ),
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true, clearActionType: true));
  }
}
