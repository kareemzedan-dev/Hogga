import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';
import 'package:hogga/features/lawyer/requests/domain/entities/lawyer_case_request.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';
import 'package:hogga/features/lawyer/requests/presentation/cubit/lawyer_requests_cubit.dart';
import 'package:hogga/features/lawyer/requests/presentation/widgets/accept_request_sheet.dart';
import '../widgets/submit_proposal_sheet.dart';
import '../widgets/proposal_card.dart';
import 'lawyer_opportunity_details_screen.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';

class LawyerOpportunitiesScreen extends StatefulWidget {
  final bool isBottomNav;
  final int initialTabIndex;
  const LawyerOpportunitiesScreen({
    super.key,
    this.isBottomNav = false,
    this.initialTabIndex = 0,
  });

  @override
  State<LawyerOpportunitiesScreen> createState() =>
      _LawyerOpportunitiesScreenState();
}

class _LawyerOpportunitiesScreenState extends State<LawyerOpportunitiesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: MultiBlocListener(
        listeners: [
          BlocListener<LawyerProposalsCubit, LawyerProposalsState>(
            listener: (context, state) {
              if (state is LawyerProposalActionSuccess) {
                AppSnackbar.showSuccess(context, message: state.message);
                context
                    .read<LawyerProposalsCubit>()
                    .getProposalsData(showLoading: false);
              } else if (state is LawyerProposalActionError) {
                AppSnackbar.showError(context, message: state.message);
                if (state.message.contains('لم يعد متاحاً') ||
                    state.message.contains('ملغي')) {
                  context
                      .read<LawyerProposalsCubit>()
                      .getProposalsData(showLoading: false);
                }
              } else if (state is LawyerProposalsError) {
                AppSnackbar.showError(context, message: state.message);
              }
            },
          ),
          BlocListener<LawyerRequestsCubit, LawyerRequestsState>(
            listener: (context, state) {
              if (state is LawyerRequestActionSuccess) {
                AppSnackbar.showSuccess(context, message: state.message);
                context
                    .read<LawyerRequestsCubit>()
                    .getRequests(showLoading: false);
              } else if (state is LawyerRequestActionError) {
                AppSnackbar.showError(context, message: state.message);
                if (state.message.contains('لم يعد متاحاً') ||
                    state.message.contains('ملغي')) {
                  context
                      .read<LawyerRequestsCubit>()
                      .getRequests(showLoading: false);
                }
              } else if (state is LawyerRequestsError) {
                AppSnackbar.showError(context, message: state.message);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: context.pageBg,
          appBar: MainAppbar(
            title: AppStrings.services.tr(context),
            backBtn: !widget.isBottomNav,
            bottom: TabBar(
              labelColor: context.isDark ? AppColors.cream : AppColors.primary,
              unselectedLabelColor: context.textSecondary,
              indicatorColor: AppColors.cream,
              indicatorWeight: 3.h,
              dividerColor: AppColors.cream.withValues(alpha: 0.18),
              labelStyle: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11.5.sp,
              ),
              unselectedLabelStyle: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 11.sp,
              ),
              tabs: [
                Tab(text: AppStrings.clientRequests.tr(context)),
                Tab(text: AppStrings.availableServices.tr(context)),
                Tab(text: AppStrings.myProposals.tr(context)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildRequestsTab(),
              _buildAvailableServicesTab(),
              _buildProposalsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableEmptyOrError({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.golden,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<LawyerRequestsCubit, LawyerRequestsState>(
      builder: (context, state) {
        if (state is LawyerRequestsLoading) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerRequestsLoaded ||
            state is LawyerRequestActionSuccess ||
            state is LawyerRequestActionLoading ||
            state is LawyerRequestActionError) {
          final requests = state is LawyerRequestsLoaded
              ? state.requests
              : context.read<LawyerRequestsCubit>().currentRequests;
          if (requests.isEmpty) {
            return _buildScrollableEmptyOrError(
              onRefresh: () =>
                  context.read<LawyerRequestsCubit>().getRequests(),
              child: CustomEmptyState(
                title: AppStrings.noOpportunities.tr(context),
                subtitle: AppStrings.noOpportunitiesSubtitle.tr(context),
                icon: Icons.business_center_outlined,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<LawyerRequestsCubit>().getRequests(),
            color: AppColors.golden,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: requests.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildOpportunityCard(context, requests[index]);
              },
            ),
          );
        } else if (state is LawyerRequestsError) {
          return _buildScrollableEmptyOrError(
            onRefresh: () =>
                context.read<LawyerRequestsCubit>().getRequests(),
            child: CustomErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<LawyerRequestsCubit>().getRequests(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAvailableServicesTab() {
    return BlocBuilder<LawyerProposalsCubit, LawyerProposalsState>(
      builder: (context, state) {
        if (state is LawyerProposalsLoading) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerProposalsLoaded) {
          if (state.availableServices.isEmpty) {
            return _buildScrollableEmptyOrError(
              onRefresh: () =>
                  context.read<LawyerProposalsCubit>().getProposalsData(),
              child: CustomEmptyState(
                title: AppStrings.noOpportunities.tr(context),
                subtitle: AppStrings.emptyServicesHistory.tr(context),
                icon: Icons.design_services_outlined,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                context.read<LawyerProposalsCubit>().getProposalsData(),
            color: AppColors.golden,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: state.availableServices.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildAvailableServiceCard(
                  context,
                  state.availableServices[index],
                );
              },
            ),
          );
        } else if (state is LawyerProposalsError) {
          return _buildScrollableEmptyOrError(
            onRefresh: () =>
                context.read<LawyerProposalsCubit>().getProposalsData(),
            child: CustomErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<LawyerProposalsCubit>().getProposalsData(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProposalsTab() {
    return BlocBuilder<LawyerProposalsCubit, LawyerProposalsState>(
      builder: (context, state) {
        if (state is LawyerProposalsLoading) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerProposalsLoaded ||
            state is LawyerProposalActionLoading ||
            state is LawyerProposalActionSuccess) {
          final proposalsData = state is LawyerProposalsLoaded
              ? state.proposals
              : context.read<LawyerProposalsCubit>().currentProposals;

          if (proposalsData.isEmpty) {
            return _buildScrollableEmptyOrError(
              onRefresh: () =>
                  context.read<LawyerProposalsCubit>().getProposalsData(),
              child: CustomEmptyState(
                title: AppStrings.noProposals.tr(context),
                subtitle: AppStrings.noProposalsSubtitle.tr(context),
                icon: Icons.assignment_outlined,
              ),
            );
          }
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () =>
                    context.read<LawyerProposalsCubit>().getProposalsData(),
                color: AppColors.golden,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  itemCount: proposalsData.length,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final proposal = proposalsData[index];
                    return ProposalCard(
                      proposal: proposal,
                      onEdit: () => _showEditProposalSheet(context, proposal),
                      onDelete: () => _showDeleteProposalConfirmation(
                        context,
                        proposal.id,
                        index: index,
                      ),
                    );
                  },
                ),
              ),
              if (state is LawyerProposalActionLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.golden),
                  ),
                ),
            ],
          );
        } else if (state is LawyerProposalsError) {
          final currentProposals =
              context.read<LawyerProposalsCubit>().currentProposals;
          if (currentProposals.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<LawyerProposalsCubit>().getProposalsData(),
              color: AppColors.golden,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: currentProposals.length,
                separatorBuilder: (context, index) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final proposal = currentProposals[index];
                  return ProposalCard(
                    proposal: proposal,
                    onEdit: () => _showEditProposalSheet(context, proposal),
                    onDelete: () => _showDeleteProposalConfirmation(
                      context,
                      proposal.id,
                      index: index,
                    ),
                  );
                },
              ),
            );
          }
          return _buildScrollableEmptyOrError(
            onRefresh: () =>
                context.read<LawyerProposalsCubit>().getProposalsData(),
            child: CustomErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<LawyerProposalsCubit>().getProposalsData(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteProposalConfirmation(
    BuildContext context,
    int proposalId, {
    int? index,
  }) {
    final cubit = context.read<LawyerProposalsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CustomConfirmationSheet(
        iconData: Icons.remove_circle_outline_rounded,
        title: AppStrings.cancelProposal.tr(sheetContext),
        subtitle: AppStrings.confirmCancelProposal.tr(sheetContext),
        actionText: AppStrings.cancelProposal.tr(sheetContext),
        actionColor: AppColors.error,
        iconColor: AppColors.error,
        onAction: () {
          Navigator.pop(sheetContext);
          cubit.deleteProposal(proposalId, index: index);
        },
      ),
    );
  }

  void _showEditProposalSheet(
    BuildContext context,
    LawyerProposal proposal,
  ) async {
    final cubit = context.read<LawyerProposalsCubit>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => BlocProvider.value(
        value: cubit,
        child: SubmitProposalSheet(
          caseId: proposal.legalCase.id,
          caseTitle: proposal.legalCase.title,
          proposalId: proposal.id,
          initialDescription: proposal.description,
          initialPrice: proposal.price,
        ),
      ),
    );
    if (result == true && mounted) {
      cubit.getProposalsData(showLoading: false);
    }
  }

  void _showAcceptRequestSheet(
    BuildContext context,
    int requestId,
    String requestTitle,
  ) async {
    final cubit = context.read<LawyerRequestsCubit>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => BlocProvider.value(
        value: cubit,
        child: AcceptRequestSheet(
          requestId: requestId,
          requestTitle: requestTitle,
        ),
      ),
    );
    if (result == true && mounted) {
      cubit.getRequests(showLoading: false);
    }
  }

  void _showRejectDialog(BuildContext context, int requestId) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: context.pageBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppStrings.confirmRefuse.tr(context),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppStrings.areYouSure.tr(context),
          style: context.text.bodyMedium?.copyWith(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: Text(
              AppStrings.cancel.tr(context),
              style: context.text.labelSmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<LawyerRequestsCubit>().rejectRequest(requestId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.refuse.tr(context),
              style: context.text.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(
    BuildContext context,
    LawyerCaseRequest request,
  ) {
    return InkWell(
      onTap: () {},
      child: LawyerCard(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: _buildInfoChip(
                    context,
                    request.statusText,
                    color: context.accentGolden,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      '${request.date} ${request.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              request.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11.5.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.end,
              children: [
                _buildCompactButton(
                  context,
                  text: AppStrings.viewDetails.tr(context),
                  isFilled: false,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LawyerOpportunityDetailsScreen(
                          requestId: request.id,
                          isDirectRequest: true,
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context
                          .read<LawyerRequestsCubit>()
                          .getRequests(showLoading: false);
                    }
                  },
                ),
                _buildCompactButton(
                  context,
                  text: AppStrings.refuse.tr(context),
                  isFilled: false,
                  textColor: context.colors.error,
                  borderColor: context.colors.error,
                  onPressed: () => _showRejectDialog(context, request.id),
                ),
                _buildCompactButton(
                  context,
                  text: AppStrings.accept.tr(context),
                  isFilled: true,
                  onPressed: () => _showAcceptRequestSheet(
                    context,
                    request.id,
                    request.title,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableServiceCard(
    BuildContext context,
    LawyerAvailableService service,
  ) {
    return LawyerCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: _buildInfoChip(
                  context,
                  service.categoryItemName,
                  color: context.accentGolden,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    service.createdAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                      fontSize: 9.5.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            service.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11.5.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 13.sp,
                      color: context.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        AppStrings.proposalsCountLabel.tr(
                          context,
                          namedArgs: {
                            'count': service.proposalsCount.toString(),
                          },
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.end,
            children: [
              _buildCompactButton(
                context,
                text: AppStrings.viewDetails.tr(context),
                isFilled: false,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LawyerOpportunityDetailsScreen(
                      requestId: service.id,
                      isDirectRequest: false,
                    ),
                  ),
                ),
              ),
              _buildCompactButton(
                context,
                text: AppStrings.submitProposal.tr(context),
                isFilled: true,
                onPressed: () => _showSubmitProposalSheet(
                  context,
                  service.id,
                  service.title,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String text, {
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 9.5.sp,
        ),
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    required bool isFilled,
    Color? textColor,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    final effectiveBg =
        isFilled ? (backgroundColor ?? context.colors.primary) : null;
    final effectiveFg = textColor ??
        (isFilled ? context.colors.onPrimary : context.colors.primary);
    final effectiveBorder = borderColor ?? context.colors.primary;

    if (!isFilled) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveFg,
          side: BorderSide(color: effectiveBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: context.text.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 9.5.sp,
            color: effectiveFg,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        foregroundColor: effectiveFg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 9.5.sp,
          color: effectiveFg,
        ),
      ),
    );
  }

  void _showSubmitProposalSheet(
    BuildContext context,
    int id,
    String title,
  ) async {
    final cubit = context.read<LawyerProposalsCubit>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => BlocProvider.value(
        value: cubit,
        child: SubmitProposalSheet(caseId: id, caseTitle: title),
      ),
    );
    if (result == true && mounted) {
      cubit.getProposalsData(showLoading: false);
    }
  }
}
