import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_details_model.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_model.dart';
import 'package:hogga/features/lawyer/cases/domain/repositories/cases_repository.dart';

abstract class LawyerCasesState {}

class LawyerCasesInitial extends LawyerCasesState {}

class LawyerCasesLoading extends LawyerCasesState {}

class LawyerCasesLoaded extends LawyerCasesState {
  final List<LawyerCaseModel> cases;
  final String currentType;

  LawyerCasesLoaded({
    required this.cases,
    this.currentType = 'active',
  });

  LawyerCasesLoaded copyWith({
    List<LawyerCaseModel>? cases,
    String? currentType,
  }) {
    return LawyerCasesLoaded(
      cases: cases ?? this.cases,
      currentType: currentType ?? this.currentType,
    );
  }
}

class LawyerCasesError extends LawyerCasesState {
  final String message;
  LawyerCasesError({required this.message});
}

class LawyerCaseDetailsLoading extends LawyerCasesState {}

class LawyerCaseDetailsLoaded extends LawyerCasesState {
  final LawyerCaseDetailsModel caseDetails;
  LawyerCaseDetailsLoaded({required this.caseDetails});
}

class LawyerCaseActionLoading extends LawyerCasesState {}

class LawyerCaseActionSuccess extends LawyerCasesState {
  final String message;
  LawyerCaseActionSuccess({required this.message});
}

class LawyerCasesCubit extends Cubit<LawyerCasesState> {
  final CasesRepository repository;
  LawyerCaseDetailsModel? currentCaseDetails;

  LawyerCasesCubit({required this.repository}) : super(LawyerCasesInitial());

  Future<void> getCases({String type = 'active'}) async {
    emit(LawyerCasesLoading());
    final result = await repository.getCases(type: type);
    result.fold(
      (failure) => emit(LawyerCasesError(message: failure.message)),
      (cases) => emit(LawyerCasesLoaded(cases: cases, currentType: type)),
    );
  }

  Future<void> getCaseDetails(int caseId) async {
    emit(LawyerCaseDetailsLoading());
    final result = await repository.getCaseDetails(caseId);
    result.fold(
      (failure) => emit(LawyerCasesError(message: failure.message)),
      (details) {
        currentCaseDetails = details;
        emit(LawyerCaseDetailsLoaded(caseDetails: details));
      },
    );
  }

  Future<void> addCaseSession({
    required int caseId,
    required String title,
    required String date,
    required String details,
  }) async {
    emit(LawyerCaseActionLoading());
    final result = await repository.addCaseSession(
      caseId: caseId,
      title: title,
      date: date,
      details: details,
    );
    result.fold(
      (failure) => emit(LawyerCasesError(message: failure.message)),
      (success) {
        emit(LawyerCaseActionSuccess(message: AppStrings.sessionAddedSuccessfully));
        getCaseDetails(caseId);
      },
    );
  }

  Future<void> uploadCaseDocument({
    required int caseId,
    required String title,
    required File document,
  }) async {
    emit(LawyerCaseActionLoading());
    final result = await repository.uploadCaseDocument(
      caseId: caseId,
      title: title,
      document: document,
    );
    result.fold(
      (failure) => emit(LawyerCasesError(message: failure.message)),
      (success) {
        emit(LawyerCaseActionSuccess(message: AppStrings.documentUploadedSuccessfully));
        getCaseDetails(caseId);
      },
    );
  }
}
