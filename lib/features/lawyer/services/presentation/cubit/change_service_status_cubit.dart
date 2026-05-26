import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class ChangeServiceStatusState {}

class ChangeServiceStatusInitial extends ChangeServiceStatusState {}

class ChangeServiceStatusLoading extends ChangeServiceStatusState {
  final int id;
  final bool optimisticStatus;
  ChangeServiceStatusLoading({required this.id, required this.optimisticStatus});
}

class ChangeServiceStatusSuccess extends ChangeServiceStatusState {
  final int id;
  final String message;
  final bool newStatus;
  ChangeServiceStatusSuccess({required this.id, required this.message, required this.newStatus});
}

class ChangeServiceStatusError extends ChangeServiceStatusState {
  final int id;
  final String message;
  final bool rollbackStatus;
  ChangeServiceStatusError({required this.id, required this.message, required this.rollbackStatus});
}

class ChangeServiceStatusCubit extends Cubit<ChangeServiceStatusState> {
  final ServicesRepository repository;
  bool _isProcessing = false;

  ChangeServiceStatusCubit({required this.repository}) : super(ChangeServiceStatusInitial());

  Future<void> changeStatus(int id, bool currentStatus) async {
    if (_isProcessing) return; // Request Locking: Throttle behavior
    _isProcessing = true;

    // Optimistic Update
    final newStatus = !currentStatus;
    emit(ChangeServiceStatusLoading(id: id, optimisticStatus: newStatus));

    final result = await repository.changeServiceStatus(id);
    
    result.fold(
      (failure) {
        _isProcessing = false;
        emit(ChangeServiceStatusError(
          id: id,
          message: failure.message,
          rollbackStatus: currentStatus,
        ));
      },
      (message) {
        _isProcessing = false;
        emit(ChangeServiceStatusSuccess(
          id: id,
          message: message,
          newStatus: newStatus,
        ));
      },
    );
  }
}
