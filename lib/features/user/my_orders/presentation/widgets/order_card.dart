import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/features/user/my_orders/data/models/order_model.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import '../../../../../core/widgets/app_status_badge.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/my_orders_cubit.dart';

class OrderCard extends StatelessWidget {
  final MyOrderData order;
  final VoidCallback onTap;
  final bool isPrevious;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.isPrevious = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled =
        order.status == 'canceled' || order.status == 'cancelled';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: HoggaCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 16,
        child: Column(
          children: [
            // ── Header: icon + title + case number ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _serviceColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceIcon(),
                    size: 20,
                    color: _serviceColor(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName.isNotEmpty
                            ? order.productName
                            : (order.isConsultation
                                ? AppStrings.legalConsultation.tr(context)
                                : (Localizations.localeOf(context).languageCode == 'ar'
                                    ? 'خدمة / قضية'
                                    : AppStrings.services.tr(context))),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.categoryName.isNotEmpty
                            ? order.categoryName
                            : '${AppStrings.appName.tr(context)} - ${AppStrings.licensedLawyer.tr(context)}',
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.chipBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.divColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        order.caseNumber.isNotEmpty
                            ? order.caseNumber
                            : '#${order.id}',
                        style: context.text.labelSmall?.copyWith(
                          color: AppColors.golden,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        order.isConsultation
                            ? (Localizations.localeOf(context).languageCode == 'ar'
                                ? 'مرجع الاستشارة'
                                : AppStrings.referenceNumber.tr(context))
                            : (Localizations.localeOf(context).languageCode == 'ar'
                                ? 'رقم القضية'
                                : AppStrings.referenceNumber.tr(context)),
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Badges row: service type + payment status + chat ──
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBadge(
                  context: context,
                  icon: _getServiceIcon(),
                  label: _serviceLabel(context),
                  color: _serviceColor(),
                ),
                _buildBadge(
                  context: context,
                  icon: order.isPaid
                      ? Icons.check_circle_outline
                      : Icons.schedule_outlined,
                  label: _paymentStatusLabel(context),
                  color: order.isPaid
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFBF8C1E),
                ),
                if (_shouldShowChatBadge) ...[
                  _buildBadge(
                    context: context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: AppStrings.chat.tr(context),
                    color: const Color(0xFF2D9CDB),
                  ),
                ],
              ],
            ),

            // ── Call Duration Info (call only) ──
            if (order.isCallType && order.callDuration != null) ...[
              const SizedBox(height: 8),
              _buildCallDurationBanner(context),
            ],

            const SizedBox(height: 10),

            // ── Bottom: date + price + case status ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            size: 13,
                            color: AppColors.golden,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              order.formattedDate.isNotEmpty
                                  ? order.formattedDate
                                  : DateFormat(
                                      'dd MMMM yyyy',
                                      Localizations.localeOf(
                                        context,
                                      ).languageCode,
                                    ).format(order.createdAt),
                              style: context.text.bodySmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (order.lawyersCount > 0) ...[
                            Icon(
                              Icons.people_outline,
                              size: 13,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${order.lawyersCount}',
                              style: context.text.labelSmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            order.total.toStringAsFixed(2),
                            style: context.text.titleLarge?.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.currencySymbol.tr(context),
                            style: context.text.bodySmall?.copyWith(
                              color: AppColors.golden,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppStatusBadge(
                  status: order.status,
                  statusText: order.statusText.isNotEmpty
                      ? order.statusText
                      : null,
                ),
              ],
            ),

            if (order.hasChatRoom && !isCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (_shouldOpenChat) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chat,
                          arguments: {
                            'chatRoomId': order.chatRoomId,
                            'lawyerName': '',
                            'caseTitle': order.productName,
                            'serviceType': order.serviceTypeKey,
                            'recordType': order.recordType,
                            'isConsultation': order.isConsultation,
                          },
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.call,
                          arguments: {
                            'chatRoomId': order.chatRoomId,
                            'lawyerName': '',
                            'lawyerPhoto': null,
                            'serviceType': order.serviceTypeKey,
                          },
                        );
                      }
                    },
                    icon: Icon(
                      _shouldOpenChat
                          ? Icons.chat_bubble_outline_rounded
                          : Icons.phone_in_talk_rounded,
                      size: 18,
                      color: _serviceColor(),
                    ),
                    label: Text(
                      _shouldOpenChat
                          ? AppStrings.enterChat.tr(context)
                          : AppStrings.makeVoiceCall.tr(context),
                      style: context.text.labelLarge?.copyWith(
                        color: _serviceColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _serviceColor(), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            if (_canRetryPayment && !isCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (order.hasPaymentUrl) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.paymentWebView,
                          arguments: {
                            'paymentUrl': order.paymentUrl,
                            'caseNumber': order.caseNumber,
                            'caseId': order.id,
                            'recordType': order.recordType,
                          },
                        );
                        return;
                      }

                      context.read<MyOrdersCubit>().payLegalCase(
                        orderId: order.id,
                        caseNumber: order.caseNumber,
                        recordType: order.recordType,
                      );
                    },
                    icon: const Icon(
                      Icons.payment_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      AppStrings.completePaymentNow.tr(context),
                      style: context.text.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      elevation: 2,
                      shadowColor: const Color(
                        0xFF27AE60,
                      ).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  bool get _shouldOpenChat => !order.isCallType;

  bool get _shouldShowChatBadge => order.hasChatRoom && _shouldOpenChat;

  bool get _canRetryPayment =>
      order.paymentStatus.toLowerCase() == 'pending' &&
      (order.isConsultation || order.hasPaymentUrl);

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 145),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentStatusLabel(BuildContext context) {
    final key = order.paymentStatus.toLowerCase();
    if (key == 'paid') return AppStrings.paidStatus.tr(context);
    if (key == 'pending') return AppStrings.pendingStatus.tr(context);
    return order.paymentStatusText.isNotEmpty
        ? order.paymentStatusText
        : order.paymentStatus;
  }

