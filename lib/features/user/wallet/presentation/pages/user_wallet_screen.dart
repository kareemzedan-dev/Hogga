import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/widgets/main_appbar.dart';
import '../../../../../core/widgets/hogga_card.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../injection_container.dart';
import '../cubits/wallet_cubit.dart';
import '../cubits/wallet_state.dart';

class UserWalletScreen extends StatelessWidget {
  const UserWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WalletCubit>()..fetchPayments(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(title: AppStrings.wallet.tr(context), backBtn: true),
        body: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return ListView.separated(
                padding: EdgeInsets.all(20.w),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (_, __) => CustomShimmer.rectangular(
                  height: 100.h,
                  width: double.infinity,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              );
            } else if (state is WalletError) {
              return Center(
                child: Text(
                  state.message,
                  style: context.text.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              );
            } else if (state is WalletLoaded) {
              final transactions = state.payments;
              if (transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64.sp,
                          color: context.textSecondary.withValues(alpha: 0.5),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppStrings.noDataFound.tr(context),
                          style: context.text.bodySmall?.copyWith(
                            color: context.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              double total = 0;
              for (var t in transactions) {
                if (t.statusKey == 'paid') {
                  total += double.tryParse(t.amount) ?? 0;
                }
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(context, total.toStringAsFixed(3)),
                    SizedBox(height: 32.h),
                    Text(
                      AppStrings.lastTransactions.tr(context),
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final item = transactions[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.paymentDetails,
                              arguments: item.id,
                            );
                          },
                          child: HoggaCard(
                            padding: EdgeInsets.all(14.w),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    color: context.colors.primary,
                                    size: 19.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.caseDetails?.title ??
                                            item.paymentNumber,
                                        style: context.text.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        item.date,
                                        style: context.text.labelSmall
                                            ?.copyWith(
                                              color: context.textSecondary,
                                              fontSize: 10.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${item.amount} ${AppStrings.currencySymbol.tr(context)}",
                                      style: context.text.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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

  Widget _buildSummaryCard(BuildContext context, String total) {
    final isDark = context.isDark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  context.colors.primary.withValues(alpha: 0.35),
                  context.cardBg,
                ]
              : [
                  context.accentGolden.withValues(alpha: 0.12),
                  context.colors.primary.withValues(alpha: 0.05),
                ],
        ),
        border: Border.all(
          color: context.accentGolden.withValues(alpha: isDark ? 0.3 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            left: -15.w,
            bottom: -20.h,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 110.sp,
              color: context.accentGolden.withValues(alpha: isDark ? 0.06 : 0.04),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16.sp,
                      color: context.accentGolden,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      AppStrings.totalPayments.tr(context),
                      style: context.text.labelMedium?.copyWith(
                        color: context.textSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      total,
                      style: context.text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        fontSize: 28.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppStrings.currencySymbol.tr(context),
                      style: context.text.titleMedium?.copyWith(
                        color: context.accentGolden,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
