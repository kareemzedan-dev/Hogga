import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/package_card.dart';
import '../../data/models/subscription_model.dart';
import '../../../../../../injection_container.dart';

class LawyerSubscriptionScreen extends StatefulWidget {
  const LawyerSubscriptionScreen({super.key});

  @override
  State<LawyerSubscriptionScreen> createState() => _LawyerSubscriptionScreenState();
}

class _LawyerSubscriptionScreenState extends State<LawyerSubscriptionScreen> {
  int? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubscriptionCubit>()..loadSubscriptionData(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.subscriptionPackages.tr(context),
        ),
        body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionActionSuccess) {
              AppSnackbar.showSuccess(context, message: AppStrings.subscriptionSuccess.tr(context));
            } else if (state is SubscriptionError) {
              AppSnackbar.showError(context, message: state.message);
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const LawyerShimmerLoading();
            }

            if (state is SubscriptionLoaded || state is SubscriptionActionLoading) {
              final isActionLoading = state is SubscriptionActionLoading;
              final SubscriptionLoaded loadedState;
              if (state is SubscriptionLoaded) {
                loadedState = state;
              } else {
                loadedState = context.read<SubscriptionCubit>().state as SubscriptionLoaded;
              }

              final packages = loadedState.packages;
              final currentSub = loadedState.currentSubscription;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20.w),
                      children: [
                        if (currentSub != null) ...[
                          _buildCurrentSubscriptionSummary(context, currentSub),
                          SizedBox(height: 24.h),
                        ],
                        Text(
                          AppStrings.choosePackage.tr(context),
                          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        ...packages.map((package) {
                          final isCurrent = currentSub?.packageSnapshot.id == package.id;
                          return PackageCard(
                            package: package,
                            isCurrent: isCurrent,
                            isSelected: _selectedPackageId == package.id,
                            onTap: () {
                              setState(() {
                                _selectedPackageId = package.id;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  _buildBottomBar(context, isActionLoading, currentSub?.packageSnapshot.id),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionSummary(BuildContext context, SubscriptionModel currentSub) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.mc.chipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: context.accentGolden, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                AppStrings.currentSubscription.tr(context),
                style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            currentSub.packageSnapshot.name,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.accentGolden,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${currentSub.progress.remaining} ${AppStrings.consultationLeft.tr(context)}',
            style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isLoading, int? currentPackageId) {
    final hasSelection = _selectedPackageId != null;
    final isCurrent = _selectedPackageId == currentPackageId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.pageBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: isCurrent 
              ? AppStrings.currentSubscription.tr(context) 
              : AppStrings.activateNow.tr(context),
          onPressed: (hasSelection && !isCurrent)
              ? () => context.read<SubscriptionCubit>().subscribeToPackage(_selectedPackageId!)
              : null,
          isLoading: isLoading,
          isSmall: true,
          backgroundColor: context.accentGolden,
        ),
      ),
    );
  }
}