  bool get _isCall {
    if (!order.isConsultation) return false;
    final key = order.serviceTypeKey.toLowerCase();
    final text = order.serviceTypeText.toLowerCase();
    final prod = order.productName.toLowerCase();
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
    final prod = order.productName.toLowerCase();
    return (key.isNotEmpty &&
            (key.contains('article') || key.contains('written'))) ||
        text.contains('مكتوب') ||
        prod.contains('مكتوب');
  }

  String _serviceLabel(BuildContext context) {
    if (!order.isConsultation) {
      if (order.recordTypeText.isNotEmpty &&
          !order.recordTypeText.contains('.')) {
        return order.recordTypeText;
      }
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'خدمة / قضية'
          : AppStrings.services.tr(context);
    }

    if (_isCall) {
      return order.serviceTypeText.isNotEmpty
          ? order.serviceTypeText
          : (Localizations.localeOf(context).languageCode == 'ar'
              ? 'مكالمة'
              : 'Call');
    }
    if (_isWritten) {
      return order.serviceTypeText.isNotEmpty
          ? order.serviceTypeText
          : (Localizations.localeOf(context).languageCode == 'ar'
              ? 'استشارة مكتوبة'
              : 'Written Consultation');
    }
    final key = order.serviceTypeKey.toLowerCase();
    if (key.contains('chat')) return AppStrings.chat.tr(context);
    if (order.serviceTypeText.isNotEmpty &&
        !order.serviceTypeText.contains('.')) {
      return order.serviceTypeText;
    }
    if (order.recordTypeText.isNotEmpty &&
        !order.recordTypeText.contains('.')) {
      return order.recordTypeText;
    }
    return AppStrings.consultation.tr(context);
  }

  IconData _getServiceIcon() {
    if (!order.isConsultation) {
      return Icons.balance_rounded;
    }
    if (_isCall) return Icons.phone_in_talk_rounded;
    if (_isWritten) return Icons.article_outlined;
    final key = order.serviceTypeKey.toLowerCase();
    if (key.contains('chat')) return Icons.chat_outlined;
    return Icons.assignment_outlined;
  }

  Color _serviceColor() {
    if (!order.isConsultation) {
      return AppColors.golden;
    }
    if (_isCall) {
      return const Color(0xFF27AE60);
    } else if (order.serviceTypeKey.toLowerCase().contains('chat')) {
      return const Color(0xFF2D9CDB);
    } else {
      return AppColors.golden;
    }
  }

  Widget _buildCallDurationBanner(BuildContext context) {
    final cd = order.callDuration!;
    final total = cd.safeTotalMinutes;
    final remaining = cd.safeRemainingMinutes;
    final used = cd.safeUsedMinutes;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final color = _serviceColor();

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
}
