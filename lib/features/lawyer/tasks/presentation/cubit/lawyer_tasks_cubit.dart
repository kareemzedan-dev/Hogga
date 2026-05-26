import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/tasks/domain/repositories/tasks_repository.dart';
import 'package:hogga/features/lawyer/tasks/data/models/lawyer_task_model.dart';

abstract class LawyerTasksState {}

class LawyerTasksInitial extends LawyerTasksState {}

class LawyerTasksLoading extends LawyerTasksState {}

class LawyerTasksLoaded extends LawyerTasksState {
  final LawyerTasksResponseModel data;
  LawyerTasksLoaded({required this.data});
}

class LawyerTasksError extends LawyerTasksState {
  final String message;
  LawyerTasksError({required this.message});
}

class LawyerTaskActionError extends LawyerTasksState {
  final String message;
  LawyerTaskActionError({required this.message});
}

class LawyerTaskActionSuccess extends LawyerTasksState {}

class LawyerTasksCubit extends Cubit<LawyerTasksState> {
  final TasksRepository repository;

  LawyerTasksResponseModel? _currentData;

  LawyerTasksCubit({required this.repository}) : super(LawyerTasksInitial());

  Future<void> fetchTasks() async {
    if (_currentData == null) emit(LawyerTasksLoading());
    final result = await repository.getTasks();
    result.fold(
      (failure) {
        if (_currentData == null) {
          emit(LawyerTasksError(message: failure.message));
        } else {
          emit(LawyerTaskActionError(message: failure.message));
          emit(LawyerTasksLoaded(data: _currentData!));
        }
      },
      (data) {
        _currentData = data;
        emit(LawyerTasksLoaded(data: data));
      },
    );
  }

  Future<void> addTask({
    required String title,
    required String priority,
    required String dueDate,
    required bool isNotified,
  }) async {
    final result = await repository.addTask(
      title: title,
      priority: priority,
      dueDate: dueDate,
      isNotified: isNotified,
    );
    result.fold(
      (failure) {
        emit(LawyerTaskActionError(message: failure.message));
        if (_currentData != null) emit(LawyerTasksLoaded(data: _currentData!));
      },
      (_) {
        emit(LawyerTaskActionSuccess());
        fetchTasks();
      },
    );
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    final result = await repository.updateTaskStatus(taskId, status);
    result.fold(
      (failure) {
        emit(LawyerTaskActionError(message: failure.message));
        if (_currentData != null) emit(LawyerTasksLoaded(data: _currentData!));
      },
      (_) {
        emit(LawyerTaskActionSuccess());
        fetchTasks();
      },
    );
  }

  Future<void> deleteTask(int taskId) async {
    final result = await repository.deleteTask(taskId);
    result.fold(
      (failure) {
        emit(LawyerTaskActionError(message: failure.message));
        if (_currentData != null) emit(LawyerTasksLoaded(data: _currentData!));
      },
      (_) {
        emit(LawyerTaskActionSuccess());
        fetchTasks();
      },
    );
  }
}
