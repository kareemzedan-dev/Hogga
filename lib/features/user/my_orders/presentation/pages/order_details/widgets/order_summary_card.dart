import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_status_badge.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import '../../../../data/models/order_details.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderDetailsData order;
  final VoidCallback onViewDetails;
  final VoidCallback onCancelOrder;

  const OrderSummaryCard({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.onCancelOrder,
  });

  bool get canCancel => order.status == 'pending';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
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
            style: context.text.bodySmall?.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            AppStrings.consultationHistory.tr(context),
            order.createdAt,
          ),
          // _buildInfoRow(
          //   context,
          //   AppStrings.selectionType.tr(context),
          //   order.selectionType,
          // ),
          _buildInfoRow(
            context,
            AppStrings.paymentMethod.tr(context),
            order.financials.paymentMethod,
          ),
          _buildInfoRow(
            context,
            AppStrings.paymentStatus.tr(context),
            order.financials.paymentStatus,
          ),
          const SizedBox(height: 18),
          Text(
            AppStrings.consultationSubject.tr(context),
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomButton(
                  onPressed: onViewDetails,
                  text: AppStrings.attachedDocuments.tr(context),
                  icon: Icons.attach_file,
                  isSmall: true,
                ),
              ),
              if (canCancel) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    onPressed: onCancelOrder,
                    text: AppStrings.cancelOrder.tr(context),
                    textColor: Colors.white,
                    backgroundColor: AppColors.error,
                    isSmall: true,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
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
              style: context.text.bodySmall?.copyWith(color: context.textSecondary),
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
}
