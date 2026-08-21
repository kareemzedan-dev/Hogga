import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_empty_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_transaction_model.dart';
import 'package:hogga/features/lawyer/wallet/presentation/cubit/lawyer_wallet_cubit.dart';
import 'package:hogga/core/widgets/custom_button.dart';

class LawyerWalletScreen extends StatefulWidget {
  final bool isBottomNav;
  const LawyerWalletScreen({super.key, this.isBottomNav = false});

  @override
  State<LawyerWalletScreen> createState() => _LawyerWalletScreenState();
}

class _LawyerWalletScreenState extends State<LawyerWalletScreen> {
  String _selectedType = 'all';

  final List<Map<String, String>> _types = [
    {'label': AppStrings.all, 'value': 'all'},
    {'label': AppStrings.income, 'value': 'income'},
    {'label': AppStrings.expenses, 'value': 'expenses'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.isBottomNav
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
        backgroundColor: context.pageBg,
        elevation: 0,
        title: Text(
          AppStrings.lawyerWallet.tr(context),
          style: context.theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<LawyerWalletCubit, LawyerWalletState>(
        buildWhen: (previous, current) =>
            current is LawyerWalletLoading || current is LawyerWalletLoaded || current is LawyerWalletError,
        listener: (context, state) {
          if (state is LawyerWalletActionSuccess) {
            AppSnackbar.showSuccess(context, message: state.message);
          } else if (state is LawyerWalletActionError) {
            AppSnackbar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is LawyerWalletLoading) {
            return const LawyerShimmerLoading();
          } else if (state is LawyerWalletError) {
            return Center(
              child: Text(
                state.message.tr(context),
                style: context.text.bodyMedium?.copyWith(color: context.colors.error),
              ),
            );
          } else if (state is LawyerWalletLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<LawyerWalletCubit>().getWalletData(filter: _selectedType),
              color: context.accentGolden,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(context, state),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.lastTransactions.tr(context),
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => _showFilterSheet(context),
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: context.accentGolden.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: context.accentGolden.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tune_rounded, color: context.accentGolden, size: 16.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  AppStrings.filter.tr(context),
                                  style: context.text.labelMedium?.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildTransactionFilters(context),
                    SizedBox(height: 16.h),
                    _buildFilteredList(context, state),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, LawyerWalletLoaded state) {
    final double balance = state.wallet.balance;
    final bool canWithdraw = balance >= 10.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 16.sp,
                color: context.accentGolden,
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.availableBalance.tr(context),
                style: context.text.labelMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                balance.toStringAsFixed(3),
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                AppStrings.currencySymbol.tr(context),
                style: context.text.titleSmall?.copyWith(
                  color: context.accentGolden,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomButton(
            text: AppStrings.requestWithdrawal.tr(context),
            backgroundColor: canWithdraw ? context.accentGolden : context.divColor,
            textColor: canWithdraw ? context.textPrimary : context.textSecondary,
            fontWeight: FontWeight.bold,
            isSmall: false,
            onPressed: canWithdraw ? () => _showWithdrawDialog(context, balance) : null,
          ),
          if (!canWithdraw) ...[
            SizedBox(height: 8.h),
            Text(
              'الحد الأدنى للسحب 10 ${AppStrings.currencySymbol.tr(context)}',
              style: context.text.labelSmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.pageBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.divColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.viewOptions.tr(context),
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildFilterOption(context, AppStrings.byDateNewest.tr(context), Icons.calendar_today_rounded, true),
            _buildFilterOption(context, AppStrings.byAmountHighest.tr(context), Icons.sort_rounded, false),
            _buildFilterOption(context, AppStrings.onlyBankTransfers.tr(context), Icons.account_balance_rounded, false),
            SizedBox(height: 24.h),
            CustomButton(
              text: AppStrings.apply.tr(context),
              backgroundColor: context.accentGolden,
              textColor: context.textPrimary,
              fontWeight: FontWeight.bold,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, IconData icon, bool isSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? context.accentGolden : context.textSecondary, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: isSelected ? context.accentGolden : context.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          const Spacer(),
          if (isSelected) Icon(Icons.check_circle_rounded, color: context.accentGolden, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildTransactionFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _types.map((type) {
          final isSelected = _selectedType == type['value'];
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: ChoiceChip(
              label: Text(type['label']!.tr(context)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type['value']!);
                  context.read<LawyerWalletCubit>().getWalletData(filter: _selectedType);
                }
              },
              selectedColor: context.accentGolden,
              labelStyle: context.text.labelSmall?.copyWith(
                color: isSelected ? context.textPrimary : context.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: isSelected ? context.accentGolden : context.divColor),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilteredList(BuildContext context, LawyerWalletLoaded state) {
    final filtered = state.transactions.where((t) {
      if (_selectedType == 'all') return true;
      if (_selectedType == 'income') return t.isIncome;
      return !t.isIncome;
    }).toList();

    if (filtered.isEmpty) {
      return LawyerEmptyState(
        title: AppStrings.noTransactions.tr(context),
        subtitle: AppStrings.noTransactionsSubtitle.tr(context),
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final tx = filtered[index];
        final isIncome = tx.isIncome;
        final isReferral = tx.isReferralBonus;

        return HoggaCard(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isReferral
                      ? context.accentGolden.withValues(alpha: 0.1)
                      : (isIncome ? context.success : context.colors.error).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReferral ? Icons.card_giftcard_rounded : (isIncome ? Icons.arrow_downward : Icons.arrow_upward),
                  color: isReferral ? context.accentGolden : (isIncome ? context.success : context.colors.error),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tx.title,
                            style: context.text.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        if (isReferral) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: context.accentGolden.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              AppStrings.referralBonus.tr(context),
                              style: context.text.labelSmall?.copyWith(
                                color: context.accentGolden,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tx.date,
                      style: context.text.bodySmall?.copyWith(color: context.textSecondary, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? "+" : "-"}${(double.tryParse(tx.amount.toString()) ?? 0.0).toStringAsFixed(3)} ${AppStrings.currencySymbol.tr(context)}',
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? context.success : context.colors.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWithdrawDialog(BuildContext context, double availableBalance) {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    final bankController = TextEditingController();
    final ibanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<LawyerWalletCubit>(),
        child: BlocConsumer<LawyerWalletCubit, LawyerWalletState>(
          listenWhen: (previous, current) => current is LawyerWalletActionSuccess,
          listener: (context, state) {
            if (state is LawyerWalletActionSuccess) {
              Navigator.pop(dialogContext);
            }
          },
          builder: (context, state) {
            final isLoading = state is LawyerWalletActionLoading;
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                top: 20.h,
                left: 20.w,
                right: 20.w,
              ),
              decoration: BoxDecoration(
                color: context.pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: context.divColor,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppStrings.requestWithdrawal.tr(context),
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.h),
                    _buildInputField(context, amountController, AppStrings.amount.tr(context), TextInputType.number),
                    SizedBox(height: 16.h),
                    _buildInputField(context, nameController, AppStrings.accountName.tr(context), TextInputType.text),
                    SizedBox(height: 16.h),
                    _buildInputField(context, bankController, AppStrings.bankName.tr(context), TextInputType.text),
                    SizedBox(height: 16.h),
                    _buildInputField(context, ibanController, AppStrings.iban.tr(context), TextInputType.text),
                    SizedBox(height: 24.h),
                    CustomButton(
                      text: AppStrings.sendRequest.tr(context),
                      backgroundColor: context.accentGolden,
                      textColor: context.textPrimary,
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () {
                              final parsedAmount = double.tryParse(amountController.text.trim());
                              if (parsedAmount == null || parsedAmount <= 0) {
                                AppSnackbar.showError(context, messageKey: AppStrings.errorServer);
                                return;
                              }
                              if (parsedAmount > availableBalance) {
                                AppSnackbar.showError(context, messageKey: AppStrings.errorServer);
                                return;
                              }
                              if (nameController.text.trim().isEmpty ||
                                  bankController.text.trim().isEmpty ||
                                  ibanController.text.trim().isEmpty) {
                                AppSnackbar.showError(context, messageKey: AppStrings.requiredField);
                                return;
                              }
                              context.read<LawyerWalletCubit>().withdrawRequest(
                                    amount: parsedAmount,
                                    accountName: nameController.text.trim(),
                                    bankName: bankController.text.trim(),
                                    iban: ibanController.text.trim(),
                                  );
                            },
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, TextEditingController controller, String label, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 13.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.divColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.divColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.accentGolden),
        ),
        filled: true,
        fillColor: context.cardBg,
      ),
    );
  }
}
