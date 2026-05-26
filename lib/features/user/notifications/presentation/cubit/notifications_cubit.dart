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

  const NotificationsLoaded({required this.notifications, required this.unreadCount});

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
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(notifications: notifications, unreadCount: unreadCount));
      },
    );
  }

  Future<void> markAsRead(int id) async {
    final result = await repository.markAsRead(id);
    result.fold(
      (failure) => null, // Silently fail or handle error
      (_) {
        if (state is NotificationsLoaded) {
          final current = state as NotificationsLoaded;
          final List<NotificationModel> updated = current.notifications.map((NotificationModel n) {
            if (n.id == id) {
              return NotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                createdAt: n.createdAt,
                isRead: true,
                type: n.type,
              );
            }
            return n;
          }).toList();
          final unreadCount = updated.where((n) => !n.isRead).length;
          emit(NotificationsLoaded(notifications: updated, unreadCount: unreadCount));
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();
    result.fold(
      (failure) => null,
      (_) {
        if (state is NotificationsLoaded) {
          final current = state as NotificationsLoaded;
          final List<NotificationModel> updated = current.notifications.map((NotificationModel n) => NotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                createdAt: n.createdAt,
                isRead: true,
                type: n.type,
              )).toList();
          emit(NotificationsLoaded(notifications: updated, unreadCount: 0));
        }
      },
    );
  }
}
