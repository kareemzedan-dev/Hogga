import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/user/my_orders/data/models/order_details.dart';
import 'package:hogga/features/user/my_orders/domin/repositories/my_orders_repository.dart';
import 'package:hogga/injection_container.dart' as di;

class OrderConfirmedScreen extends StatefulWidget {
  final String caseNumber;
  final int? caseId;
  final String? recordType;

  const OrderConfirmedScreen({
    super.key,
    required this.caseNumber,
    this.caseId,
    this.recordType,
  });

  @override
  State<OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<OrderConfirmedScreen> {
  OrderDetailsData? _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.caseId != null && widget.caseId! > 0) {
      _fetchOrderDetails();
    }
  }

  Future<void> _fetchOrderDetails({bool isRetry = false}) async {
    if (!isRetry) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final repo = di.sl<MyOrderRepository>();
      final result = await repo.getOrderDetails(
        orderId: widget.caseId!,
        recordType: widget.recordType,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
          });
        },
        (order) {
          setState(() {
            _order = order;
            _isLoading = false;
          });

          // If consultation without chat room provisioned yet, retry once after 2.5s
          if (!isRetry &&
              !order.hasChatRoom &&
              (order.isConsultation || widget.recordType == 'consultation')) {
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (mounted) {
                _fetchOrderDetails(isRetry: true);
              }
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool get _isConsultation {
    if (_order != null) return _order!.isConsultation;
    final rt = widget.recordType?.toLowerCase() ?? '';
    return rt.contains('consultation') || rt.contains('استشارة');
  }

  bool get _isCall {
    if (_order == null) return false;
    final key = _order!.serviceTypeKey.toLowerCase();
    final text = _order!.serviceTypeText.toLowerCase();
    final prod = _order!.title.toLowerCase();
    return _order!.isCallType ||
        key.contains('video') ||
        key.contains('audio') ||
        key.contains('voice') ||
        key.contains('call') ||
        text.contains('فيديو') ||
        text.contains('صوت') ||
        text.contains('مكالمة') ||
        prod.contains('فيديو') ||
        prod.contains('صوت') ||
        prod.contains('مكالمة');
  }

  void _openOrder(BuildContext context) {
    if (widget.caseId != null && widget.caseId! > 0) {
      Navigator.pushNamed(
        context,
        AppRoutes.myOrderDetails,
        arguments: {'orderId': widget.caseId, 'recordType': widget.recordType},
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.myOrders,
      (route) => false,
    );
  }

  void _openChat(BuildContext context) {
    final order = _order;
    if (order == null || order.chatRoomId == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'chatRoomId': order.chatRoomId,
        'lawyerName': order.lawyerName,
        'lawyerPhoto': null,
        'caseTitle': order.title,
        'serviceType': order.serviceTypeKey,
        'recordType': order.recordType,
        'isConsultation': order.isConsultation,
        'isCall': order.isCallType,
      },
    );
  }

  void _openCall(BuildContext context) {
    final order = _order;
    if (order == null || order.chatRoomId == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.call,
      arguments: {
        'chatRoomId': order.chatRoomId,
        'lawyerName': order.lawyerName,
        'lawyerPhoto': null,
        'serviceType': order.serviceTypeKey,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChat = _order != null && _order!.hasChatRoom;
    final hasCall = hasChat && _isCall;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // ── Success Icon ──
              Container(
                width: 92.w,
                height: 92.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 68.sp,
                    color: const Color(0xFF27AE60),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Success Title ──
              Text(
                _isConsultation
                    ? AppStrings.consultationConfirmedSuccessfully.tr(context)
                    : AppStrings.orderSentSuccessfully.tr(context),
                textAlign: TextAlign.center,
                style: context.text.titleLarge?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 10.h),

              // ── Description ──
              Text(
                hasChat
                    ? AppStrings.consultationReadyDesc.tr(context)
                    : AppStrings.orderProcessingDesc.tr(context),
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.textSecondary,
                  fontSize: 13.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),

              // ── Order Number Badge ──
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: context.divColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.caseNumber.isNotEmpty) ...[
                      Text(
                        widget.caseNumber,
                        style: TextStyle(
                          color: AppColors.golden,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Text(
                      AppStrings.orderNumber.tr(context),
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Loading Communication indicator ──
              if (_isLoading) ...[
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.golden,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      AppStrings.loadingCommunicationDetails.tr(context),
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ] else ...[
                SizedBox(height: 32.h),
              ],

              // ── Quick Actions Cards ──
              if (hasChat) ...[
                // Start Call Card (if audio/video consultation)
                if (hasCall) ...[
                  _buildActionCard(
                    context: context,
                    icon: Icons.phone_in_talk_rounded,
                    title: AppStrings.startCallNow.tr(context),
                    subtitle: AppStrings.startCallSubtitle.tr(context),
                    iconColor: const Color(0xFF27AE60),
                    cardBg: const Color(0xFF27AE60).withValues(alpha: 0.08),
                    borderColor: const Color(0xFF27AE60).withValues(alpha: 0.35),
                    isPrimaryHighlight: true,
                    onTap: () => _openCall(context),
                    isRtl: isRtl,
                  ),
                  SizedBox(height: 12.h),
                ],

                // Enter Chat Card
                _buildActionCard(
                  context: context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: AppStrings.enterChatRoom.tr(context),
                  subtitle: AppStrings.enterChatSubtitle.tr(context),
                  iconColor: const Color(0xFF2D9CDB),
                  cardBg: context.cardBg,
                  borderColor: context.divColor,
                  isPrimaryHighlight: !hasCall,
                  onTap: () => _openChat(context),
                  isRtl: isRtl,
                ),
                SizedBox(height: 12.h),

                // View Service Details Card
                _buildActionCard(
                  context: context,
                  icon: Icons.description_outlined,
                  title: AppStrings.viewServiceDetails.tr(context),
                  subtitle: AppStrings.viewServiceDetailsSubtitle.tr(context),
                  iconColor: AppColors.golden,
                  cardBg: context.cardBg,
                  borderColor: context.divColor,
                  onTap: () => _openOrder(context),
                  isRtl: isRtl,
                ),
                SizedBox(height: 20.h),
              ] else ...[
                // Default action when no chat room or for standard service orders
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _openOrder(context),
                    icon: Icon(
                      Icons.assignment_outlined,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      AppStrings.trackOrder.tr(context),
                      style: context.text.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cream,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // ── Back to Home Button ──
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                      (route) => false,
                    );
                  },
                  icon: Icon(
                    Icons.home_outlined,
                    size: 20.sp,
                    color: context.textPrimary,
                  ),
                  label: Text(
                    AppStrings.backToHome.tr(context),
                    style: context.text.bodyLarge?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.divColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color cardBg,
    required Color borderColor,
    required VoidCallback onTap,
    required bool isRtl,
    bool isPrimaryHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor, width: isPrimaryHighlight ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                      fontSize: 11.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: context.textSecondary.withValues(alpha: 0.6),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
