import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_stat_box.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/lawyer_service_details_cubit.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/update_service_cubit.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/delete_service_cubit.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/change_service_status_cubit.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';
import 'package:hogga/core/utils/app_assets.dart';

class LawyerServiceDetailsScreen extends StatelessWidget {
  final int serviceId;
  final String title;

  const LawyerServiceDetailsScreen({
    super.key,
    required this.serviceId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<LawyerServiceDetailsCubit>()..fetchServiceDetails(serviceId)),
        BlocProvider(create: (context) => sl<DeleteServiceCubit>()),
        BlocProvider(create: (context) => sl<ChangeServiceStatusCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DeleteServiceCubit, DeleteServiceState>(
            listener: (context, state) {
              if (state is DeleteServiceSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
                Navigator.pop(context); // Reactive refresh handled by stream
              } else if (state is DeleteServiceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<ChangeServiceStatusCubit, ChangeServiceStatusState>(
            listener: (context, state) {
              if (state is ChangeServiceStatusSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
                // Reactive refresh handled by stream
              } else if (state is ChangeServiceStatusError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: context.pageBg,
          appBar: AppBar(
            backgroundColor: context.pageBg,
            elevation: 0,
            shape: Border(bottom: BorderSide(color: context.divColor.withValues(alpha: 0.5), width: 1)),
            title: Text(title, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              BlocBuilder<LawyerServiceDetailsCubit, LawyerServiceDetailsState>(
                builder: (context, state) {
                  if (state is LawyerServiceDetailsLoaded) {
                    return IconButton(
                      icon: Icon(Icons.edit_note_rounded, color: context.colors.primary, size: 28.sp),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.lawyerUpdateService,
                          arguments: state.details.service,
                        );
                        // Reactive refresh handled by stream
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<LawyerServiceDetailsCubit, LawyerServiceDetailsState>(
                builder: (context, state) {
                  if (state is LawyerServiceDetailsLoaded) {
                    return IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: context.colors.error, size: 28.sp),
                      onPressed: () => _showDeleteConfirmation(context, state.details.service.id),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: BlocBuilder<LawyerServiceDetailsCubit, LawyerServiceDetailsState>(
            builder: (context, state) {
              if (state is LawyerServiceDetailsLoading) {
                return const LawyerShimmerLoading();
              } else if (state is LawyerServiceDetailsError) {
                return Center(child: Text(state.message, style: TextStyle(color: context.colors.error)));
              } else if (state is LawyerServiceDetailsLoaded) {
                final details = state.details;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceInfo(context, details.service),
                      SizedBox(height: 24.h),
                      Text(
                        AppStrings.performanceOverview.tr(context),
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      _buildStatsGrid(context, details.statistics),
                      SizedBox(height: 24.h),
                      Text(
                        AppStrings.lastTransactions.tr(context),
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      _buildPurchasesList(context, details.purchases),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context, dynamic service) {
    return LawyerCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.design_services_rounded, color: context.accentGolden, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        service.name,
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    Text(
                      service.categoriesItemName,
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              BlocBuilder<ChangeServiceStatusCubit, ChangeServiceStatusState>(
                builder: (context, state) {
                  bool isActive = service.status == 'approved' || service.status == 'active';
                  bool isLoading = false;

                  if (state is ChangeServiceStatusLoading) {
                    isActive = state.optimisticStatus;
                    isLoading = true;
                  } else if (state is ChangeServiceStatusSuccess) {
                    isActive = state.newStatus;
                  } else if (state is ChangeServiceStatusError) {
                    isActive = state.rollbackStatus;
                  }
                  
                  return Column(
                    children: [
                      Switch.adaptive(
                        value: isActive,
                        activeColor: Colors.green,
                        onChanged: isLoading ? null : (_) => context.read<ChangeServiceStatusCubit>().changeStatus(service.id, isActive),
                      ),
                      Text(
                        isActive ? AppStrings.activeLabel.tr(context) : AppStrings.inactiveLabel.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: isActive ? Colors.green : context.colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            AppStrings.serviceDescription.tr(context),
            style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            service.description,
            style: context.text.bodySmall?.copyWith(color: context.textSecondary),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.price.tr(context),
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${service.price} ${AppStrings.currency.tr(context)}',
                style: context.text.titleMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LawyerStatBox(
                label: AppStrings.totalPurchases.tr(context),
                value: stats.totalPurchases.toString(),
                icon: Icons.shopping_bag_outlined,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: LawyerStatBox(
                label: AppStrings.totalIncome.tr(context),
                value: '${stats.totalIncome}',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: LawyerStatBox(
                label: AppStrings.pendingPurchases.tr(context),
                value: stats.pendingPurchases.toString(),
                icon: Icons.timer_outlined,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: LawyerStatBox(
                label: AppStrings.completedPurchases.tr(context),
                value: stats.completedPurchases.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchasesList(BuildContext context, List<dynamic> purchases) {
    if (purchases.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 48.sp, color: context.textSecondary.withValues(alpha: 0.3)),
              SizedBox(height: 12.h),
              Text(
                AppStrings.noTransactions.tr(context),
                style: context.text.labelSmall?.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        // Implement purchase item UI if data becomes available
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => CustomConfirmationSheet(
        iconPath: AppAssets.trashLogo,
        title: AppStrings.delete.tr(context),
        subtitle: AppStrings.confirmDelete.tr(context),
        actionText: AppStrings.delete.tr(context),
        onAction: () {
          Navigator.pop(dialogContext);
          context.read<DeleteServiceCubit>().deleteService(id);
        },
      ),
    );
  }
}
