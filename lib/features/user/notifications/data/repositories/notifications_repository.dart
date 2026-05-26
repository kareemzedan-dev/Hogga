import 'package:dartz/dartz.dart';
import '../../../../../config/shared_preference/shared_preference.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(int notificationId);
  Future<Either<Failure, void>> markAllAsRead();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final ApiClient apiClient;

  NotificationsRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final isLawyer = AppPreferences().isProvider;
      final endpoint = isLawyer ? AppEndPoints.lawyerNotificationsEndPoint : AppEndPoints.notificationsEndPoint;
      
      final response = await apiClient.get(endpoint);
      if (response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return Right(data.map((e) => NotificationModel.fromJson(e)).toList());
      }
      return Left(ServerFailure(response.data['message'] ?? 'Failed to fetch notifications'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    try {
      final isLawyer = AppPreferences().isProvider;
      final endpoint = isLawyer ? AppEndPoints.lawyerMarkAsReadEndPoint : AppEndPoints.markAsReadEndPoint;
      
      final response = await apiClient.post('$endpoint/$notificationId');
      if (response.data['success'] == true) {
        return const Right(null);
      }
      return Left(ServerFailure(response.data['message'] ?? 'Failed to mark as read'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      final isLawyer = AppPreferences().isProvider;
      final endpoint = isLawyer ? AppEndPoints.lawyerMarkAsReadEndPoint : AppEndPoints.markAsReadEndPoint;

      final response = await apiClient.post(endpoint);
      if (response.data['success'] == true) {
        return const Right(null);
      }
      return Left(ServerFailure(response.data['message'] ?? 'Failed to mark all as read'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
