import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/clients/domain/repositories/clients_repository.dart';
import 'package:hogga/features/lawyer/clients/data/models/lawyer_client_model.dart';

abstract class LawyerClientsState {}

class LawyerClientsInitial extends LawyerClientsState {}

class LawyerClientsLoading extends LawyerClientsState {}

class LawyerClientsLoaded extends LawyerClientsState {
  final List<LawyerClientModel> clients;
  final bool hasReachedMax;
  final int currentPage;

  LawyerClientsLoaded({
    required this.clients,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  LawyerClientsLoaded copyWith({
    List<LawyerClientModel>? clients,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return LawyerClientsLoaded(
      clients: clients ?? this.clients,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class LawyerClientsError extends LawyerClientsState {
  final String message;
  LawyerClientsError({required this.message});
}

class LawyerClientsCubit extends Cubit<LawyerClientsState> {
  final ClientsRepository repository;

  LawyerClientsCubit({required this.repository}) : super(LawyerClientsInitial());

  Future<void> getClients() async {
    emit(LawyerClientsLoading());
    final result = await repository.getClients(page: 1);
    result.fold(
      (failure) => emit(LawyerClientsError(message: failure.message)),
      (response) => emit(LawyerClientsLoaded(
        clients: response.data,
        hasReachedMax: response.currentPage >= response.lastPage,
        currentPage: 1,
      )),
    );
  }

  Future<void> loadMoreClients() async {
    if (state is LawyerClientsLoaded) {
      final currentState = state as LawyerClientsLoaded;
      if (currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;
      final result = await repository.getClients(page: nextPage);
      result.fold(
        (failure) => null,
        (response) {
          final newClients = List<LawyerClientModel>.from(currentState.clients)..addAll(response.data);
          emit(currentState.copyWith(
            clients: newClients,
            hasReachedMax: response.currentPage >= response.lastPage,
            currentPage: nextPage,
          ));
        },
      );
    }
  }
}
