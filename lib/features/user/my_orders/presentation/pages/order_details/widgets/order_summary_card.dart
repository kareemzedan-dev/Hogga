import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_status_badge.dart';
import '../../../../data/models/order_details.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderDetailsData order;
  final VoidCallback onViewDetails;
  final VoidCallback onCancelOrder;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenCall;
  final VoidCallback? onOpenConversation;
  final VoidCallback? onCompleteOrder;
  final bool isCompleting;

  const OrderSummaryCard({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.onCancelOrder,
    this.onOpenChat,
    this.onOpenCall,
    this.onOpenConversation,
    this.onCompleteOrder,
    this.isCompleting = false,
  });

  bool get canCancel => order.status == 'pending';

  bool get _isCall {
    if (!order.isConsultation) return false;
    final key = order.serviceTypeKey.toLowerCase();
    final text = order.serviceTypeText.toLowerCase();
    final prod = order.title.toLowerCase();
    return order.isCallType ||
        (key.isNotEmpty &&
            (key.contains('video') ||
                key.contains('audio') ||
                key.contains('voice') ||
                key.contains('call'))) ||
        text.contains('فيديو') ||
        text.contains('صوت') ||
        text.contains('مكالمة') ||
        prod.contains('فيديو') ||
        prod.contains('صوت') ||
        prod.contains('مكالمة');
  }

  bool get _isWritten {
    if (!order.isConsultation) return false;
    final key = order.serviceTypeKey.toLowerCase();
    final text = order.serviceTypeText.toLowerCase();
    final prod = order.title.toLowerCase();
    return (key.isNotEmpty &&
            (key.contains('article') || key.contains('written'))) ||
        text.contains('مكتوب') ||
        prod.contains('مكتوب');
  }

  Color get _callColor => const Color(0xFF27AE60);

  IconData get _callIcon => Icons.phone_in_talk_rounded;

  @override
  Widget build(BuildContext context) {
    final hasChatAction =
        order.hasChatRoom && (onOpenChat != null || onOpenConversation != null);
    final effectiveChatCallback = onOpenChat ?? onOpenConversation;
    final hasCallAction =
        order.hasChatRoom && _isCall && !_isWritten && onOpenCall != null;
    final hasCompleteAction =
        order.canCompleteByUser && onCompleteOrder != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.title,
                  style: context.text.labelMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.category.name,
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            AppStrings.date.tr(context),
            _formatDateString(context, order.createdAt),
          ),
          if (order.financials.paymentMethod.isNotEmpty)
            _buildInfoRow(
              context,
              AppStrings.paymentMethod.tr(context),
              order.financials.paymentMethod,
            ),
          _buildInfoRow(
            context,
            AppStrings.paymentStatus.tr(context),
            order.financials.displayPaymentStatus,
          ),

          // ── Call Duration Banner (calls only) ──
          if (_isCall && !_isWritten && order.callDuration != null) ...[
            const SizedBox(height: 8),
            _buildCallDurationBanner(context),
          ],

          const SizedBox(height: 16),
          Text(
            (order.isConsultation
                    ? AppStrings.consultationSubject
                    : AppStrings.requestDetails)
                .tr(context),
            style: context.text.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.description,
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18.h),

          // ── Action Row (Attachments + Cancel [when pending], or Attachments + Call/Chat [when active]) ──
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: onViewDetails,
                    icon: Icon(
                      Icons.attach_file_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      AppStrings.attachedDocuments.tr(context),
                      style: context.text.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accentGolden,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ),
              if (canCancel) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: onCancelOrder,
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        AppStrings.cancelOrder.tr(context),
                        style: context.text.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (hasCallAction) ...[
                SizedBox(width: 8.w),
                _buildIconActionButton(
                  icon: _callIcon,
                  color: _callColor,
                  onTap: onOpenCall!,
                  tooltip: AppStrings.makeVoiceCall.tr(context),
                ),
              ],
              if (hasChatAction) ...[
                SizedBox(width: 8.w),
                _buildIconActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF2D9CDB),
                  onTap: effectiveChatCallback!,
                  tooltip: AppStrings.chat.tr(context),
                ),
              ],
            ],
          ),

          // ── Complete Order Button ──
          if (hasCompleteAction) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: onCompleteOrder,
                icon: isCompleting
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.done_all_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                label: Text(
                  (order.isConsultation
                          ? AppStrings.completeConsultation
                          : AppStrings.completeService)
                      .tr(context),
                  style: context.text.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: 48.h,
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Center(child: Icon(icon, color: color, size: 20.sp)),
        ),
      ),
    );
  }

  Widget _buildCallDurationBanner(BuildContext context) {
    final cd = order.callDuration!;
    final total = cd.safeTotalMinutes;
    final remaining = cd.safeRemainingMinutes;
    final used = cd.safeUsedMinutes;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final color = _callColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 12, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  AppStrings.callMinutes.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.5,
                  ),
                ),
              ),
              Text(
                '${remaining.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} ${AppStrings.minutesLabel.tr(context)}',
                style: context.text.labelSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 1.0 - progress,
              minHeight: 3.5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.text.bodySmall?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateString(BuildContext context, String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final locale = Localizations.localeOf(context).languageCode;
      return DateFormat('dd MMMM yyyy, hh:mm a', locale).format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
