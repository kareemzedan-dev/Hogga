import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/tasks/data/models/lawyer_task_model.dart';

abstract class TasksRepository {
  Future<Either<Failure, LawyerTasksResponseModel>> getTasks();
  Future<Either<Failure, void>> addTask({
    required String title,
    required String priority,
    required String dueDate,
    required bool isNotified,
  });
  Future<Either<Failure, void>> updateTaskStatus(int taskId, String status);
  Future<Either<Failure, void>> deleteTask(int taskId);
}
