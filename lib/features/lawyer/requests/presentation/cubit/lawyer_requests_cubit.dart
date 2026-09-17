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

class LawyerRequestActionLoading extends LawyerRequestsState {}

class LawyerRequestActionSuccess extends LawyerRequestsState {
  final String message;
  LawyerRequestActionSuccess({required this.message});
}

class LawyerRequestActionError extends LawyerRequestsState {
  final String message;
  LawyerRequestActionError({required this.message});
}

class LawyerRequestsCubit extends Cubit<LawyerRequestsState> {
  final RequestsRepository repository;
  LawyerCaseRequestDetailsModel? currentDetails;
  List<LawyerCaseRequestModel> currentRequests = const [];

  LawyerRequestsCubit({required this.repository}) : super(LawyerRequestsInitial());

  Future<void> getRequests({bool showLoading = true}) async {
    if (showLoading) {
      emit(LawyerRequestsLoading());
    }
    final result = await repository.getCaseRequests();
    result.fold(
      (failure) {
        if (showLoading || currentRequests.isEmpty) {
          emit(LawyerRequestsError(message: failure.message));
        }
      },
      (requests) {
        currentRequests = requests;
        emit(LawyerRequestsLoaded(requests: requests));
      },
    );
  }

  Future<void> getRequestDetails(int requestId, {bool showLoading = true}) async {
    if (showLoading) {
      emit(LawyerRequestDetailsLoading());
    }
    final result = await repository.getCaseRequestDetails(requestId);
    result.fold(
      (failure) {
        if (showLoading || currentDetails == null) {
          emit(LawyerRequestsError(message: failure.message));
        }
      },
      (details) {
        currentDetails = details;
        emit(LawyerRequestDetailsLoaded(details: details));
      },
    );
  }

  Future<void> acceptRequest({
    required int requestId,
    required double price,
    String? description,
  }) async {
    emit(LawyerRequestActionLoading());
    final result = await repository.acceptRequest(
      requestId: requestId,
      price: price,
      description: description,
    );
    result.fold(
      (failure) {
        emit(LawyerRequestActionError(message: failure.message));
      },
      (message) {
        // Optimistically remove request from list
        currentRequests =
            currentRequests.where((r) => r.id != requestId).toList();
        emit(LawyerRequestActionSuccess(message: message));
        if (currentDetails?.id == requestId) {
          getRequestDetails(requestId, showLoading: false);
        }
        getRequests(showLoading: false);
      },
    );
  }

  Future<void> rejectRequest(int requestId) async {
    emit(LawyerRequestActionLoading());
    final result = await repository.rejectRequest(requestId);
    result.fold(
      (failure) {
        emit(LawyerRequestActionError(message: failure.message));
      },
      (message) {
        // Optimistically remove request from list
        currentRequests =
            currentRequests.where((r) => r.id != requestId).toList();
        emit(LawyerRequestActionSuccess(message: message));
        getRequests(showLoading: false);
      },
    );
  }
}
