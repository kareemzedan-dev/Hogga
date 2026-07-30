import 'package:dartz/dartz.dart';
import '../../../../../config/shared_preference/shared_preference.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String notificationId);
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final ApiClient apiClient;

  NotificationsRepositoryImpl({required this.apiClient});

  bool get _isLawyerAccount {
    final prefs = AppPreferences();
    final role = prefs.role.toLowerCase();
    return prefs.isProvider || role == 'lawyer' || role == 'provider';
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final isLawyer = _isLawyerAccount;
      final endpoint = isLawyer
          ? AppEndPoints.lawyerNotificationsEndPoint
          : AppEndPoints.notificationsEndPoint;

      final response = await apiClient.get(endpoint);
      final isSuccess =
          response.data['success'] == true || response.data['status'] == true;
      if (!isSuccess) {
        return Left(
          ServerFailure(
            response.data['message']?.toString() ??
                'Failed to fetch notifications',
          ),
        );
      }

      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      final notifications = data
          .whereType<Map>()
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      final isLawyer = _isLawyerAccount;
      final endpoint = isLawyer
          ? '${AppEndPoints.lawyerMarkAsReadEndPoint}/$notificationId'
          : '${AppEndPoints.markAsReadEndPoint}/$notificationId';

      final response = await apiClient.post(endpoint);
      final isSuccess =
          response.data['success'] == true || response.data['status'] == true;
      if (isSuccess) {
        return const Right(null);
      }

      return Left(
        ServerFailure(
          response.data['message']?.toString() ?? 'Failed to mark as read',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
