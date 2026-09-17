import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';
import 'package:hogga/features/lawyer/proposals/presentation/widgets/submit_proposal_sheet.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/injection_container.dart';

import 'package:hogga/features/lawyer/proposals/presentation/widgets/proposal_card.dart';

import '../../../../../core/utils/app_colors.dart';

class LawyerProposalsScreen extends StatefulWidget {
  const LawyerProposalsScreen({super.key});

  @override
  State<LawyerProposalsScreen> createState() => _LawyerProposalsScreenState();
}

class _LawyerProposalsScreenState extends State<LawyerProposalsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LawyerProposalsCubit>()..getProposalsData(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.myProposals.tr(context),
        ),
        body: BlocConsumer<LawyerProposalsCubit, LawyerProposalsState>(
          listener: (context, state) {
            if (state is LawyerProposalActionSuccess) {
              AppSnackbar.showSuccess(context, message: state.message);
            } else if (state is LawyerProposalsError) {
              AppSnackbar.showError(context, message: state.message);
            }
          },
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
                return CustomEmptyState(
                  title: AppStrings.noProposals.tr(context),
                  subtitle: AppStrings.noProposalsSubtitle.tr(context),
                  icon: Icons.assignment_outlined,
                  buttonLabel: AppStrings.browseOpportunities.tr(context),
                  onAction: () => Navigator.pushNamed(
                    context,
                    AppRoutes.lawyerOpportunities,
                  ),
                );
              }
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () =>
                        context.read<LawyerProposalsCubit>().getProposalsData(),
                    child: ListView.separated(
                      padding: EdgeInsets.all(20.w),
                      itemCount: proposalsData.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final proposal = proposalsData[index];
                        return ProposalCard(
                          proposal: proposal,
                          onEdit: () =>
                              _showEditProposalSheet(context, proposal),
                          onDelete: () =>
                              _showDeleteConfirmation(context, proposal.id, index: index),
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
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.w),
                    itemCount: currentProposals.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final proposal = currentProposals[index];
                      return ProposalCard(
                        proposal: proposal,
                        onEdit: () =>
                            _showEditProposalSheet(context, proposal),
                        onDelete: () =>
                            _showDeleteConfirmation(context, proposal.id, index: index),
                      );
                    },
                  ),
                );
              }
              return CustomErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<LawyerProposalsCubit>().getProposalsData(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
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

  void _showEditProposalSheet(BuildContext context, LawyerProposal proposal) {
    final cubit = context.read<LawyerProposalsCubit>();
    showModalBottomSheet(
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
  }
}
