import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class AddServiceState {}

class AddServiceInitial extends AddServiceState {}

class AddServiceLoading extends AddServiceState {}

class AddServiceSuccess extends AddServiceState {
  final String message;
  AddServiceSuccess({required this.message});
}

class AddServiceError extends AddServiceState {
  final String message;
  AddServiceError({required this.message});
}

class AddServiceCubit extends Cubit<AddServiceState> {
  final ServicesRepository repository;

  AddServiceCubit({required this.repository}) : super(AddServiceInitial());

  Future<void> addService({
    required String name,
    required String details,
    required double price,
    required int categoryId,
  }) async {
    emit(AddServiceLoading());
    final result = await repository.addService(
      name: name,
      details: details,
      price: price,
      categoryId: categoryId,
    );
    result.fold(
      (failure) => emit(AddServiceError(message: failure.message)),
      (message) => emit(AddServiceSuccess(message: message)),
    );
  }

  Future<void> addMultipleServices(List<Map<String, dynamic>> services) async {
    emit(AddServiceLoading());
    bool hasError = false;
    String errorMessage = '';
    String lastMessage = 'Services added successfully';

    for (var service in services) {
      final result = await repository.addService(
        name: service['name'],
        details: service['details'],
        price: service['price'],
        categoryId: service['categories_item_id'],
      );
      result.fold(
        (failure) {
          hasError = true;
          errorMessage = failure.message;
        },
        (message) {
          lastMessage = message;
        },
      );
    }

    if (hasError) {
      emit(AddServiceError(message: errorMessage));
    } else {
      emit(AddServiceSuccess(message: lastMessage));
    }
  }
}
