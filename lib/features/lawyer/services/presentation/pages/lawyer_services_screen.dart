import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/lawyer_services_cubit.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/delete_service_cubit.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/change_service_status_cubit.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';

import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';
import 'package:hogga/core/widgets/main_appbar.dart';

class LawyerServicesScreen extends StatefulWidget {
  const LawyerServicesScreen({super.key});

  @override
  State<LawyerServicesScreen> createState() => _LawyerServicesScreenState();
}

class _LawyerServicesScreenState extends State<LawyerServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<LawyerServicesCubit>()..fetchServices(),
        ),
        BlocProvider(create: (context) => sl<DeleteServiceCubit>()),
        BlocProvider(create: (context) => sl<ChangeServiceStatusCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DeleteServiceCubit, DeleteServiceState>(
            listener: (context, state) {
              if (state is DeleteServiceSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is DeleteServiceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<ChangeServiceStatusCubit, ChangeServiceStatusState>(
            listener: (context, state) {
              if (state is ChangeServiceStatusSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ChangeServiceStatusError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: context.pageBg,
          appBar: MainAppbar(title: AppStrings.myServices.tr(context)),
          body: BlocBuilder<LawyerServicesCubit, LawyerServicesState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<LawyerServicesCubit>().fetchServices(),
                color: context.accentGolden,
                child: Builder(
                  builder: (context) {
                    if (state is LawyerServicesLoading) {
                      return const LawyerShimmerLoading();
                    } else if (state is LawyerServicesError) {
                      return CustomErrorState(
                        message: state.message,
                        onRetry: () =>
                            context.read<LawyerServicesCubit>().fetchServices(),
                      );
                    } else if (state is LawyerServicesLoaded) {
                      final services = state.services;
                      return services.isEmpty
                          ? CustomEmptyState(
                              title: AppStrings.noServices.tr(context),
                              subtitle: AppStrings.noServicesSubtitle.tr(
                                context,
                              ),
                              icon: Icons.design_services_outlined,
                              buttonLabel: AppStrings.addNewService.tr(context),
                              onAction: () => Navigator.pushNamed(
                                context,
                                AppRoutes.lawyerAddService,
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(
                                20.w,
                              ).copyWith(bottom: 100.h),
                              itemCount: services.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                return _buildServiceCard(
                                  context,
                                  services[index],
                                );
                              },
                            );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.lawyerAddService),
            backgroundColor: context.colors.primary,
            child: Icon(
              Icons.add,
              color: context.colors.secondary,
              size: 28.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, LawyerService service) {
    return LawyerCard(
      padding: EdgeInsets.all(16.w),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.lawyerServiceDetails,
          arguments: {'id': service.id, 'title': service.name},
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.design_services_rounded,
                  color: context.accentGolden,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: context.text.titleMedium!.copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                    if (service.categoriesItemName.isNotEmpty)
                      Text(
                        service.categoriesItemName,
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      '${AppStrings.price.tr(context)}: ${service.price} ${AppStrings.currency.tr(context)}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: context.divColor, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToggleAction(context, service),
              Row(
                children: [
                  _buildActionBtn(
                    context,
                    icon: Icons.edit_note_rounded,
                    label: AppStrings.edit.tr(context),
                    color: context.colors.primary,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.lawyerUpdateService,
                      arguments: service,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  _buildActionBtn(
                    context,
                    icon: Icons.delete_outline_rounded,
                    label: AppStrings.delete.tr(context),
                    color: context.colors.error,
                    onTap: () => _showDeleteConfirmation(context, service.id),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleAction(BuildContext context, LawyerService service) {
    return BlocBuilder<ChangeServiceStatusCubit, ChangeServiceStatusState>(
      builder: (context, state) {
        bool isActive =
            service.status == 'approved' || service.status == 'active';
        bool isLoading = false;

        if (state is ChangeServiceStatusLoading && state.id == service.id) {
          isActive = state.optimisticStatus;
          isLoading = true;
        } else if (state is ChangeServiceStatusSuccess &&
            state.id == service.id) {
          isActive = state.newStatus;
        } else if (state is ChangeServiceStatusError &&
            state.id == service.id) {
          isActive = state.rollbackStatus;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: isActive,
              activeThumbColor: Colors.green,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: isLoading
                  ? null
                  : (_) => context
                        .read<ChangeServiceStatusCubit>()
                        .changeStatus(service.id, isActive),
            ),
            SizedBox(width: 8.w),
            Text(
              isActive
                  ? AppStrings.activeLabel.tr(context)
                  : AppStrings.inactiveLabel.tr(context),
              style: context.text.labelSmall?.copyWith(
                color: isActive ? Colors.green : context.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.sp, color: context.textSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
