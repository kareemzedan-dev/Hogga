import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_empty_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/features/lawyer/referral/domain/entities/referral_history_item.dart';
import '../cubit/referral_cubit.dart';
import '../cubit/referral_state.dart';
import '../cubit/referral_history_cubit.dart';

class LawyerReferralScreen extends StatefulWidget {
  final ReferralCampaign? campaign;
  const LawyerReferralScreen({super.key, this.campaign});

  @override
  State<LawyerReferralScreen> createState() => _LawyerReferralScreenState();
}

class _LawyerReferralScreenState extends State<LawyerReferralScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  void _loadData() {
    context.read<ReferralCubit>().getReferralCode(campaign: widget.campaign);
    context.read<ReferralHistoryCubit>().loadHistory(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ReferralHistoryCubit>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.referralProgram.tr(context),
      ),
      body: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          if (state is ReferralLoading) {
            return const LawyerShimmerLoading();
          } else if (state is ReferralError) {
            return Center(
              child: Text(
                state.message.tr(context),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            );
          } else if (state is ReferralCodeLoaded) {
            final codeData = state.codeData;

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: context.accentGolden,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCodeCard(context, codeData.referralCode),
                    SizedBox(height: 24.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 0.5,
                          color: context.textSecondary
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: context.accentGolden,
                              size: 18.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              AppStrings.totalReferredUsers.tr(context),
                              style: context.text.titleSmall?.copyWith(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${codeData.totalReferredUsers}',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(width: 12.w),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      AppStrings.referralHistory.tr(context),
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildHistoryList(),
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

  bool _isCopied = false;

  Widget _buildCodeCard(BuildContext context, String code) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
                Icons.card_giftcard_rounded,
                color: context.accentGolden,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.referralCode.tr(context),
                style: context.text.labelLarge?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: context.pageBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: context.divColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: SelectableText(
                      code,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (code.isNotEmpty) {
                      await Clipboard.setData(ClipboardData(text: code));
                      setState(() => _isCopied = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _isCopied = false);
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _isCopied ? context.success : context.accentGolden,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 14.sp,
                          color: _isCopied ? context.colors.onError : context.textPrimary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _isCopied ? AppStrings.codeCopiedSuccess.tr(context) : AppStrings.copyCode.tr(context),
                          style: context.text.labelSmall?.copyWith(
                            color: _isCopied ? context.colors.onError : context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return BlocBuilder<ReferralHistoryCubit, ReferralHistoryState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const LawyerShimmerLoading();
        }

        if (state.errorMessage != null && state.items.isEmpty) {
          return Center(
            child: Text(
              state.errorMessage!.tr(context),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          );
        }

        if (state.items.isEmpty) {
          return LawyerEmptyState(
            icon: Icons.history_rounded,
            title: AppStrings.noReferralsYet.tr(context),
            subtitle: AppStrings.shareCodePrompt.tr(context),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.items.length + (state.isLoading ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Center(child: CircularProgressIndicator(color: context.accentGolden)),
              );
            }
            return _buildHistoryItem(context, state.items[index]);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, ReferralHistoryItem item) {
    final user = item.referredUser;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.divColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: context.accentGolden.withValues(alpha: 0.1),
            child: Icon(
              Icons.person_rounded,
              color: context.accentGolden,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : AppStrings.referredUser.tr(context),
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  user.phone.isNotEmpty ? user.phone : user.email,
                  style: context.text.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontSize: 11.sp,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          Text(
            item.referredAt.length >= 10 ? item.referredAt.substring(0, 10) : item.referredAt,
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
