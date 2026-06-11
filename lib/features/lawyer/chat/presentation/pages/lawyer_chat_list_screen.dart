import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/injection_container.dart' as di;
import '../../../../../core/localization/app_localizations.dart';
import '../cubit/lawyer_chat_list_cubit.dart';
import '../cubit/lawyer_chat_list_state.dart';
import '../cubit/lawyer_chat_messages_cubit.dart';
import '../cubit/lawyer_call_cubit.dart';
import 'lawyer_chat_screen.dart';

class LawyerChatListScreen extends StatelessWidget {
  const LawyerChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<LawyerChatListCubit>()..fetchChatRooms(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(title: AppStrings.chats.tr(context), backBtn: false),
        body: BlocBuilder<LawyerChatListCubit, LawyerChatListState>(
          builder: (context, state) {
            if (state is LawyerChatListLoading) {
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: 6,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, __) => CustomShimmer.rectangular(
                  height: 80.h,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                ),
              );
            }

            if (state is LawyerChatListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48.sp, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(state.message,
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.textSecondary)),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () =>
                          context.read<LawyerChatListCubit>().fetchChatRooms(),
                      child: Text(AppStrings.retry.tr(context)),
                    ),
                  ],
                ),
              );
            }

            if (state is LawyerChatListLoaded) {
              if (state.rooms.isEmpty) {
                return CustomEmptyState(
                  title: AppStrings.noChats.tr(context),
                  subtitle: AppStrings.noClientChatsSubtitle.tr(context),
                  icon: Icons.chat_bubble_outline_rounded,
                );
              }

              return RefreshIndicator(
                color: AppColors.golden,
                onRefresh: () =>
                    context.read<LawyerChatListCubit>().fetchChatRooms(),
                child: ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: state.rooms.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final room = state.rooms[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (_) =>
                                      di.sl<LawyerChatMessagesCubit>(
                                              param1: room.chatRoomId)
                                        ..loadMessages(),
                                ),
                                BlocProvider(
                                  create: (_) =>
                                      di.sl<LawyerCallCubit>(),
                                ),
                              ],
                              child: LawyerChatScreen(
                                chatRoomId: room.chatRoomId,
                                clientName: room.lawyer.name,
                                caseTitle: room.caseTitle,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: context.divColor),
                        ),
                        child: Row(
                          children: [
                            // Avatar with unread badge
                            Stack(
                              children: [
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person_rounded,
                                      color: AppColors.primary, size: 26.sp),
                                ),
                                if (room.unreadCount > 0)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 18.w,
                                      height: 18.w,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${room.unreadCount}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          room.caseTitle.isNotEmpty
                                              ? room.caseTitle
                                              : room.caseNumber,
                                          style: context.text.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.sp),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (room.latestMessage?.createdAt != null)
                                        Text(
                                          _formatTime(
                                              room.latestMessage!.createdAt!,context),
                                          style: context.text.labelSmall
                                              ?.copyWith(
                                                  color: context.textSecondary,
                                                  fontSize: 10.sp),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    room.latestMessage?.getPreview(context) ??
                                        AppStrings.startConversation.tr(context),
                                    style: context.text.bodySmall?.copyWith(
                                      color: room.unreadCount > 0
                                          ? context.textPrimary
                                          : context.textSecondary,
                                      fontWeight: room.unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 11.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    room.caseNumber,
                                    style: context.text.labelSmall?.copyWith(
                                      color: AppColors.golden,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.textSecondary,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  String _formatTime(String dateStr,context) {
    try {
      final dt = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays < 7) {
        const days = [
          AppStrings.monday,
          AppStrings.tuesday,
          AppStrings.wednesday,
          AppStrings.thursday,
          AppStrings.friday,
          AppStrings.saturday,
          AppStrings.sunday
        ];
        return days[dt.weekday - 1].tr(context);
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {
      return '';
    }
  }
}
