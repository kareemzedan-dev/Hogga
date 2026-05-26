import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class DeleteServiceState {}

class DeleteServiceInitial extends DeleteServiceState {}

class DeleteServiceLoading extends DeleteServiceState {}

class DeleteServiceSuccess extends DeleteServiceState {
  final String message;
  DeleteServiceSuccess({required this.message});
}

class DeleteServiceError extends DeleteServiceState {
  final String message;
  DeleteServiceError({required this.message});
}

class DeleteServiceCubit extends Cubit<DeleteServiceState> {
  final ServicesRepository repository;

  DeleteServiceCubit({required this.repository}) : super(DeleteServiceInitial());

  Future<void> deleteService(int id) async {
    emit(DeleteServiceLoading());
    final result = await repository.deleteService(id);
    result.fold(
      (failure) => emit(DeleteServiceError(message: failure.message)),
      (message) => emit(DeleteServiceSuccess(message: message)),
    );
  }
}
