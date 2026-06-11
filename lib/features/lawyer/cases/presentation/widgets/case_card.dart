import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_status_badge.dart';
import 'package:hogga/core/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/injection_container.dart' as di;

import '../../../../../core/localization/app_localizations.dart';
import '../../../chat/presentation/cubit/lawyer_chat_messages_cubit.dart';
import '../../../chat/presentation/cubit/lawyer_call_cubit.dart';
import '../../../chat/presentation/pages/lawyer_chat_screen.dart';
import '../../../chat/presentation/pages/lawyer_agora_call_screen.dart';

class CaseCard extends StatelessWidget {
  final LawyerCase lawyerCase;

  const CaseCard({super.key, required this.lawyerCase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: HoggaCard(
        color: context.cardBg,
        padding: EdgeInsets.all(20.w),
        borderRadius: 20.r,
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.lawyerCaseDetails,
            arguments: {'id': lawyerCase.id, 'title': lawyerCase.title},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: icon + title + case number ──
            Row(
              children: [
                // Container(
                //   padding: EdgeInsets.all(10.w),
                //   decoration: BoxDecoration(
                //     color: _serviceColor().withValues(alpha: 0.12),
                //     shape: BoxShape.circle,
                //   ),
                //   child: Icon(_getServiceIcon(), size: 20.sp, color: _serviceColor()),
                // ),
                // SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyerCase.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(Icons.person_outline_rounded,
                                    size: 12.sp, color: context.textSecondary),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    lawyerCase.clientName.isNotEmpty
                                        ? lawyerCase.clientName
                                        : AppStrings.client.tr(context),
                                    style: context.text.labelSmall?.copyWith(
                                      color: context.textSecondary,
                                      fontSize: 11.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: context.chipBg,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: context.divColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  lawyerCase.realCaseNumber.isNotEmpty
                                      ? lawyerCase.realCaseNumber
                                      : '#${lawyerCase.id}',
                                  style: context.text.labelSmall?.copyWith(
                                    color: AppColors.golden,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Text(
                                  AppStrings.referenceNumber.tr(context),
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.textSecondary,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Divider(height: 1, thickness: 0.8, color: context.divColor),
            ),

            // ── Badges row: service type + case status ──
            Row(
              children: [
                _buildBadge(
                  context: context,
                  icon: _getServiceIcon(),
                  label: lawyerCase.serviceTypeText.isNotEmpty
                      ? lawyerCase.serviceTypeText
                      : lawyerCase.serviceType,
                  color: _serviceColor(),
                ),
                SizedBox(width: 8.w),
                LawyerStatusBadge(text: lawyerCase.statusText.toLocalizedStatus(context)),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Divider(height: 1, thickness: 0.8, color: context.divColor),
            ),

            // ── Bottom: date + court + status ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_outlined, size: 13.sp, color: AppColors.golden),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              lawyerCase.date,
                              style: context.text.bodySmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (lawyerCase.court != null && lawyerCase.court!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 13.sp, color: AppColors.golden),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                lawyerCase.court!,
                                style: context.text.bodySmall?.copyWith(
                                  color: context.textSecondary,
                                  fontSize: 11.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            // ── Action buttons (only shown if accepted & has chat room) ──
            if (lawyerCase.statusKey == 'accepted' && lawyerCase.hasChatRoom)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _openService(context),
                    icon: Icon(
                      _getActionIcon(),
                      size: 18.sp,
                      color: _serviceColor(),
                    ),
                    label: Text(
                      _getActionLabel(context),
                      style: context.text.labelLarge?.copyWith(
                        color: _serviceColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _serviceColor()),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                    ),
                  ),
                ),
              ),


          ],
        ),
      ),
    );
  }

  void _openService(BuildContext context) {
    final serviceType = lawyerCase.serviceType;
    if (serviceType == 'video' || serviceType == 'audio' || serviceType == 'phone') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<LawyerCallCubit>(),
            child: LawyerAgoraCallScreen(
              roomId: lawyerCase.chatRoomId!,
              clientName: lawyerCase.clientName,
              isVideo: serviceType == 'video',
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => di.sl<LawyerChatMessagesCubit>(param1: lawyerCase.chatRoomId!)
                  ..loadMessages(),
              ),
              BlocProvider(
                create: (_) => di.sl<LawyerCallCubit>(),
              ),
            ],
            child: LawyerChatScreen(
              chatRoomId: lawyerCase.chatRoomId!,
              clientName: lawyerCase.clientName,
              caseTitle: lawyerCase.title,
            ),
          ),
        ),
      );
    }
  }

  IconData _getActionIcon() {
    switch (lawyerCase.serviceType) {
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
      case 'phone':
        return Icons.phone_in_talk_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String _getActionLabel(BuildContext context) {
    switch (lawyerCase.serviceType) {
      case 'video':
        return AppStrings.videoCall.tr(context);
      case 'audio':
      case 'phone':
        return AppStrings.voiceCall.tr(context);
      default:
        return AppStrings.startConversation.tr(context);
    }
  }

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon() {
    switch (lawyerCase.serviceType) {
      case 'video':
        return Icons.videocam_outlined;
      case 'audio':
      case 'phone':
        return Icons.phone_outlined;
      case 'chat':
        return Icons.chat_outlined;
      case 'article':
      default:
        return Icons.article_outlined;
    }
  }

  Color _serviceColor() {
    switch (lawyerCase.serviceType) {
      case 'video':
        return const Color(0xFF9B59B6);
      case 'audio':
      case 'phone':
        return const Color(0xFF27AE60);
      case 'chat':
        return const Color(0xFF2D9CDB);
      case 'article':
      default:
        return AppColors.golden;
    }
  }
}
