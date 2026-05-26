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
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_stat_box.dart';
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
          shape: Border(
            bottom: BorderSide(
              color: context.divColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          title: Text(
            AppStrings.lawyerWallet.tr(context),
            style: context.theme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<LawyerWalletCubit, LawyerWalletState>(
          buildWhen: (previous, current) {
            return current is LawyerWalletLoading || 
                   current is LawyerWalletLoaded || 
                   current is LawyerWalletError;
          },
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildBalanceCard(context, state),
                      SizedBox(height: 24.h),
                      _buildStatsRow(context, state),
                      SizedBox(height: 24.h),
                      LawyerSectionHeader(
                        title: AppStrings.lastTransactions.tr(context),
                        actionLabel: AppStrings.filter.tr(context),
                        onActionPressed: () => _showFilterSheet(context),
                      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cream, width: 1),
      ),
      child: Column(
        children: [
          Text(AppStrings.availableBalance.tr(context), style: context.text.labelLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${state.wallet.balance}',
                style: context.text.headlineSmall,
              ),
              const SizedBox(width: 8),
              Text(
                state.wallet.currency,
                style: context.text.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showWithdrawDialog(context, state.wallet.balance),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accentGolden,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              elevation: 0,
            ),
            child: Text(
              AppStrings.requestWithdrawal.tr(context),
              style: context.text.labelLarge!.copyWith(color: context.colors.onSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, LawyerWalletLoaded state) {
    return Row(
      children: [
        Expanded(
          child: LawyerStatBox(
            label: AppStrings.pendingBalance.tr(context),
            value: '${state.wallet.pendingBalance}',
            icon: Icons.timer_outlined,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: LawyerStatBox(
            label: AppStrings.totalSent.tr(context),
            value: '${state.wallet.totalSent}',
            icon: Icons.payments_outlined,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.pageBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.viewOptions.tr(context),
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),
              _buildFilterOption(context, AppStrings.byDateNewest.tr(context), Icons.calendar_today_rounded, true),
              _buildFilterOption(context, AppStrings.byAmountHighest.tr(context), Icons.sort_rounded, false),
              _buildFilterOption(context, AppStrings.onlyBankTransfers.tr(context), Icons.account_balance_rounded, false),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    AppStrings.apply.tr(context),
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, IconData icon, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? context.accentGolden : context.textSecondary, size: 20),
          SizedBox(width: 12.w),
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: isSelected ? context.accentGolden : context.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          const Spacer(),
          if (isSelected) Icon(Icons.check_circle_rounded, color: context.accentGolden, size: 20),
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
                color: isSelected ? context.colors.onPrimary : context.textPrimary,
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

    return _buildTransactionList(context, filtered);
  }

  Widget _buildTransactionList(BuildContext context, List<LawyerWalletTransactionModel> transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction.isIncome;
        return HoggaCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIncome ? Colors.green : context.colors.error).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : context.colors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      transaction.date,
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? "+" : "-"}${transaction.amount} ${AppStrings.currencySymbol.tr(context)}',
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : context.colors.error,
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
              SizedBox(height: 20.h),
              Text(
                AppStrings.requestWithdrawal.tr(context),
                style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: AppStrings.amount.tr(context),
                  labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 14.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: context.cardBg,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: AppStrings.accountName.tr(context),
                  labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 14.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: context.cardBg,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: bankController,
                style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: AppStrings.bankName.tr(context),
                  labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 14.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: context.cardBg,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: ibanController,
                style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: AppStrings.iban.tr(context),
                  labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 14.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: context.cardBg,
                ),
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: AppStrings.sendRequest.tr(context),
                backgroundColor: context.accentGolden,
                isLoading: isLoading,
                onPressed: isLoading ? null : () {
                  final parsedAmount = double.tryParse(amountController.text.trim());
                  if (parsedAmount == null || parsedAmount <= 0) {
                    AppSnackbar.showError(context, messageKey: AppStrings.errorServer);
                    return;
                  }
                  if (parsedAmount > availableBalance) {
                    AppSnackbar.showError(context, message: 'الرصيد المتاح غير كافٍ لإتمام عملية السحب.');
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
      },
    )
      )
    );
  }
}
