import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class UpdateServiceState {}

class UpdateServiceInitial extends UpdateServiceState {}

class UpdateServiceLoading extends UpdateServiceState {}

class UpdateServiceSuccess extends UpdateServiceState {
  final String message;
  UpdateServiceSuccess({required this.message});
}

class UpdateServiceError extends UpdateServiceState {
  final String message;
  UpdateServiceError({required this.message});
}

class UpdateServiceCubit extends Cubit<UpdateServiceState> {
  final ServicesRepository repository;

  UpdateServiceCubit({required this.repository}) : super(UpdateServiceInitial());

  Future<void> updateService({
    required int id,
    required String name,
    required String details,
    required double price,
    required int categoryId,
  }) async {
    emit(UpdateServiceLoading());
    final result = await repository.updateService(
      id: id,
      name: name,
      details: details,
      price: price,
      categoryId: categoryId,
    );
    result.fold(
      (failure) => emit(UpdateServiceError(message: failure.message)),
      (message) => emit(UpdateServiceSuccess(message: message)),
    );
  }
}
