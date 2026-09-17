import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/widgets/custom_network_image.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/injection_container.dart' as di;
import '../../../../core/localization/app_localizations.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../cubit/chat_messages_cubit.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ChatListCubit>()..fetchChatRooms(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(title: AppStrings.chats.tr(context), backBtn: false),
        body: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading) {
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: 6,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, __) => CustomShimmer.rectangular(
                  height: 80.h,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              );
            }

            if (state is ChatListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () =>
                          context.read<ChatListCubit>().fetchChatRooms(),
                      child: Text(AppStrings.retry.tr(context)),
                    ),
                  ],
                ),
              );
            }

            if (state is ChatListLoaded) {
              if (state.rooms.isEmpty) {
                return CustomEmptyState(
                  title: AppStrings.noChats.tr(context),
                  subtitle: AppStrings.noLawyerChatsSubtitle.tr(context),
                  icon: Icons.forum_outlined,
                );
              }

              return RefreshIndicator(
                color: AppColors.golden,
                onRefresh: () => context.read<ChatListCubit>().fetchChatRooms(),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                            builder: (_) => BlocProvider(
                              create: (_) => di.sl<ChatMessagesCubit>(
                                param1: room.chatRoomId,
                              )..loadMessages(),
                              child: ChatScreen(
                                chatRoomId: room.chatRoomId,
                                lawyerName: room.lawyer.name,
                                lawyerPhoto: room.lawyer.photo,
                                caseTitle: room.caseTitle.isNotEmpty
                                    ? room.caseTitle
                                    : room.caseNumber,
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
                            // Avatar
                            Stack(
                              children: [
                                _ChatAvatar(photoUrl: room.lawyer.photo),
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
                                          room.lawyer.name,
                                          style: context.text.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.5.sp,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (room.latestMessage?.createdAt != null)
                                        Text(
                                          _formatTime(
                                            room.latestMessage!.createdAt!,
                                            context,
                                          ),
                                          style: context.text.labelSmall
                                              ?.copyWith(
                                                color: context.textSecondary,
                                                fontSize: 9.sp,
                                              ),
                                        ),
                                    ],
                                  ),
                                  if (room.caseTitle.isNotEmpty ||
                                      room.caseNumber.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.golden.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6.r),
                                        border: Border.all(
                                          color: AppColors.golden.withValues(
                                            alpha: 0.25,
                                          ),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 1.h),
                                            child: Icon(
                                              Icons.balance_rounded,
                                              size: 11.sp,
                                              color: AppColors.golden,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Flexible(
                                            child: Text(
                                              room.caseTitle.isNotEmpty &&
                                                      room.caseNumber.isNotEmpty
                                                  ? '${room.caseTitle} • ${room.caseNumber}'
                                                  : (room.caseTitle.isNotEmpty
                                                      ? room.caseTitle
                                                      : room.caseNumber),
                                              style: context.text.labelSmall
                                                  ?.copyWith(
                                                    color: AppColors.golden,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 9.5.sp,
                                                    height: 1.2,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 4.h),
                                  Text(
                                    room.latestMessage?.getPreview(context) ??
                                        AppStrings.startConversation.tr(
                                          context,
                                        ),
                                    style: context.text.bodySmall?.copyWith(
                                      color: room.unreadCount > 0
                                          ? context.textPrimary
                                          : context.textSecondary,
                                      fontWeight: room.unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 10.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

  String _formatTime(String dateStr, context) {
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
          AppStrings.sunday,
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

class _ChatAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ChatAvatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl?.trim();
    final fallback = _PersonAvatar(size: 52.w);

    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.toLowerCase() == 'null') {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(26.r),
      child: CustomNetworkImage(
        imageUrl: imageUrl,
        width: 52.w,
        height: 52.w,
        fit: BoxFit.cover,
        errorWidget: fallback,
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  final double size;

  const _PersonAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: size * 0.5,
      ),
    );
  }
}
