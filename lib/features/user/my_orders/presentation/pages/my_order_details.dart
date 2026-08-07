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

class OrderDetailsView extends StatefulWidget {
  final int orderId;
  const OrderDetailsView({super.key, required this.orderId});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  int? _selectedProposalId;

  @override
  void initState() {
    super.initState();
    context.read<MyOrdersCubit>().getOrderDetails(orderId: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<LegalCaseActionsCubit>(),
      child: BlocListener<LegalCaseActionsCubit, LegalCaseActionsState>(
        listener: (context, actionState) {
          if (actionState.errorMessage != null &&
              actionState.errorMessage!.isNotEmpty) {
            AppSnackbar.showError(context, message: actionState.errorMessage);
            context.read<LegalCaseActionsCubit>().clearMessages();
          }
          if (actionState.successMessage != null &&
              actionState.successMessage!.isNotEmpty) {
            AppSnackbar.showSuccess(
              context,
              message: actionState.successMessage,
            );
            final type = actionState.actionType;
            if (type == 'cancel') {
              context.read<LegalCaseActionsCubit>().clearMessages();
              Navigator.of(
                context,
              ).pop({'cancelled': true, 'orderId': widget.orderId});
            } else {
              context.read<LegalCaseActionsCubit>().clearMessages();
              // For uploads and other actions, reload details immediately
              final cubit = context.read<MyOrdersCubit>();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  cubit.getOrderDetails(orderId: widget.orderId);
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
                      : AppStrings.consultationDetails.tr(context))
                : AppStrings.consultationDetails.tr(context);
            return Scaffold(
              backgroundColor: context.pageBg,
              appBar: MainAppbar(title: title),
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
                    final ratableProposal = order.ratableProposal;
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
                          ),
                          const SizedBox(height: 20),
                          if (order.proposals.isNotEmpty) ...[
                            _buildProposalsSection(order),
                            const SizedBox(height: 20),
                          ],
                          if (order.canRateLawyer &&
                              ratableProposal != null) ...[
                            _buildRateLawyerCard(ratableProposal),
                            const SizedBox(height: 20),
                          ],
                          OrderReceiptSection(order: order),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            );
          },
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
                    fontSize: 14.sp,
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
                        fontSize: 17.sp,
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
        Text(
          AppStrings.receivedProposals.tr(context),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.proposals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
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

  void _showAcceptProposalDialog(CaseProposal proposal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.pageBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppStrings.confirm.tr(context),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppStrings.confirmAcceptProposal.tr(
            context,
            namedArgs: {'name': proposal.lawyerName},
          ),
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
                  text: AppStrings.cancel.tr(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog
                    // Call the actual API
                    context.read<LegalCaseActionsCubit>().acceptProposal(
                      proposal.id,
                    );
                  },
                  backgroundColor: AppColors.golden,
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
                    context.read<LegalCaseActionsCubit>().cancelCase(caseId);
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

  void _showDocumentsSheet(int orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final actionCubit = context.read<LegalCaseActionsCubit>();
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
                  sheetCubit.getOrderDetails(orderId: orderId);
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
