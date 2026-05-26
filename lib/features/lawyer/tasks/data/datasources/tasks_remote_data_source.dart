import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/tasks/data/models/lawyer_task_model.dart';

abstract class TasksRemoteDataSource {
  Future<LawyerTasksResponseModel> getTasks();
  Future<void> addTask({
    required String title,
    required String priority,
    required String dueDate,
    required bool isNotified,
  });
  Future<void> updateTaskStatus(int taskId, String status);
  Future<void> deleteTask(int taskId);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final ApiClient apiClient;

  TasksRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<LawyerTasksResponseModel> getTasks() async {
    final response = await apiClient.get(AppEndPoints.lawyerTasksEndPoint);
    return LawyerTasksResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> addTask({
    required String title,
    required String priority,
    required String dueDate,
    required bool isNotified,
  }) async {
    await apiClient.post(
      AppEndPoints.lawyerTasksEndPoint,
      data: {
        'title': title,
        'priority': priority,
        'due_date': dueDate,
        'is_notified': isNotified ? 1 : 0,
      },
    );
  }

  @override
  Future<void> updateTaskStatus(int taskId, String status) async {
    await apiClient.post(
      "${AppEndPoints.lawyerTasksEndPoint}/$taskId/status",
      data: {'status': status},
    );
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await apiClient.post(
      "${AppEndPoints.lawyerTasksEndPoint}/$taskId",
      data: {'_method': 'DELETE'},
    );
  }
}
