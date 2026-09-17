import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/chat/data/repositories/chat_repository.dart';
import 'package:hogga/features/lawyer/chat/data/repositories/lawyer_chat_repository.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case.dart';
import 'package:hogga/features/lawyer/cases/domain/repositories/cases_repository.dart';
import 'package:hogga/features/lawyer/proposals/presentation/pages/lawyer_opportunity_details_screen.dart';
import 'package:hogga/features/user/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:hogga/features/user/notifications/data/models/notification_model.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/injection_container.dart' as di;
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.notifications.tr(context),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return _buildLoadingState();
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return CustomEmptyState(
                title: AppStrings.noNotifications.tr(context),
                subtitle: AppStrings.noNotificationsSubtitle.tr(context),
                icon: Icons.notifications_none_rounded,
              );
            }
            return _buildNotificationsList(context, state.notifications);
          } else if (state is NotificationsError) {
            return CustomErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<NotificationsCubit>().getNotifications(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerItem(context),
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: context.divColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150.w, height: 12.h, color: context.divColor),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 10.h,
                  color: context.divColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().getNotifications(),
      color: context.accentGolden,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationItem(notification: notification);
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  bool get _isCallNotification {
    final type = notification.type?.toLowerCase() ?? '';
    final actionType = notification.actionType?.toLowerCase() ?? '';

    return type == 'incoming_call' ||
        type == 'audio_call' ||
        type == 'video_call' ||
        type.contains('call') ||
        actionType.contains('call') ||
        notification.callId != null;
  }

  bool get _isCaseNotification {
    final type = notification.type?.toLowerCase() ?? '';
    final actionType = notification.actionType?.toLowerCase() ?? '';

    return notification.caseId != null ||
        notification.consultationId != null ||
        notification.recordType == 'consultation' ||
        actionType == 'case_accepted' ||
        actionType.contains('case') ||
        actionType.contains('legal') ||
        actionType.contains('proposal') ||
        actionType.contains('consultation') ||
        type == 'order_status' ||
        type == 'legal_case_update' ||
        type == 'payment' ||
        type.contains('consultation') ||
        type.contains('case') ||
        type.contains('legal');
  }

  bool get _isLawyerAccount {
    final prefs = AppPreferences();
    final role = prefs.role.toLowerCase();
    return prefs.isProvider || role == 'lawyer' || role == 'provider';
  }

  void _openCasesList(BuildContext context, bool isLawyer) {
    if (isLawyer) {
      Navigator.pushNamed(context, AppRoutes.lawyerMain, arguments: 2);
      return;
    }

    Navigator.pushNamed(context, AppRoutes.myOrders);
  }

  Future<int?> _resolveCaseId(bool isLawyer) async {
    final caseId = notification.caseId;
    if (caseId != null && caseId > 0) {
      return caseId;
    }

    final roomId = notification.chatRoomId;
    if (roomId == null || roomId <= 0) {
      return null;
    }

    try {
      final rooms = isLawyer
          ? await di.sl<LawyerChatRepository>().getChatRooms()
          : await di.sl<ChatRepository>().getChatRooms();
      for (final room in rooms) {
        if (room.chatRoomId == roomId && room.legalCaseId > 0) {
          return room.legalCaseId;
        }
      }
    } catch (_) {}

    if (isLawyer) {
      final lawyerCase = await _findLawyerCase(roomId: roomId);
      if (lawyerCase != null) {
        return lawyerCase.id;
      }
    }

    return null;
  }

  Future<LawyerCase?> _findLawyerCase({int? caseId, int? roomId}) async {
    if ((caseId == null || caseId <= 0) && (roomId == null || roomId <= 0)) {
      return null;
    }

    try {
      final result = await di.sl<CasesRepository>().getCases(type: 'all');
      return result.fold((_) => null, (cases) {
        for (final lawyerCase in cases) {
          final matchesCase = caseId != null && lawyerCase.id == caseId;
          final matchesRoom = roomId != null && lawyerCase.chatRoomId == roomId;
          if (matchesCase || matchesRoom) {
            return lawyerCase;
          }
        }
        return null;
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> _openCaseDetails(BuildContext context) async {
    final isLawyer = _isLawyerAccount;
    final isConsultation =
        notification.recordType == 'consultation' ||
        notification.consultationId != null;
    final consultationId = notification.consultationId;
    final caseId = await _resolveCaseId(isLawyer);

    if (!context.mounted) {
      return;
    }

    if (isConsultation && consultationId != null && consultationId > 0) {
      if (isLawyer) {
        Navigator.pushNamed(
          context,
          AppRoutes.lawyerConsultationDetails,
          arguments: consultationId,
        );
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.myOrderDetails,
        arguments: {'orderId': consultationId, 'recordType': 'consultation'},
      );
      return;
    }

    if (caseId != null && caseId > 0) {
      final actionType = notification.actionType?.toLowerCase() ?? '';
      if (isLawyer && actionType == 'new_case_request') {
        final existingCase = await _findLawyerCase(
          caseId: caseId,
          roomId: notification.chatRoomId,
        );
        if (!context.mounted) {
          return;
        }
        if (existingCase != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.lawyerCaseDetails,
            arguments: {'id': existingCase.id, 'title': existingCase.title},
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LawyerOpportunityDetailsScreen(
              requestId: caseId,
              isDirectRequest: true,
            ),
          ),
        );
        return;
      }

      if (isLawyer) {
        Navigator.pushNamed(
          context,
          AppRoutes.lawyerCaseDetails,
          arguments: {'id': caseId, 'title': notification.title},
        );
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.myOrderDetails,
        arguments: {'orderId': caseId, 'recordType': 'service'},
      );
      return;
    }

    AppSnackbar.showInfo(context, messageKey: AppStrings.noDataFound);
  }

  Future<void> _handleTap(BuildContext context) async {
    try {
      if (!notification.isRead) {
        await context.read<NotificationsCubit>().markAsRead(notification.id);
        if (!context.mounted) {
          return;
        }
      }

      if (_isCallNotification) {
        await _openCaseDetails(context);
        return;
      }

      final type = notification.type?.toLowerCase() ?? '';
      final actionType = notification.actionType?.toLowerCase() ?? '';
      final isChat = (notification.chatRoomId != null && notification.chatRoomId! > 0) &&
          (type == 'chat_message' ||
              type == 'new_message' ||
              type == 'message' ||
              type == 'chat' ||
              actionType == 'chat_message' ||
              actionType == 'new_message' ||
              actionType == 'chat');

      if (isChat) {
        final isLawyer = _isLawyerAccount;
        Navigator.pushNamed(
          context,
          isLawyer ? AppRoutes.lawyerChat : AppRoutes.chat,
          arguments: {
            'chatRoomId': notification.chatRoomId,
            'clientName': notification.callerName ?? notification.title,
            'lawyerName': notification.callerName ?? notification.title,
            'caseTitle': notification.title,
            'serviceType': 'chat',
          },
        );
        return;
      }

      if (_isCaseNotification) {
        await _openCaseDetails(context);
        return;
      }

      if (type == 'notification') {
        _openCasesList(context, _isLawyerAccount);
        return;
      }

      // If it's a general or informational notification, it is now marked as read.
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.showInfo(context, messageKey: AppStrings.noDataFound);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unawaited(_handleTap(context)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: notification.isRead
              ? context.cardBg
              : context.accentGolden.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead
                ? context.divColor
                : context.accentGolden.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            if (!notification.isRead)
              BoxShadow(
                color: context.accentGolden.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(context),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.bold
                                : FontWeight.w900,
                            color: notification.isRead
                                ? context.textPrimary
                                : context.accentGolden,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    notification.body,
                    style: context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _formatDate(context, notification.createdAt),
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary.withValues(alpha: 0.6),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return AppStrings.minutesAgo.tr(
        context,
        namedArgs: {'count': difference.inMinutes.toString()},
      );
    } else if (difference.inHours < 24) {
      return AppStrings.hoursAgo.tr(
        context,
        namedArgs: {'count': difference.inHours.toString()},
      );
    } else if (difference.inDays < 7) {
      return AppStrings.daysAgo.tr(
        context,
        namedArgs: {'count': difference.inDays.toString()},
      );
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(date);
    }
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'order_update':
        icon = Icons.assignment_outlined;
        color = Colors.blue;
        break;
      case 'payment':
        icon = Icons.account_balance_wallet_outlined;
        color = Colors.green;
        break;
      case 'system':
        icon = Icons.info_outline_rounded;
        color = context.accentGolden;
        break;
      default:
        icon = Icons.notifications_active_outlined;
        color = context.accentGolden;
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}
