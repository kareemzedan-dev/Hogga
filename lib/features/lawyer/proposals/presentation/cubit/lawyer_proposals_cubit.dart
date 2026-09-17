import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/proposals/domain/repositories/proposals_repository.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';
import 'package:hogga/core/utils/app_strings.dart';

abstract class LawyerProposalsState {}

class LawyerProposalsInitial extends LawyerProposalsState {}

class LawyerProposalsLoading extends LawyerProposalsState {}

class LawyerProposalsLoaded extends LawyerProposalsState {
  final List<LawyerAvailableService> availableServices;
  final List<LawyerProposal> proposals;

  LawyerProposalsLoaded({
    required this.availableServices,
    required this.proposals,
  });

  LawyerProposalsLoaded copyWith({
    List<LawyerAvailableService>? availableServices,
    List<LawyerProposal>? proposals,
  }) {
    return LawyerProposalsLoaded(
      availableServices: availableServices ?? this.availableServices,
      proposals: proposals ?? this.proposals,
    );
  }
}

class LawyerProposalsError extends LawyerProposalsState {
  final String message;
  LawyerProposalsError({required this.message});
}

class LawyerProposalActionLoading extends LawyerProposalsState {}

class LawyerProposalActionSuccess extends LawyerProposalsState {
  final String message;
  LawyerProposalActionSuccess({required this.message});
}

class LawyerProposalActionError extends LawyerProposalsState {
  final String message;
  LawyerProposalActionError({required this.message});
}

class AvailableServiceDetailsLoading extends LawyerProposalsState {}

class AvailableServiceDetailsLoaded extends LawyerProposalsState {
  final AvailableServiceDetails details;
  AvailableServiceDetailsLoaded({required this.details});
}

class LawyerProposalsCubit extends Cubit<LawyerProposalsState> {
  final ProposalsRepository repository;
  List<LawyerAvailableService> currentAvailableServices = const [];
  List<LawyerProposal> currentProposals = const [];
  AvailableServiceDetails? currentAvailableServiceDetails;

  LawyerProposalsCubit({required this.repository})
    : super(LawyerProposalsInitial());

  Future<void> getProposalsData({bool showLoading = true}) async {
    if (showLoading) {
      emit(LawyerProposalsLoading());
    }
    final servicesResult = await repository.getAvailableServices();
    final proposalsResult = await repository.getProposals();

    servicesResult.fold(
      (failure) {
        if (showLoading) {
          emit(LawyerProposalsError(message: failure.message));
        }
      },
      (services) {
        proposalsResult.fold(
          (failure) {
            if (showLoading) {
              emit(LawyerProposalsError(message: failure.message));
            }
          },
          (proposals) {
            currentAvailableServices = services;
            currentProposals = proposals;
            emit(
              LawyerProposalsLoaded(
                availableServices: services,
                proposals: proposals,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> submitProposal({
    required int serviceId,
    required double offerPrice,
    required String description,
  }) async {
    emit(LawyerProposalActionLoading());
    final result = await repository.submitProposal(
      serviceId: serviceId,
      offerPrice: offerPrice,
      description: description,
    );
    result.fold(
      (failure) {
        emit(LawyerProposalActionError(message: failure.message));
        if (currentAvailableServiceDetails != null) {
          emit(AvailableServiceDetailsLoaded(details: currentAvailableServiceDetails!));
        } else if (currentAvailableServices.isNotEmpty || currentProposals.isNotEmpty) {
          emit(LawyerProposalsLoaded(
            availableServices: currentAvailableServices,
            proposals: currentProposals,
          ));
        }
      },
      (successMessage) async {
        emit(
          LawyerProposalActionSuccess(
            message: successMessage.isNotEmpty
                ? successMessage
                : AppStrings.proposalSubmittedSuccess,
          ),
        );
        if (currentAvailableServiceDetails?.id == serviceId) {
          await getAvailableServiceDetails(serviceId, showLoading: false);
        }
        getProposalsData(showLoading: false);
      },
    );
  }

  Future<void> updateProposal({
    required int proposalId,
    required double offerPrice,
    required String description,
  }) async {
    emit(LawyerProposalActionLoading());
    final result = await repository.updateProposal(
      proposalId: proposalId,
      offerPrice: offerPrice,
      description: description,
    );
    result.fold(
      (failure) {
        emit(LawyerProposalActionError(message: failure.message));
        if (currentAvailableServiceDetails != null) {
          emit(AvailableServiceDetailsLoaded(details: currentAvailableServiceDetails!));
        } else if (currentAvailableServices.isNotEmpty || currentProposals.isNotEmpty) {
          emit(LawyerProposalsLoaded(
            availableServices: currentAvailableServices,
            proposals: currentProposals,
          ));
        }
      },
      (successMessage) async {
        emit(
          LawyerProposalActionSuccess(
            message: successMessage.isNotEmpty
                ? successMessage
                : AppStrings.operationSuccess,
          ),
        );
        if (currentAvailableServiceDetails != null) {
          await getAvailableServiceDetails(
            currentAvailableServiceDetails!.id,
            showLoading: false,
          );
        }
        getProposalsData(showLoading: false);
      },
    );
  }

  Future<void> deleteProposal(int proposalId, {int? index}) async {
    emit(LawyerProposalActionLoading());
    final result = await repository.deleteProposal(proposalId);
    result.fold(
      (failure) => emit(LawyerProposalsError(message: failure.message)),
      (serverMessage) {
        // 1. Remove deleted proposal at index or by proposalId
        if (index != null &&
            index >= 0 &&
            index < currentProposals.length &&
            currentProposals[index].id == proposalId) {
          final updated = List<LawyerProposal>.from(currentProposals)
            ..removeAt(index);
          currentProposals = updated;
        } else {
          currentProposals =
              currentProposals.where((p) => p.id != proposalId).toList();
        }

        // 2. Emit action success with message from backend
        emit(LawyerProposalActionSuccess(message: serverMessage));

        // 3. Immediately emit updated loaded state so the list updates instantly
        emit(
          LawyerProposalsLoaded(
            availableServices: currentAvailableServices,
            proposals: currentProposals,
          ),
        );

        // 4. Update the page in background from server
        getProposalsData(showLoading: false);
      },
    );
  }

  Future<void> getAvailableServiceDetails(int id, {bool showLoading = true}) async {
    if (showLoading) {
      emit(AvailableServiceDetailsLoading());
    }
    final result = await repository.getAvailableServiceDetails(id);
    result.fold(
      (failure) => emit(LawyerProposalsError(message: failure.message)),
      (details) {
        currentAvailableServiceDetails = details;
        emit(AvailableServiceDetailsLoaded(details: details));
      },
    );
  }
}
