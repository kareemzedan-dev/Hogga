import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/features/user/my_orders/data/models/order_model.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hogga/core/utils/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import '../../../../../core/widgets/app_status_badge.dart';
import 'package:hogga/core/widgets/hogga_card.dart';

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
              // Header
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.golden.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getServiceIcon(), size: 20, color: AppColors.golden),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.productName.isNotEmpty ? order.productName.tr(context) : AppStrings.legalConsultation.tr(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleMedium?.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    order.categoryName.isNotEmpty
                                        ? order.categoryName
                                        : '${AppStrings.appName.tr(context)} - ${AppStrings.licensedLawyer.tr(context)}',
                                    style: context.text.labelSmall?.copyWith(
                                      color: context.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          AppStrings.referenceNumber.tr(context),
                                          style: context.text.labelSmall?.copyWith(
                                            color: context.textSecondary,
                                            fontSize: 9,
                                          ),
                                        ),
                                        const SizedBox(height: 3),

                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1, thickness: 0.8, color: context.divColor),
              ),

              // Middle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 14, color: AppColors.golden),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                order.formattedDate.isNotEmpty
                                    ? order.formattedDate
                                    : DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(order.createdAt),
                                style: context.text.bodySmall?.copyWith(
                                  color: context.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (order.lawyersCount > 0) ...[
                              Icon(Icons.people_outline, size: 14, color: context.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${order.lawyersCount}',
                                style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                order.total.toStringAsFixed(2),
                                style: context.text.titleLarge?.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
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

              const SizedBox(height: 22),

              // Action Button — always uses primary bg (by design)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.cream,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.consultationDetails.tr(context),
                        style: context.text.labelLarge?.copyWith(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  IconData _getServiceIcon() {
    return Icons.gavel_rounded;
  }
}
