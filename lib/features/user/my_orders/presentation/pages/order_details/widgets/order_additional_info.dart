import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import '../../../../data/models/order_details.dart';

class OrderRatingSection extends StatelessWidget {
  const OrderRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class OrderReceiptSection extends StatelessWidget {
  final OrderDetailsData order;

  const OrderReceiptSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.golden, size: 20),
              const SizedBox(width: 10),
              Text(
                AppStrings.financialStatement.tr(context),
                style: context.text.titleMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReceiptRow(
            context,
            AppStrings.serviceFee.tr(context),
            order.financials.subtotal,
          ),
          _buildReceiptRow(
            context,
            AppStrings.discount.tr(context),
            order.financials.discount,
            isDiscount: true,
          ),
          _buildReceiptRow(
            context,
            AppStrings.tax.tr(context),
            order.financials.taxAmount,
          ),
          const Divider(height: 28),
          _buildReceiptRow(
            context,
            AppStrings.total.tr(context),
            order.financials.totalPrice,
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(BuildContext context, String label, double value, {bool isDiscount = false, bool highlight = false}) {
    final display = isDiscount ? '- ${value.toStringAsFixed(2)}' : value.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: highlight
                  ? context.text.titleSmall?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    )
                  : context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
            ),
          ),
          Text(
            '$display ${AppStrings.currencySymbol.tr(context)}',
            style: highlight
                ? context.text.titleSmall?.copyWith(
                    color: AppColors.golden,
                    fontWeight: FontWeight.bold,
                  )
                : context.text.bodySmall?.copyWith(
                    color: isDiscount ? AppColors.danger : context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}
