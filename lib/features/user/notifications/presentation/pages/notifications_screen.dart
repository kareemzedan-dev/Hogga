import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/user/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:hogga/features/user/notifications/data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.notifications.tr(context),
          style: context.theme.appBarTheme.titleTextStyle,
        ),
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
              onRetry: () => context.read<NotificationsCubit>().getNotifications(),
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
            decoration: BoxDecoration(color: context.divColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150.w, height: 12.h, color: context.divColor),
                SizedBox(height: 8.h),
                Container(width: double.infinity, height: 10.h, color: context.divColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<NotificationModel> notifications) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsCubit>().markAsRead(notification.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: notification.isRead ? context.cardBg : context.accentGolden.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead ? context.divColor : context.accentGolden.withValues(alpha: 0.3),
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
                            fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w900,
                            color: notification.isRead ? context.textPrimary : context.accentGolden,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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
      return AppStrings.minutesAgo.tr(context, namedArgs: {'count': difference.inMinutes.toString()});
    } else if (difference.inHours < 24) {
      return AppStrings.hoursAgo.tr(context, namedArgs: {'count': difference.inHours.toString()});
    } else if (difference.inDays < 7) {
      return AppStrings.daysAgo.tr(context, namedArgs: {'count': difference.inDays.toString()});
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
