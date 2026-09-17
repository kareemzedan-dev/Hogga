import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_empty_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import '../../domain/entities/referral_history_item.dart';
import '../cubit/referral_history_cubit.dart';
import '../cubit/referral_state.dart';

class LawyerReferralHistoryScreen extends StatefulWidget {
  const LawyerReferralHistoryScreen({super.key});

  @override
  State<LawyerReferralHistoryScreen> createState() => _LawyerReferralHistoryScreenState();
}

class _LawyerReferralHistoryScreenState extends State<LawyerReferralHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ReferralHistoryCubit>().loadHistory(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ReferralHistoryCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.referralHistory.tr(context),
      ),
      body: BlocBuilder<ReferralHistoryCubit, ReferralHistoryState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const LawyerShimmerLoading();
          }

          if (state.errorMessage != null && state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!.tr(context),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ReferralHistoryCubit>().loadHistory(refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accentGolden,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(AppStrings.refresh.tr(context)),
                  ),
                ],
              ),
            );
          }

          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<ReferralHistoryCubit>().loadHistory(refresh: true),
              color: context.accentGolden,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100.h),
                  LawyerEmptyState(
                    title: AppStrings.noReferralsYet.tr(context),
                    subtitle: AppStrings.noReferralsYetSubtitle.tr(context),
                    icon: Icons.people_outline_rounded,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ReferralHistoryCubit>().loadHistory(refresh: true),
            color: context.accentGolden,
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.accentGolden,
                      ),
                    ),
                  );
                }

                final item = state.items[index];
                return _buildHistoryCard(context, item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ReferralHistoryItem item) {
    final user = item.referredUser;
    final isRewarded = item.isRewarded;

    return HoggaCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: (isRewarded ? Colors.green : context.textSecondary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRewarded ? Icons.check_circle_rounded : Icons.pending_outlined,
                  color: isRewarded ? Colors.green : context.textSecondary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : AppStrings.referredUser.tr(context),
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.phone.isNotEmpty ? user.phone : user.email,
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isRewarded ? Colors.green : Colors.grey).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: (isRewarded ? Colors.green : Colors.grey).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isRewarded
                      ? '+${item.rewardAmount} ${AppStrings.currencySymbol.tr(context)}'
                      : AppStrings.notRewarded.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: isRewarded ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: context.divColor),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.sp,
                    color: context.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    item.referredAt.length >= 10 ? item.referredAt.substring(0, 10) : item.referredAt,
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    size: 13.sp,
                    color: context.accentGolden,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    item.codeUsed,
                    style: context.text.labelSmall?.copyWith(
                      color: context.accentGolden,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
