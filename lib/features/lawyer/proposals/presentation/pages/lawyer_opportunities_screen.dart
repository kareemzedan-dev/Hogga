import 'package:flutter/material.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/requests/domain/entities/lawyer_case_request.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';
import 'package:hogga/features/lawyer/requests/presentation/cubit/lawyer_requests_cubit.dart';
import '../widgets/submit_proposal_sheet.dart';
import 'lawyer_opportunity_details_screen.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/utils/app_colors.dart';

class LawyerOpportunitiesScreen extends StatefulWidget {
  final bool isBottomNav;
  const LawyerOpportunitiesScreen({super.key, this.isBottomNav = false});

  @override
  State<LawyerOpportunitiesScreen> createState() => _LawyerOpportunitiesScreenState();
}

class _LawyerOpportunitiesScreenState extends State<LawyerOpportunitiesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: context.pageBg,
          appBar: AppBar(
            backgroundColor: context.pageBg,
            elevation: 0,
            title: Text(AppStrings.services.tr(context), style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary)),
            centerTitle: true,
            leading: widget.isBottomNav
                ? null
                : IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
            bottom: TabBar(
              labelColor: context.colors.primary,
              unselectedLabelColor: context.textSecondary,
              indicatorColor: context.colors.primary,
              indicatorWeight: 3.h,
              labelStyle: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: AppStrings.clientRequests.tr(context)),
                Tab(text: AppStrings.availableServices.tr(context)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildRequestsTab(),
              _buildAvailableServicesTab(),
            ],
          ),
        ),
      );
  }

  Widget _buildRequestsTab() {
    return BlocListener<LawyerRequestsCubit, LawyerRequestsState>(
      listener: (context, state) {
        if (state is LawyerRequestActionSuccess) {
          AppSnackbar.showSuccess(context, message: state.message);
        } else if (state is LawyerRequestsError) {
          AppSnackbar.showError(context, message: state.message);
        }
      },
      child: BlocBuilder<LawyerRequestsCubit, LawyerRequestsState>(
        builder: (context, state) {
          if (state is LawyerRequestsLoading) {
            return const LawyerShimmerLoading();
          } else if (state is LawyerRequestsLoaded || state is LawyerRequestActionSuccess) {
            final requests = state is LawyerRequestsLoaded ? state.requests : (context.read<LawyerRequestsCubit>().state as LawyerRequestsLoaded).requests;
            if (requests.isEmpty) {
              return CustomEmptyState(
                title: AppStrings.noOpportunities.tr(context),
                subtitle: AppStrings.noOpportunitiesSubtitle.tr(context),
                icon: Icons.business_center_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<LawyerRequestsCubit>().getRequests(),
              child: ListView.separated(
                padding: EdgeInsets.all(20.w),
                itemCount: requests.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  return _buildOpportunityCard(context, requests[index]);
                },
              ),
            );
          } else if (state is LawyerRequestsError) {
            return CustomErrorState(
              message: state.message,
              onRetry: () => context.read<LawyerRequestsCubit>().getRequests(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAvailableServicesTab() {
    return BlocBuilder<LawyerProposalsCubit, LawyerProposalsState>(
      builder: (context, state) {
        if (state is LawyerProposalsLoading) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerProposalsLoaded) {
          if (state.availableServices.isEmpty) {
            return CustomEmptyState(
              title: AppStrings.noOpportunities.tr(context),
              subtitle: AppStrings.emptyServicesHistory.tr(context),
              icon: Icons.design_services_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<LawyerProposalsCubit>().getProposalsData(),
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: state.availableServices.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildAvailableServiceCard(context, state.availableServices[index]);
              },
            ),
          );
        } else if (state is LawyerProposalsError) {
          return CustomErrorState(
            message: state.message,
            onRetry: () => context.read<LawyerProposalsCubit>().getProposalsData(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // _buildEmptyState removed as it's replaced by CustomEmptyState

  Widget _buildOpportunityCard(BuildContext context, LawyerCaseRequest request) {
    return InkWell(
      onTap: () {},
        // MaterialPageRoute(builder: (context) => LawyerOpportunityDetailsScreen(requestId: request.id)),

      child: LawyerCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  request.statusText,
                  style: context.text.labelSmall?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                '${request.date} ${request.time}',
                style: context.text.labelSmall?.copyWith(color: context.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            request.title,
            style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LawyerOpportunityDetailsScreen(requestId: request.id, isDirectRequest: true)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(AppStrings.viewDetails.tr(context), style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 11.sp, color: context.colors.onPrimary)),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAvailableServiceCard(BuildContext context, LawyerAvailableService service) {
    return LawyerCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  service.categoryItemName,
                  style: context.text.labelSmall?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                service.createdAt,
                style: context.text.labelSmall?.copyWith(color: context.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            service.title,
            style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (service.minPrice != null || service.maxPrice != null)
                Text(
                  '${service.minPrice ?? '-'} - ${service.maxPrice ?? '-'} ${AppStrings.currencyRial.tr(context)}',
                  style: context.text.titleSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16.sp, color: context.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    AppStrings.proposalsCountLabel.tr(context, namedArgs: {'count': service.proposalsCount.toString()}),
                    style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LawyerOpportunityDetailsScreen(requestId: service.id, isDirectRequest: false)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.viewDetails.tr(context),
                  style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 11.sp, color: context.colors.primary),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () => _showSubmitProposalSheet(
                  context,
                  service.id,
                  service.title,
                  minPrice: service.minPrice,
                  maxPrice: service.maxPrice,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.submitPriceOffer.tr(context),
                  style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 11.sp, color: context.colors.onPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSubmitProposalSheet(BuildContext context, int id, String title, {String? minPrice, String? maxPrice}) {
    final cubit = context.read<LawyerProposalsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => BlocProvider.value(
        value: cubit,
        child: SubmitProposalSheet(
          caseId: id,
          caseTitle: title,
          minPrice: minPrice,
          maxPrice: maxPrice,
        ),
      ),
    );
  }
}
