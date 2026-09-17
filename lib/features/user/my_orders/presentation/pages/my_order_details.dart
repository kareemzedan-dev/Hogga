import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import '../../../../../core/widgets/main_appbar.dart';
import '../../../../../../../injection_container.dart' as di;
import '../../data/models/order_details.dart';
import '../cubit/legal_case_actions_cubit.dart';
import '../cubit/my_orders_cubit.dart';
import '../cubit/my_orders_states.dart';
import 'order_details/widgets/order_details_header.dart';
import 'order_details/widgets/order_summary_card.dart';
import 'order_details/widgets/order_additional_info.dart';
import 'order_details/widgets/proposal_card.dart';
import '../../../../../config/routes/app_routes.dart';
import '../widgets/order_details_shimmer.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_network_image.dart';

class OrderDetailsView extends StatefulWidget {
  final int orderId;
  final String? recordType;

  const OrderDetailsView({super.key, required this.orderId, this.recordType});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  int? _selectedProposalId;
  late final LegalCaseActionsCubit _actionsCubit;

  @override
  void initState() {
    super.initState();
    _actionsCubit = di.sl<LegalCaseActionsCubit>();
    context.read<MyOrdersCubit>().getOrderDetails(
      orderId: widget.orderId,
      recordType: widget.recordType,
    );
  }

