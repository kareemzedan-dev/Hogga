import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/requests/domain/repositories/requests_repository.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_model.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_details_model.dart';

abstract class LawyerRequestsState {}

class LawyerRequestsInitial extends LawyerRequestsState {}

class LawyerRequestsLoading extends LawyerRequestsState {}

class LawyerRequestsLoaded extends LawyerRequestsState {
  final List<LawyerCaseRequestModel> requests;
  LawyerRequestsLoaded({required this.requests});
}

class LawyerRequestDetailsLoading extends LawyerRequestsState {}

class LawyerRequestDetailsLoaded extends LawyerRequestsState {
  final LawyerCaseRequestDetailsModel details;
  LawyerRequestDetailsLoaded({required this.details});
}

class LawyerRequestsError extends LawyerRequestsState {
  final String message;
  LawyerRequestsError({required this.message});
}

class LawyerRequestActionSuccess extends LawyerRequestsState {
  final String message;
  LawyerRequestActionSuccess({required this.message});
}

class LawyerRequestsCubit extends Cubit<LawyerRequestsState> {
  final RequestsRepository repository;

  LawyerRequestsCubit({required this.repository}) : super(LawyerRequestsInitial());

  Future<void> getRequests() async {
    emit(LawyerRequestsLoading());
    final result = await repository.getCaseRequests();
    result.fold(
      (failure) => emit(LawyerRequestsError(message: failure.message)),
      (requests) => emit(LawyerRequestsLoaded(requests: requests)),
    );
  }

  Future<void> getRequestDetails(int requestId) async {
    emit(LawyerRequestDetailsLoading());
    final result = await repository.getCaseRequestDetails(requestId);
    result.fold(
      (failure) => emit(LawyerRequestsError(message: failure.message)),
      (details) => emit(LawyerRequestDetailsLoaded(details: details)),
    );
  }

  Future<void> acceptRequest(int requestId) async {
    emit(LawyerRequestsLoading());
    final result = await repository.acceptRequest(requestId);
    result.fold(
      (failure) => emit(LawyerRequestsError(message: failure.message)),
      (message) {
        emit(LawyerRequestActionSuccess(message: message));
        getRequests();
      },
    );
  }

  Future<void> rejectRequest(int requestId) async {
    emit(LawyerRequestsLoading());
    final result = await repository.rejectRequest(requestId);
    result.fold(
      (failure) => emit(LawyerRequestsError(message: failure.message)),
      (message) {
        emit(LawyerRequestActionSuccess(message: message));
        getRequests();
      },
    );
  }
}
