import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/tasks/domain/repositories/tasks_repository.dart';
import 'package:hogga/features/lawyer/tasks/data/datasources/tasks_remote_data_source.dart';
import 'package:hogga/features/lawyer/tasks/data/models/lawyer_task_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;

  TasksRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LawyerTasksResponseModel>> getTasks() async {
    try {
      final remoteData = await remoteDataSource.getTasks();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTask({
    required String title,
    required String priority,
    required String dueDate,
    required bool isNotified,
  }) async {
    try {
      await remoteDataSource.addTask(
        title: title,
        priority: priority,
        dueDate: dueDate,
        isNotified: isNotified,
      );
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskStatus(int taskId, String status) async {
    try {
      await remoteDataSource.updateTaskStatus(taskId, status);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
