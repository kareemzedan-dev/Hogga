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
    final serviceLabel = lawyerCase.serviceTypeText.isNotEmpty
        ? lawyerCase.serviceTypeText
        : lawyerCase.serviceType;
    final showServiceType = _shouldShowServiceType(
      lawyerCase.serviceType,
      lawyerCase.serviceTypeText,
    );
    final showChatBadge =
        lawyerCase.hasChatRoom &&
        !_isCallType(lawyerCase.serviceType.toLowerCase());

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: HoggaCard(
        color: context.cardBg,
        padding: EdgeInsets.all(16.w),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _serviceColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    _getServiceIcon(),
                    size: 22.sp,
                    color: _serviceColor(),
                  ),
                ),
                SizedBox(width: 12.w),
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
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 12.sp,
                            color: context.textSecondary,
                          ),
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
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.chipBg,
                    borderRadius: BorderRadius.circular(10.r),
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
                          fontWeight: FontWeight.w700,
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

            if (showServiceType || showChatBadge) ...[
              SizedBox(height: 12.h),

              // ── Badges row: service type + chat ──
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  if (showServiceType)
                    _buildBadge(
                      context: context,
                      icon: _getServiceIcon(),
                      label: serviceLabel,
                      color: _serviceColor(),
                    ),
                  if (showChatBadge) ...[
                    _buildBadge(
                      context: context,
                      icon: Icons.chat_bubble_outline_rounded,
                      label: AppStrings.chat.tr(context),
                      color: AppColors.golden,
                    ),
                  ],
                ],
              ),
            ],

            SizedBox(height: 14.h),

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
                          Icon(
                            Icons.event_outlined,
                            size: 13.sp,
                            color: AppColors.golden,
                          ),
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
                      if (lawyerCase.court != null &&
                          lawyerCase.court!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13.sp,
                              color: AppColors.golden,
                            ),
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
                SizedBox(width: 8.w),
                LawyerStatusBadge(
                  text: lawyerCase.statusText.toLocalizedStatus(context),
                ),
              ],
            ),

            // ── Action button: one communication method per service type ──
            if (lawyerCase.statusKey == 'accepted' &&
                lawyerCase.hasChatRoom &&
                _hasCommunicationAction())
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 42.h,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _serviceColor(), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
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
    final serviceType = lawyerCase.serviceType.toLowerCase();
    if (_isCallType(serviceType)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<LawyerCallCubit>(),
            child: LawyerAgoraCallScreen(
              roomId: lawyerCase.chatRoomId!,
              clientName: lawyerCase.clientName,
              isVideo: _isVideoType(serviceType),
            ),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  di.sl<LawyerChatMessagesCubit>(param1: lawyerCase.chatRoomId!)
                    ..loadMessages(),
            ),
            BlocProvider(create: (_) => di.sl<LawyerCallCubit>()),
          ],
          child: LawyerChatScreen(
            chatRoomId: lawyerCase.chatRoomId!,
            clientName: lawyerCase.clientName,
            caseTitle: lawyerCase.title,
            isCall: _isCallType(serviceType),
            isVideo: _isVideoType(serviceType),
          ),
        ),
      ),
    );
  }

  bool _hasCommunicationAction() {
    return lawyerCase.hasChatRoom;
  }

  IconData _getActionIcon() {
    final serviceType = lawyerCase.serviceType.toLowerCase();
    if (_isVideoType(serviceType)) {
      return Icons.videocam_rounded;
    }
    if (_isCallType(serviceType)) {
      return Icons.phone_in_talk_rounded;
    }
    return Icons.chat_bubble_outline_rounded;
  }

  String _getActionLabel(BuildContext context) {
    final serviceType = lawyerCase.serviceType.toLowerCase();
    if (_isVideoType(serviceType)) {
      return AppStrings.videoCall.tr(context);
    }
    if (_isCallType(serviceType)) {
      return AppStrings.voiceCall.tr(context);
    }
    return AppStrings.enterChat.tr(context);
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
    final serviceType = lawyerCase.serviceType.toLowerCase();
    if (_isVideoType(serviceType)) {
      return Icons.videocam_rounded;
    }
    if (_isCallType(serviceType)) {
      return Icons.phone_in_talk_rounded;
    }
    if (serviceType.contains('chat') || serviceType == 'normal') {
      return Icons.chat_outlined;
    }
    return Icons.article_outlined;
  }

  Color _serviceColor() {
    final serviceType = lawyerCase.serviceType.toLowerCase();
    if (_isVideoType(serviceType)) {
      return const Color(0xFF6C205F);
    }
    if (_isCallType(serviceType)) {
      return const Color(0xFF27AE60);
    }
    return AppColors.golden;
  }

  bool _shouldShowServiceType(String type, String typeText) {
    final normalizedType = type.trim().toLowerCase();
    final normalizedText = typeText.trim().toLowerCase();
    final label = normalizedText.isNotEmpty ? normalizedText : normalizedType;
    return label.isNotEmpty && label != 'normal';
  }

  bool _isVideoType(String serviceType) {
    return serviceType.contains('video');
  }

  bool _isCallType(String serviceType) {
    return _isVideoType(serviceType) ||
        serviceType.contains('audio') ||
        serviceType.contains('phone') ||
        serviceType.contains('call');
  }
}
