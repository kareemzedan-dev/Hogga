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

class AvailableServiceDetailsLoading extends LawyerProposalsState {}

class AvailableServiceDetailsLoaded extends LawyerProposalsState {
  final AvailableServiceDetails details;
  AvailableServiceDetailsLoaded({required this.details});
}

class LawyerProposalsCubit extends Cubit<LawyerProposalsState> {
  final ProposalsRepository repository;
  List<LawyerAvailableService> currentAvailableServices = const [];
  List<LawyerProposal> currentProposals = const [];

  LawyerProposalsCubit({required this.repository}) : super(LawyerProposalsInitial());

  Future<void> getProposalsData() async {
    emit(LawyerProposalsLoading());
    final servicesResult = await repository.getAvailableServices();
    final proposalsResult = await repository.getProposals();

    servicesResult.fold(
      (failure) => emit(LawyerProposalsError(message: failure.message)),
      (services) {
        proposalsResult.fold(
          (failure) => emit(LawyerProposalsError(message: failure.message)),
          (proposals) {
            currentAvailableServices = services;
            currentProposals = proposals;
            emit(LawyerProposalsLoaded(
              availableServices: services,
              proposals: proposals,
            ));
          },
        );
      },
    );
  }

  Future<void> submitProposal({
    required int serviceId,
    required double price,
    required String description,
  }) async {
    emit(LawyerProposalActionLoading());
    final result = await repository.submitProposal(
      serviceId: serviceId,
      price: price,
      description: description,
    );
    result.fold(
      (failure) {
        if (state is LawyerProposalsLoaded) {
          emit(LawyerProposalsError(message: failure.message));
        } else {
          emit(LawyerProposalsError(message: failure.message));
        }
      },
      (success) {
        emit(LawyerProposalActionSuccess(message: AppStrings.proposalSubmittedSuccess));
        getProposalsData();
      },
    );
  }

  Future<void> updateProposal({
    required int proposalId,
    required double price,
    required String description,
  }) async {
    emit(LawyerProposalActionLoading());
    final result = await repository.updateProposal(
      proposalId: proposalId,
      price: price,
      description: description,
    );
    result.fold(
      (failure) => emit(LawyerProposalsError(message: failure.message)),
      (success) {
        emit(LawyerProposalActionSuccess(message: AppStrings.operationSuccess));
        getProposalsData();
      },
    );
  }

  Future<void> deleteProposal(int proposalId) async {
    emit(LawyerProposalActionLoading());
    final result = await repository.deleteProposal(proposalId);
    result.fold(
      (failure) => emit(LawyerProposalsError(message: failure.message)),
      (success) {
        emit(LawyerProposalActionSuccess(message: AppStrings.operationSuccess));
        getProposalsData();
      },
    );
  }

  Future<void> getAvailableServiceDetails(int id) async {
    emit(AvailableServiceDetailsLoading());
    final result = await repository.getAvailableServiceDetails(id);
    result.fold(
      (failure) => emit(LawyerProposalsError(message: failure.message)),
      (details) => emit(AvailableServiceDetailsLoaded(details: details)),
    );
  }
}
