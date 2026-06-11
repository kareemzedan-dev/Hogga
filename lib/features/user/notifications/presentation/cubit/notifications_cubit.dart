import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository repository;

  NotificationsCubit({required this.repository}) : super(NotificationsInitial());

  Future<void> getNotifications() async {
    emit(NotificationsLoading());
    final result = await repository.getNotifications();
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) => emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: notifications.where((n) => !n.isRead).length,
        ),
      ),
    );
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationsLoaded) {
      return;
    }

    final target = current.notifications
        .where((notification) => notification.id == id)
        .cast<NotificationModel?>()
        .firstOrNull;
    if (target == null || target.isRead) {
      return;
    }

    final result = await repository.markAsRead(id);
    result.fold(
      (_) => null,
      (_) {
        final updated = current.notifications.map((notification) {
          if (notification.id == id) {
            return notification.copyWith(
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
            );
          }
          return notification;
        }).toList();

        emit(
          NotificationsLoaded(
            notifications: updated,
            unreadCount: updated.where((n) => !n.isRead).length,
          ),
        );
      },
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
