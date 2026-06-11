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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: HoggaCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        child: Column(
          children: [
            // ── Header: icon + title + case number ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _serviceColor().withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getServiceIcon(), size: 20, color: _serviceColor()),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName.isNotEmpty
                            ? order.productName
                            : AppStrings.legalConsultation.tr(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.categoryName.isNotEmpty
                                  ? order.categoryName
                                  : '${AppStrings.appName.tr(context)} - ${AppStrings.licensedLawyer.tr(context)}',
                              style: context.text.labelSmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.chipBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.divColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  order.caseNumber.isNotEmpty ? order.caseNumber : '#${order.id}',
                                  style: context.text.labelSmall?.copyWith(
                                    color: AppColors.golden,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  AppStrings.referenceNumber.tr(context),
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.textSecondary,
                                    fontSize: 9,
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, thickness: 0.8, color: context.divColor),
            ),

            // ── Badges row: service type + payment status + chat ──
            Row(
              children: [
                _buildBadge(
                  context: context,
                  icon: _getServiceIcon(),
                  label: order.serviceTypeText.isNotEmpty ? order.serviceTypeText : order.serviceTypeKey,
                  color: _serviceColor(),
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  context: context,
                  icon: order.isPaid ? Icons.check_circle_outline : Icons.schedule_outlined,
                  label: order.paymentStatusText.isNotEmpty
                      ? order.paymentStatusText
                      : (order.isPaid ? AppStrings.paidStatus.tr(context) : AppStrings.pendingStatus.tr(context)),
                  color: order.isPaid ? const Color(0xFF27AE60) : const Color(0xFFBF8C1E),
                ),
                if (order.hasChatRoom) ...[
                  const SizedBox(width: 8),
                  _buildBadge(
                    context: context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: AppStrings.chat.tr(context),
                    color: const Color(0xFF2D9CDB),
                  ),
                ],
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, thickness: 0.8, color: context.divColor),
            ),

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
                          const Icon(Icons.event_outlined, size: 13, color: AppColors.golden),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              order.formattedDate.isNotEmpty
                                  ? order.formattedDate
                                  : DateFormat('dd MMMM yyyy',
                                          Localizations.localeOf(context).languageCode)
                                      .format(order.createdAt),
                              style: context.text.bodySmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11,
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
                            Icon(Icons.people_outline, size: 13, color: context.textSecondary),
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
                              fontSize: 17,
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
                AppStatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: 18),

            // ── Action buttons ──
            if (order.hasChatRoom)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (order.serviceTypeKey == 'video') {
                        Navigator.pushNamed(context, AppRoutes.videoCall, arguments: {'chatRoomId': order.chatRoomId, 'lawyerName': '', 'lawyerPhoto': null, 'serviceType': order.serviceTypeKey});
                      } else if (order.serviceTypeKey == 'audio' || order.serviceTypeKey == 'phone') {
                        Navigator.pushNamed(context, AppRoutes.voiceCall, arguments: {'chatRoomId': order.chatRoomId, 'lawyerName': '', 'lawyerPhoto': null, 'serviceType': order.serviceTypeKey});
                      } else {
                        Navigator.pushNamed(context, AppRoutes.chat, arguments: {'chatRoomId': order.chatRoomId, 'lawyerName': '', 'caseTitle': order.productName, 'serviceType': order.serviceTypeKey});
                      }
                    },
                    icon: Icon(
                      order.serviceTypeKey == 'video'
                          ? Icons.videocam_rounded
                          : (order.serviceTypeKey == 'audio' || order.serviceTypeKey == 'phone'
                              ? Icons.phone_in_talk_rounded
                              : Icons.chat_bubble_outline_rounded),
                      size: 18,
                      color: _serviceColor(),
                    ),
                    label: Text(
                      order.serviceTypeKey == 'video'
                          ? AppStrings.makeVideoCall.tr(context)
                          : (order.serviceTypeKey == 'audio' || order.serviceTypeKey == 'phone'
                              ? AppStrings.makeVoiceCall.tr(context)
                              : AppStrings.enterChat.tr(context)),
                      style: context.text.labelLarge?.copyWith(
                        color: _serviceColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _serviceColor()),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),

            if (order.paymentStatus == 'pending' && order.status != 'canceled')
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<MyOrdersCubit>().payLegalCase(
                            orderId: order.id,
                            caseNumber: order.caseNumber,
                          );
                    },
                    icon: const Icon(Icons.payment_rounded, size: 20, color: Colors.white),
                    label: Text(
                      AppStrings.completePaymentNow.tr(context),
                      style: context.text.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      elevation: 2,
                      shadowColor: const Color(0xFF27AE60).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: (order.paymentStatus == 'pending' && order.status != 'canceled')
                  ? OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        AppStrings.consultationDetails.tr(context),
                        style: context.text.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.cream,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        AppStrings.consultationDetails.tr(context),
                        style: context.text.labelLarge?.copyWith(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
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
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon() {
    switch (order.serviceTypeKey) {
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
    switch (order.serviceTypeKey) {
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
