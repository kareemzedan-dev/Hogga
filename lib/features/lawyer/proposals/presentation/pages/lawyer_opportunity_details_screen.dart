import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';
import 'package:hogga/features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';
import 'package:hogga/features/lawyer/requests/domain/entities/lawyer_case_request_details.dart';
import 'package:hogga/features/lawyer/requests/presentation/cubit/lawyer_requests_cubit.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/requests/presentation/widgets/accept_request_sheet.dart';
import 'package:hogga/injection_container.dart';

import '../widgets/submit_proposal_sheet.dart';

class LawyerOpportunityDetailsScreen extends StatefulWidget {
  final int requestId;
  final bool isDirectRequest;

  const LawyerOpportunityDetailsScreen({
    super.key,
    required this.requestId,
    this.isDirectRequest = false,
  });

  @override
  State<LawyerOpportunityDetailsScreen> createState() =>
      _LawyerOpportunityDetailsScreenState();
}

class _LawyerOpportunityDetailsScreenState
    extends State<LawyerOpportunityDetailsScreen> {
  bool _isRejecting = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = sl<LawyerRequestsCubit>();
            if (widget.isDirectRequest) {
              cubit.getRequestDetails(widget.requestId);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = sl<LawyerProposalsCubit>();
            if (!widget.isDirectRequest) {
              cubit.getAvailableServiceDetails(widget.requestId);
              cubit.getProposalsData(showLoading: false);
            }
            return cubit;
          },
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LawyerRequestsCubit, LawyerRequestsState>(
            listener: (context, state) {
              if (state is LawyerRequestActionSuccess) {
                AppSnackbar.showSuccess(context, message: state.message);
                if (_isRejecting) {
                  _isRejecting = false;
                  Navigator.pop(context, true);
                } else {
                  context
                      .read<LawyerRequestsCubit>()
                      .getRequestDetails(widget.requestId, showLoading: false);
                }
              } else if (state is LawyerRequestActionError) {
                _isRejecting = false;
                AppSnackbar.showError(context, message: state.message);
                if (state.message.contains('لم يعد متاحاً') ||
                    state.message.contains('ملغي')) {
                  Navigator.pop(context, true);
                }
              } else if (state is LawyerRequestsError) {
                AppSnackbar.showError(context, message: state.message);
              }
            },
          ),
          BlocListener<LawyerProposalsCubit, LawyerProposalsState>(
            listener: (context, state) {
              if (state is LawyerProposalActionSuccess) {
                AppSnackbar.showSuccess(context, message: state.message);
                context.read<LawyerProposalsCubit>().getAvailableServiceDetails(widget.requestId);
                context.read<LawyerProposalsCubit>().getProposalsData(showLoading: false);
              } else if (state is LawyerProposalActionError) {
                AppSnackbar.showError(context, message: state.message);
                if (state.message.contains('لم يعد متاحاً') ||
                    state.message.contains('ملغي')) {
                  context.read<LawyerProposalsCubit>().getAvailableServiceDetails(widget.requestId);
                }
              } else if (state is LawyerProposalsError) {
                AppSnackbar.showError(context, message: state.message);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: context.pageBg,
          appBar: MainAppbar(
            title: AppStrings.caseDetails.tr(context),
            onBack: () => Navigator.pop(context, true),
          ),
          body: widget.isDirectRequest
              ? _buildDirectRequestBody(context)
              : _buildAvailableServiceBody(context),
        ),
      ),
    );
  }

  // ─── Direct Request Body ───────────────────────────────────────────────────
  Widget _buildDirectRequestBody(BuildContext context) {
    return BlocBuilder<LawyerRequestsCubit, LawyerRequestsState>(
      builder: (context, state) {
        final cubit = context.read<LawyerRequestsCubit>();
        final details = state is LawyerRequestDetailsLoaded
            ? state.details
            : cubit.currentDetails;

        if (details != null) {
          return _buildDirectRequestContent(context, details);
        }

        if (state is LawyerRequestDetailsLoading ||
            state is LawyerRequestsInitial) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerRequestsError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: context.colors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDirectRequestContent(
    BuildContext context,
    LawyerCaseRequestDetails details,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClientInfoCard(
            context,
            name: details.client.name,
            status: details.client.status,
            photo: details.client.photo,
          ),
          SizedBox(height: 24.h),
          _buildTitleAndStatus(
            context,
            title: details.serviceName,
            statusText: details.statusText,
          ),
          if (details.description != null &&
              details.description!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              AppStrings.description.tr(context),
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              details.description!,
              style: context.text.bodyMedium?.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          SizedBox(height: 24.h),
          _buildAppointmentCard(
            context,
            date: details.appointment.date,
            time: details.appointment.time,
          ),
          SizedBox(height: 32.h),
          if (details.statusText.contains('مقبول') ||
              details.statusText.toLowerCase().contains('accepted')) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF27AE60),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'تم قبول هذا الطلب بنجاح',
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (details.statusText.contains('ملغي') ||
              details.statusText.toLowerCase().contains('cancel')) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: context.colors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: context.colors.error,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'هذا الطلب لم يعد متاحاً أو تم إلغاؤه',
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.error,
                      side: BorderSide(color: context.colors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      AppStrings.refuse.tr(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.accept.tr(context),
                    onPressed: () => _showAcceptRequestSheet(
                      context,
                      details.id,
                      details.serviceName,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Available Service Body ────────────────────────────────────────────────
  Widget _buildAvailableServiceBody(BuildContext context) {
    return BlocBuilder<LawyerProposalsCubit, LawyerProposalsState>(
      builder: (context, state) {
        final cubit = context.read<LawyerProposalsCubit>();
        final details = state is AvailableServiceDetailsLoaded
            ? state.details
            : cubit.currentAvailableServiceDetails;

        if (details != null) {
          return _buildAvailableServiceContent(context, details);
        }

        if (state is AvailableServiceDetailsLoading ||
            state is LawyerProposalsInitial) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerProposalsError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: context.colors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAvailableServiceContent(
    BuildContext context,
    AvailableServiceDetails details,
  ) {
    final cubit = context.read<LawyerProposalsCubit>();
    LawyerProposal? existingProposal;
    for (final p in cubit.currentProposals) {
      if (p.legalCase.id == details.id) {
        existingProposal = p;
        break;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client info
          _buildClientInfoCard(
            context,
            name: details.user.name,
            photo: details.user.photo,
          ),
          SizedBox(height: 24.h),
          // Title & category
          _buildTitleAndStatus(
            context,
            title: details.title,
            statusText: details.categoryItemName,
          ),
          if (details.description != null &&
              details.description!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              AppStrings.description.tr(context),
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              details.description!,
              style: context.text.bodyMedium?.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          // Execution date
          if (details.executionDate != null) ...[
            SizedBox(height: 24.h),
            _buildAppointmentCard(context, date: details.executionDate!),
          ],
          // Proposals count
          SizedBox(height: 16.h),
          _buildProposalsCount(context, details.proposalsCount),
          SizedBox(height: 32.h),

          // Proposal submitted card or submit button
          if (existingProposal != null) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF27AE60),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تم تقديم عرضك بنجاح',
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'قيمة العرض: ${existingProposal.price} ${AppStrings.currencySymbol.tr(context)}',
                          style: context.text.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: AppStrings.editProposal.tr(context),
              onPressed: () => _showEditProposalSheet(
                context,
                details.id,
                details.title,
                existingProposal!,
              ),
            ),
          ] else ...[
            CustomButton(
              text: AppStrings.submitProposal.tr(context),
              onPressed: () => _showSubmitProposalSheet(context, details),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────────────────
  Widget _buildClientInfoCard(
    BuildContext context, {
    required String name,
    String? status,
    String? photo,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: photo != null && photo.isNotEmpty
                ? CachedNetworkImageProvider(photo) as ImageProvider
                : const AssetImage(AppAssets.userPlaceholder),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (status != null)
                  Text(
                    status,
                    style: context.text.bodySmall?.copyWith(
                      color: context.accentGolden,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndStatus(
    BuildContext context, {
    required String title,
    String? statusText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
        if (statusText != null) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  statusText,
                  style: context.text.labelSmall?.copyWith(
                    color: context.accentGolden,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context, {
    String? date,
    String? time,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        children: [
          if (date != null)
            _buildInfoRow(
              context,
              Icons.calendar_today_outlined,
              AppStrings.date.tr(context),
              date,
            ),
          if (date != null && time != null) Divider(height: 24.h),
          if (time != null)
            _buildInfoRow(
              context,
              Icons.access_time_rounded,
              AppStrings.time.tr(context),
              time,
            ),
        ],
      ),
    );
  }

  Widget _buildProposalsCount(BuildContext context, int count) {
    return Row(
      children: [
        Icon(Icons.people_outline, size: 18.sp, color: context.textSecondary),
        SizedBox(width: 8.w),
        Text(
          AppStrings.proposalsCountLabel.tr(
            context,
            namedArgs: {'count': count.toString()},
          ),
          style: context.text.bodySmall?.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: context.accentGolden),
        SizedBox(width: 12.w),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(color: context.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ─── Dialogs & Sheets ──────────────────────────────────────────────────────
  void _showRejectDialog(BuildContext context) {
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
              setState(() {
                _isRejecting = true;
              });
              context.read<LawyerRequestsCubit>().rejectRequest(
                widget.requestId,
              );
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
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showSubmitProposalSheet(
    BuildContext context,
    AvailableServiceDetails details,
  ) async {
    final cubit = context.read<LawyerProposalsCubit>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => BlocProvider.value(
        value: cubit,
        child: SubmitProposalSheet(
          caseId: details.id,
          caseTitle: details.title,
        ),
      ),
    );
    if (result == true && mounted) {
      cubit.getAvailableServiceDetails(details.id);
      cubit.getProposalsData(showLoading: false);
    }
  }

  void _showEditProposalSheet(
    BuildContext context,
    int caseId,
    String caseTitle,
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
          caseId: caseId,
          caseTitle: caseTitle,
          proposalId: proposal.id,
          initialDescription: proposal.description,
          initialPrice: proposal.price,
        ),
      ),
    );
    if (result == true && mounted) {
      cubit.getAvailableServiceDetails(caseId);
      cubit.getProposalsData(showLoading: false);
    }
  }
}
