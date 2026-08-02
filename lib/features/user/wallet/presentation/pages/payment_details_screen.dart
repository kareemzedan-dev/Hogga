import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/widgets/main_appbar.dart';
import '../../../../../core/widgets/hogga_card.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../core/widgets/app_status_badge.dart';
import '../../../../../injection_container.dart';
import '../cubits/payment_details_cubit.dart';
import '../cubits/payment_details_state.dart';
import '../../../../../core/utils/app_strings.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final int paymentId;

  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PaymentDetailsCubit>()..fetchPaymentDetails(paymentId),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.paymentDetails.tr(context),
          backBtn: true,
        ),
        body: BlocBuilder<PaymentDetailsCubit, PaymentDetailsState>(
          builder: (context, state) {
            if (state is PaymentDetailsLoading) {
              return ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  CustomShimmer.rectangular(
                    height: 150.h,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomShimmer.rectangular(
                    height: 250.h,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ],
              );
            } else if (state is PaymentDetailsError) {
              return Center(
                child: Text(
                  state.message,
                  style: context.text.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              );
            } else if (state is PaymentDetailsLoaded) {
              final item = state.paymentDetails;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.paidAmount.tr(context),
                            style: context.text.labelSmall?.copyWith(
                              color: context.textSecondary,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            item.amount,
                            style: context.text.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          AppStatusBadge(
                            status: item.statusKey.isNotEmpty
                                ? item.statusKey
                                : item.status,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Info Card
                    HoggaCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            AppStrings.transactionNumber.tr(context),
                            item.paymentNumber,
                          ),
                          if (item.invoiceNumber != null) ...[
                            Divider(color: context.divColor, height: 24.h),
                            _buildInfoRow(
                              context,
                              AppStrings.invoiceNumber.tr(context),
                              item.invoiceNumber!,
                            ),
                          ],
                          if (item.clientReferenceId != null) ...[
                            Divider(color: context.divColor, height: 24.h),
                            _buildInfoRow(
                              context,
                              AppStrings.referenceNumber.tr(context),
                              item.clientReferenceId!,
                            ),
                          ],
                          Divider(color: context.divColor, height: 24.h),
                          _buildInfoRow(
                            context,
                            AppStrings.date.tr(context),
                            item.date,
                          ),
                          Divider(color: context.divColor, height: 24.h),
                          _buildInfoRow(
                            context,
                            AppStrings.paymentMethod.tr(context),
                            item.paymentMethod,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    if (item.caseDetails != null) ...[
                      Text(
                        AppStrings.caseDetails.tr(context),
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      HoggaCard(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.caseDetails!.title,
                              style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "${AppStrings.caseNumberLabel.tr(context)}: ${item.caseDetails!.caseNumber}",
                              style: context.text.labelSmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    if (item.products.isNotEmpty) ...[
                      Text(
                        AppStrings.servicesAndProducts.tr(context),
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...item.products.map(
                        (product) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: HoggaCard(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: context.text.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "${AppStrings.quantity.tr(context)}: ${product.quantity}",
                                        style: context.text.labelSmall
                                            ?.copyWith(
                                              color: context.textSecondary,
                                              fontSize: 10.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${product.amount} ${item.currency}",
                                  style: context.text.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.labelSmall?.copyWith(
            color: context.textSecondary,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }
}
