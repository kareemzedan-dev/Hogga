import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/hogga_card.dart';

class UserWalletScreen extends StatelessWidget {
  const UserWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.wallet.tr(context),
        backBtn: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context),
            SizedBox(height: 32.h),
            Text(
              AppStrings.lastTransactions.tr(context),
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTransactionsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.totalPayments.tr(context),
            style: context.text.labelLarge?.copyWith(color: context.textSecondary),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "0.00",
                style: context.text.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.currencySymbol.tr(context),
                style: context.text.titleMedium?.copyWith(color: context.colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [];

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 64.sp, color: context.textSecondary.withValues(alpha: 0.5)),
              SizedBox(height: 16.h),
              Text(
                AppStrings.noDataFound.tr(context),
                style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = transactions[index];
        return HoggaCard(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: context.colors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['date'],
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "- ${item['amount']} ${AppStrings.currencySymbol.tr(context)}",
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppStrings.completed.tr(context),
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