  @override
  void dispose() {
    _actionsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _actionsCubit,
      child: BlocListener<LegalCaseActionsCubit, LegalCaseActionsState>(
        listener: (listenerContext, actionState) {
          if (actionState.errorMessage != null &&
              actionState.errorMessage!.isNotEmpty) {
            AppSnackbar.showError(context, message: actionState.errorMessage);
            _actionsCubit.clearMessages();
          }
          if (actionState.successMessage != null &&
              actionState.successMessage!.isNotEmpty) {
            AppSnackbar.showSuccess(
              context,
              message: actionState.successMessage,
            );
            final type = actionState.actionType;
            if (type == 'cancel') {
              _actionsCubit.clearMessages();
              Navigator.of(
                context,
              ).pop({'cancelled': true, 'orderId': widget.orderId});
            } else if (type == 'accept') {
              final paymentUrl = actionState.paymentUrl;
              final caseId = actionState.caseId ?? widget.orderId;
              _actionsCubit.clearMessages();
              final cubit = context.read<MyOrdersCubit>();
              final currentState = cubit.state;
              final currentOrder = currentState is MyOrderDetailsLoaded
                  ? currentState.orderDetails
                  : null;
              if (paymentUrl != null && paymentUrl.isNotEmpty) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.paymentWebView,
                  arguments: {
                    'paymentUrl': paymentUrl,
                    'caseNumber': currentOrder?.caseNumber ?? '',
                    'caseId': caseId,
                    'recordType': currentOrder?.recordType ?? 'service',
                  },
                ).then((_) {
                  if (mounted) {
                    cubit.getOrderDetails(
                      orderId: widget.orderId,
                      recordType: widget.recordType,
                    );
                  }
                });
              } else {
                // No payment URL - reload to reflect updated state
                cubit.getOrderDetails(
                  orderId: widget.orderId,
                  recordType: widget.recordType,
                );
              }
            } else {
              _actionsCubit.clearMessages();
              // For uploads and other actions, reload details immediately
              final cubit = context.read<MyOrdersCubit>();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  cubit.getOrderDetails(
                    orderId: widget.orderId,
                    recordType: widget.recordType,
                  );
                }
              });
            }
          }
        },
        child: BlocBuilder<MyOrdersCubit, MyOrdersState>(
          builder: (context, state) {
            final title = state is MyOrderDetailsLoaded
                ? (state.orderDetails.title.isNotEmpty
                      ? state.orderDetails.title
                      : (state.orderDetails.isConsultation
                            ? AppStrings.consultationDetails.tr(context)
                            : AppStrings.requestDetails.tr(context)))
                : (widget.recordType == 'consultation'
                      ? AppStrings.consultationDetails.tr(context)
                      : AppStrings.requestDetails.tr(context));
            final actionState = context.watch<LegalCaseActionsCubit>().state;
            final bottomActionOrder = state is MyOrderDetailsLoaded
                ? state.orderDetails
                : null;
            final showCompleteBottomAction =
                bottomActionOrder?.canCompleteByUser ?? false;
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: context.pageBg,
                  appBar: MainAppbar(title: title),
                  bottomNavigationBar: showCompleteBottomAction
                      ? _buildCompleteBottomBar(
                          bottomActionOrder!,
                          actionState.isLoading &&
                              actionState.actionType == 'complete',
                        )
                      : null,
                  body: Builder(
                    builder: (context) {
                      if (state is MyOrderDetailsLoading) {
                        return const OrderDetailsShimmer();
                      }
                      if (state is MyOrderDetailsError) {
                        return Center(
                          child: Text(
                            state.message.tr(context),
                            style: TextStyle(color: AppColors.error),
                          ),
                        );
                      }
                      if (state is MyOrderDetailsLoaded) {
                        final order = state.orderDetails;
                        _selectedProposalId ??=
                            order.ratableProposal?.id ??
                            (order.proposals.isNotEmpty
                                ? order.proposals.first.id
                                : null);
                        final ratingTarget = order.ratingTarget;
                        return SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.horizontalPadding,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OrderDetailsHeader(order: order),
                              const SizedBox(height: 24),
                              OrderSummaryCard(
                                order: order,
                                onViewDetails: () {
                                  _showDocumentsSheet(order.id);
                                },
                                onCancelOrder: () {
                                  _showCancelCaseDialog(order.id);
                                },
                                onOpenChat: order.hasChatRoom
                                    ? () => _openChat(order)
                                    : null,
                                onOpenCall: order.hasChatRoom
                                    ? () => _openCall(order)
                                    : null,
                                onCompleteOrder: null,
                              ),
                              SizedBox(height: 8.h),

                              if (order.hasAcceptedLawyer) ...[
                                _buildAcceptedLawyerCard(order),
                                SizedBox(height: 10.h),
                              ] else if (!order.isConsultation &&
                                  order.proposals.isNotEmpty) ...[
                                _buildProposalsSection(order),
                                SizedBox(height: 10.h),
                              ] else if (order.isPending) ...[
                                _buildWaitingForProposalsCard(order),
                                SizedBox(height: 10.h),
                              ],
                              if (order.canRateLawyer &&
                                  ratingTarget != null) ...[
                                _buildRateLawyerCard(ratingTarget),
                                const SizedBox(height: 20),
                              ],
                              if (order.financials.totalPrice > 0 ||
                                  order.proposals.any((p) => p.isAccepted) ||
                                  order.hasAcceptedLawyer) ...[
                                OrderReceiptSection(order: order),
                                const SizedBox(height: 40),
                              ],
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                if (actionState.isLoading && actionState.actionType == 'accept')
                  Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 32.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 20.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.golden,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? 'جاري قبول العرض وتجهيز الدفع...'
                                  : 'Processing acceptance & preparing payment...',
                              textAlign: TextAlign.center,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompleteBottomBar(OrderDetailsData order, bool isCompleting) {
    final label =
        (order.isConsultation
                ? AppStrings.completeConsultation
                : AppStrings.completeService)
            .tr(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border(top: BorderSide(color: context.divColor)),
        ),
        child: SizedBox(
          height: 48.h,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isCompleting
                ? null
                : () => _showCompleteOrderDialog(order),
            icon: isCompleting
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.done_all_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
            label: Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              disabledBackgroundColor: const Color(
                0xFF27AE60,
              ).withValues(alpha: 0.65),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateLawyerCard(CaseProposal proposal) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.golden.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.golden.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: const BoxDecoration(
              color: AppColors.golden,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: Colors.white, size: 26.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.rateLawyer.tr(context),
                  style: context.text.titleSmall?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  proposal.lawyerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          CustomButton(
            isSmall: true,
            width: 84,
            height: 10,
            onPressed: () => _showRateLawyerSheet(proposal),
            text: AppStrings.rateLawyer.tr(context),
            backgroundColor: AppColors.golden,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _openChat(OrderDetailsData order) {
    final chatRoomId = order.chatRoomId;
    if (chatRoomId == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'chatRoomId': chatRoomId,
        'lawyerName': order.lawyerName,
        'caseTitle': order.title,
        'serviceType': order.serviceTypeKey,
        'recordType': order.recordType,
        'isConsultation': order.isConsultation,
        'isCall': order.isCallType,
      },
    );
  }

  void _openCall(OrderDetailsData order) {
    final chatRoomId = order.chatRoomId;
    if (chatRoomId == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.call,
      arguments: {
        'chatRoomId': chatRoomId,
        'lawyerName': order.lawyerName,
        'lawyerPhoto': null,
        'serviceType': order.serviceTypeKey,
      },
    );
  }

  Future<void> _showRateLawyerSheet(CaseProposal proposal) async {
    final commentController = TextEditingController();
    final myOrdersCubit = context.read<MyOrdersCubit>();
    var selectedRating = 5;
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: context.pageBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24.w,
                12.h,
                24.w,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: context.divColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.golden,
                      size: 42.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppStrings.rateLawyerTitle.tr(
                        context,
                        namedArgs: {'name': proposal.lawyerName},
                      ),
                      textAlign: TextAlign.center,
                      style: context.text.titleMedium?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.rateLawyerSubtitle.tr(context),
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        final isSelected = value <= selectedRating;
                        return IconButton(
                          onPressed: () {
                            setSheetState(() {
                              selectedRating = selectedRating == value
                                  ? 0
                                  : value;
                            });
                          },
                          icon: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.golden,
                            size: 34.sp,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 14.h),
                    TextField(
                      controller: commentController,
                      minLines: 3,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: AppStrings.ratingComment.tr(context),
                        hintText: AppStrings.ratingCommentHint.tr(context),
                        filled: true,
                        fillColor: context.cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: context.divColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: context.divColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: AppColors.golden,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    CustomButton(
                      isLoading: isSubmitting,
                      onPressed: () async {
                        if (isSubmitting) return;
                        setSheetState(() => isSubmitting = true);
                        final parentContext = context;

                        final error = await myOrdersCubit.rateProvider(
                          providerId: proposal.providerId,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        );

                        if (!sheetContext.mounted || !parentContext.mounted) {
                          return;
                        }
                        if (error != null) {
                          setSheetState(() => isSubmitting = false);
                          AppSnackbar.showError(sheetContext, message: error);
                          return;
                        }

                        Navigator.pop(sheetContext);
                        AppSnackbar.showSuccess(
                          parentContext,
                          messageKey: AppStrings.ratingSentSuccessfully,
                        );
                      },
                      text: AppStrings.submitRating.tr(context),
                      backgroundColor: AppColors.golden,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  Widget _buildProposalsSection(OrderDetailsData order) {
    final bool isCaseAcceptedOrClosed = order.isAcceptedOrActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 2.w, bottom: 7.h),
          child: Text(
            AppStrings.receivedProposals.tr(context),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              height: 1.1,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.proposals.length,
          separatorBuilder: (context, index) => SizedBox(height: 7.h),
          itemBuilder: (context, index) {
            final proposal = order.proposals[index];
            return ProposalCard(
              proposal: proposal,
              isSelected: _selectedProposalId == proposal.id,
              canAccept: !isCaseAcceptedOrClosed,
              onAccept: () {
                // Show confirmation logic
                setState(() => _selectedProposalId = proposal.id);
                _showAcceptProposalDialog(proposal);
              },
              onViewProfile: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.lawyerProfile,
                  arguments: proposal.lawyerId,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWaitingForProposalsCard(OrderDetailsData order) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDirectLawyer =
        order.selectionType == 'select' || order.lawyer != null;
    final lawyer = order.lawyer;

    final title = isDirectLawyer
        ? (order.statusText.isNotEmpty
              ? order.statusText
              : (isArabic
                    ? 'بانتظار قبول المحامي'
                    : "Waiting for Lawyer's Approval"))
        : (order.statusText.isNotEmpty
              ? order.statusText
              : AppStrings.waitingForProposals.tr(context));

    final subtitle = isDirectLawyer
        ? (isArabic
              ? (lawyer != null
                    ? 'تم إرسال طلبك بنجاح إلى المحامي (${lawyer.name}) وبانتظار مراجعته وقبول الطلب وتقديم عرض السعر.'
                    : 'تم إرسال طلبك إلى المحامي المحدد وبانتظار موافقته وتقديم عرض السعر.')
              : (lawyer != null
                    ? 'Your request has been sent to (${lawyer.name}) and is awaiting approval and quotation.'
                    : 'Your request has been sent to the selected lawyer and is awaiting approval.'))
        : AppStrings.waitingForProposalsSubtitle.tr(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.golden.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.golden.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.golden,
              size: 21.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary,
              height: 1.35,
              fontSize: 10.5.sp,
            ),
          ),
          if (isDirectLawyer && lawyer != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.golden.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child:
                        lawyer.photoUrl != null && lawyer.photoUrl!.isNotEmpty
                        ? CustomNetworkImage(
                            imageUrl: lawyer.photoUrl!,
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.golden.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.golden,
                                size: 20.sp,
                              ),
                            ),
                          )
                        : Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: AppColors.golden.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.golden,
                              size: 20.sp,
                            ),
                          ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lawyer.name,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lawyer.specialization != null &&
                            lawyer.specialization!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            lawyer.specialization!,
                            style: context.text.bodySmall?.copyWith(
                              color: context.textSecondary,
                              fontSize: 10.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.golden.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      isArabic ? 'المحامي المطلوب' : 'Requested',
                      style: context.text.labelSmall?.copyWith(
                        color: AppColors.golden,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcceptedLawyerCard(OrderDetailsData order) {
    final lawyer = order.lawyer;
    final acceptedProposal = order.acceptedProposal;
    final lawyerName = lawyer?.name.isNotEmpty == true
        ? lawyer!.name
        : (order.lawyerName.isNotEmpty ? order.lawyerName : 'المحامي');
    final lawyerPhoto = lawyer?.photoUrl ?? acceptedProposal?.lawyerPhoto;
    final lawyerId = lawyer?.id ?? order.lawyerId ?? acceptedProposal?.lawyerId;
    final specialization = lawyer?.specialization ?? lawyer?.providerType ?? '';
    final hasChat = order.hasChatRoom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 2.w, bottom: 7.h),
          child: Text(
            order.isConsultation
                ? (Localizations.localeOf(context).languageCode == 'ar'
                      ? 'محامي الاستشارة'
                      : 'Consultation Lawyer')
                : (Localizations.localeOf(context).languageCode == 'ar'
                      ? 'المحامي المعين للقضية'
                      : 'Assigned Lawyer'),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              height: 1.1,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: context.divColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: lawyerId != null
                        ? () => Navigator.pushNamed(
                            context,
                            AppRoutes.lawyerProfile,
                            arguments: lawyerId,
                          )
                        : null,
                    child: ClipOval(
                      child: lawyerPhoto != null && lawyerPhoto.isNotEmpty
                          ? CustomNetworkImage(
                              imageUrl: lawyerPhoto,
                              width: 52.w,
                              height: 52.w,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                width: 52.w,
                                height: 52.w,
                                decoration: BoxDecoration(
                                  color: AppColors.golden.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.golden,
                                  size: 26.sp,
                                ),
                              ),
                            )
                          : Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: AppColors.golden.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.golden,
                                size: 26.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lawyerName,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (specialization.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            specialization,
                            style: context.text.bodySmall?.copyWith(
                              color: context.textSecondary,
                              fontSize: 10.5.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            if (lawyer != null &&
                                lawyer.experienceYears > 0) ...[
                              Icon(
                                Icons.work_outline,
                                size: 12.sp,
                                color: context.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${lawyer.experienceYears} ${AppStrings.years.tr(context)}',
                                style: context.text.labelSmall?.copyWith(
                                  color: context.textSecondary,
                                  fontSize: 10.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                            ],
                            if (lawyer != null && lawyer.rating > 0) ...[
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.golden,
                                size: 14.sp,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                lawyer.rating.toStringAsFixed(1),
                                style: context.text.labelSmall?.copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (acceptedProposal != null ||
                  (!order.isConsultation &&
                      order.financials.totalPrice > 0)) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.golden.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.golden.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 16.sp,
                                color: AppColors.golden,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? 'قيمة العرض المعتمد:'
                                    : 'Accepted Offer:',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.textSecondary,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            AppStrings.priceWithCurrency.tr(
                              context,
                              namedArgs: {
                                'price':
                                    acceptedProposal?.price ??
                                    order.financials.totalPrice.toStringAsFixed(
                                      2,
                                    ),
                              },
                            ),
                            style: context.text.titleSmall?.copyWith(
                              color: AppColors.golden,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5.sp,
                            ),
                          ),
                        ],
                      ),
                      if (acceptedProposal?.description.isNotEmpty == true) ...[
                        SizedBox(height: 6.h),
                        Divider(
                          color: AppColors.golden.withValues(alpha: 0.15),
                          height: 1,
                        ),
                        SizedBox(height: 6.h),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            acceptedProposal!.description,
                            style: context.text.bodySmall?.copyWith(
                              color: context.textSecondary,
                              fontSize: 10.5.sp,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              Row(
                children: [
                  if (hasChat) ...[
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _openChat(order),
                          icon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            AppStrings.chat.tr(context),
                            style: context.text.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.golden,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (lawyerId != null) SizedBox(width: 8.w),
                  ],
                  if (lawyerId != null)
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.lawyerProfile,
                              arguments: lawyerId,
                            );
                          },
                          icon: Icon(
                            Icons.person_outline_rounded,
                            size: 16.sp,
                            color: context.textPrimary,
                          ),
                          label: Text(
                            'عرض الملف الشخصي',
                            style: context.text.labelMedium?.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5.sp,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.divColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAcceptProposalDialog(CaseProposal proposal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.payment_rounded,
                color: AppColors.golden,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'تأكيد القبول والمتابعة للدفع',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من قبول عرض ${proposal.lawyerName}؟',
              style: context.text.bodyMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.golden.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.proposalPrice.tr(context),
                    style: context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    AppStrings.priceWithCurrency.tr(
                      context,
                      namedArgs: {'price': proposal.price},
                    ),
                    style: context.text.titleSmall?.copyWith(
                      color: AppColors.golden,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'سيتم نقلك لصفحة الدفع الإلكتروني الآمن لاستكمال رسوم الخدمة والبدء في تنفيذ القضية.',
              style: context.text.bodySmall?.copyWith(
                color: context.textSecondary,
                fontSize: 10.5.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.divColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      AppStrings.cancel.tr(context),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Close dialog
                      _actionsCubit.acceptProposal(proposal.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.golden,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'تأكيد والدفع',
                      style: context.text.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelCaseDialog(int caseId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.confirm.tr(context)),
        content: Text(AppStrings.confirmCancelCase.tr(context)),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  isOutlined: true,
                  onPressed: () => Navigator.pop(dialogContext),
                  text: AppStrings.back.tr(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog
                    // Call the actual API for cancellation
                    _actionsCubit.cancelCase(caseId);
                  },
                  backgroundColor: AppColors.error,
                  textColor: Colors.white,
                  text: AppStrings.confirm.tr(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompleteOrderDialog(OrderDetailsData order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.pageBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          (order.isConsultation
                  ? AppStrings.completeConsultation
                  : AppStrings.completeService)
              .tr(context),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          (order.isConsultation
                  ? AppStrings.confirmCompleteConsultation
                  : AppStrings.confirmCompleteService)
              .tr(context),
          style: context.text.bodyMedium?.copyWith(
            color: context.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  isOutlined: true,
                  onPressed: () => Navigator.pop(dialogContext),
                  text: AppStrings.back.tr(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _actionsCubit.completeRecord(
                      recordId: order.id,
                      isConsultation: order.isConsultation,
                    );
                  },
                  backgroundColor: const Color(0xFF27AE60),
                  textColor: Colors.white,
                  text: AppStrings.confirm.tr(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentsSheet(int orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final actionCubit = _actionsCubit;
        final myOrdersCubit = context.read<MyOrdersCubit>();
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: actionCubit),
            BlocProvider.value(value: myOrdersCubit),
          ],
          child: BlocListener<LegalCaseActionsCubit, LegalCaseActionsState>(
            listener: (context, actionState) {
              if (actionState.successMessage != null &&
                  actionState.successMessage!.isNotEmpty &&
                  actionState.actionType == 'upload') {
                // Reload order details so newly uploaded files appear immediately in the sheet
                Future.delayed(const Duration(milliseconds: 300), () {
                  final sheetCubit = myOrdersCubit;
                  if (sheetCubit.isClosed) return;
                  sheetCubit.getOrderDetails(
                    orderId: orderId,
                    recordType: widget.recordType,
                  );
                });
              }
            },
            child: BlocBuilder<MyOrdersCubit, MyOrdersState>(
              builder: (context, state) {
                final order = context.read<MyOrdersCubit>().lastLoadedDetails;

                if (order == null && state is MyOrderDetailsLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (order == null) return const SizedBox();

                return Container(
                  decoration: BoxDecoration(
                    color: context.pageBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.attachedDocuments.tr(context),
                                style: context.text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (state is MyOrderDetailsLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (order.documents.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.folder_open_outlined,
                                      size: 48,
                                      color: context.textSecondary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppStrings.noDataFound.tr(context),
                                      style: context.text.bodyMedium?.copyWith(
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: order.documents.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) =>
                                    _buildDocumentCard(order.documents[index]),
                              ),
                            ),
                          const SizedBox(height: 24),
                          CustomButton(
                            onPressed: () {
                              _pickFilesAndUpload(order.id, actionCubit);
                            },
                            icon: Icons.add_circle_outline,
                            isLoading: context
                                .watch<LegalCaseActionsCubit>()
                                .state
                                .isLoading,
                            text: AppStrings.uploadDocuments.tr(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(CaseDocument doc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.divColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.golden.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.golden,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title.isNotEmpty ? doc.title : doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _openUrl(doc.url),
            icon: const Icon(Icons.download_for_offline_outlined, size: 22),
            color: AppColors.golden,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.golden.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppSnackbar.showError(context, messageKey: AppStrings.errorServer);
      }
    } else if (mounted) {
      AppSnackbar.showError(context, messageKey: AppStrings.errorServer);
    }
  }

  Future<void> _pickFilesAndUpload(
    int caseId,
    LegalCaseActionsCubit actionCubit,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final files = result.files
        .where((file) => file.path != null)
        .map((file) => File(file.path!))
        .toList();

    if (files.isEmpty) return;

    final titles = await _collectDocumentTitles(files);
    if (titles == null) return;

    await actionCubit.uploadDocuments(
      caseId: caseId,
      titles: titles,
      files: files,
    );
  }

  Future<List<String>?> _collectDocumentTitles(List<File> files) async {
    final controllers = files
        .map(
          (file) => TextEditingController(
            text: file.path.split(Platform.pathSeparator).last,
          ),
        )
        .toList();

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.pageBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.divColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.enterDocumentTitles.tr(context),
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.pleaseEnterDocumentTitles.tr(context),
                  style: context.text.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(files.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CustomTextField(
                      controller: controllers[index],
                      hintText:
                          '${AppStrings.documentTitle.tr(context)} ${index + 1}',
                      prefixIcon: const Icon(Icons.title_rounded, size: 20),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                CustomButton(
                  onPressed: () {
                    final titles = controllers
                        .map((c) => c.text.trim())
                        .toList();
                    if (titles.any((title) => title.isEmpty)) {
                      AppSnackbar.showError(
                        context,
                        messageKey: AppStrings.pleaseEnterDocumentTitles,
                      );
                      return;
                    }
                    Navigator.pop(context, titles);
                  },
                  text: AppStrings.saveChanges.tr(context),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  onPressed: () {
                    Navigator.pop(context); // Just close the sheet
                  },
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  text: AppStrings.cancel.tr(context),
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),
        );
      },
    );

    for (final controller in controllers) {
      controller.dispose();
    }

    return result;
  }
}
