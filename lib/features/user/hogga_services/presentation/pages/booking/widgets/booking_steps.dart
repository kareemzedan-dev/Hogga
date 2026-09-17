import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/features/user/hogga_services/data/models/legal_case_models.dart';
import 'package:hogga/features/user/hogga_services/domain/models/service_required_input.dart';
import 'booking_components.dart';

class RequestDetailsStep extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final bool showInfoDialog;
  final VoidCallback onInfoDialogDismissed;
  final VoidCallback onNext;
  final String subCategoryName;
  final String childCategoryName;
  final String? itemName;
  final bool canAttendRemotely;
  final ValueChanged<bool>? onRemoteAttendanceChanged;
  final TextEditingController? governorateController;
  final TextEditingController? cityController;
  final int? duration;
  final bool isCallType;
  final List<ServiceRequiredInput> requiredInputs;
  final Map<String, String> metadataValues;
  final void Function(String slug, String value)? onMetadataChanged;

  const RequestDetailsStep({
    super.key,
    required this.titleController,
    required this.detailsController,
    required this.showInfoDialog,
    required this.onInfoDialogDismissed,
    required this.onNext,
    required this.subCategoryName,
    required this.childCategoryName,
    this.itemName,
    this.canAttendRemotely = false,
    this.onRemoteAttendanceChanged,
    this.governorateController,
    this.cityController,
    this.duration,
    this.isCallType = false,
    this.requiredInputs = const [],
    this.metadataValues = const {},
    this.onMetadataChanged,
  });

  @override
  State<RequestDetailsStep> createState() => _RequestDetailsStepState();
}

class _RequestDetailsStepState extends State<RequestDetailsStep> {
  final Map<String, TextEditingController> _metadataControllers = {};

  @override
  void initState() {
    super.initState();
    _syncMetadataControllers();
    if (widget.showInfoDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showDisclaimer();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant RequestDetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMetadataControllers();
  }

  @override
  void dispose() {
    for (final controller in _metadataControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncMetadataControllers() {
    final slugs = widget.requiredInputs.map((input) => input.slug).toSet();
    final staleSlugs = _metadataControllers.keys
        .where((slug) => !slugs.contains(slug))
        .toList();
    for (final slug in staleSlugs) {
      _metadataControllers.remove(slug)?.dispose();
    }

    for (final input in widget.requiredInputs) {
      _metadataControllers.putIfAbsent(
        input.slug,
        () => TextEditingController(
          text: widget.metadataValues[input.slug] ?? '',
        ),
      );
    }
  }

  bool _areRequiredInputsValid() {
    return widget.requiredInputs.every((input) {
      if (!input.isRequired) return true;
      return (widget.metadataValues[input.slug]?.trim().isNotEmpty ?? false);
    });
  }

  void _showDisclaimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              Icons.info_outline,
              size: 56,
              color: Theme.of(context).primaryColor,
            ),
            AppSizes.h(16),
            Text(
              AppStrings.infoDialogHeading.tr(context),
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSizes.h(12),
            Text(
              AppStrings.infoDialogBody.tr(context),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(height: 1.5),
            ),
            AppSizes.h(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onInfoDialogDismissed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.golden,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.infoDialogConfirm.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            AppSizes.h(16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isValid =
        widget.titleController.text.trim().isNotEmpty &&
        widget.detailsController.text.trim().isNotEmpty &&
        _areRequiredInputsValid();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service breadcrumb
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.chipBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 14,
                        color: context.colors.primary,
                      ),
                      AppSizes.w(6),
                      Expanded(
                        child: Text(
                          '${widget.subCategoryName}  ›  ${widget.childCategoryName}${widget.itemName != null ? '  ›  ${widget.itemName}' : ''}',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: context.textSecondary,
                            fontFamily: 'Rubik',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isCallType && widget.duration != null) ...[
                  AppSizes.h(12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Color(0xFF27AE60),
                        ),
                        AppSizes.w(6),
                        Text(
                          '${widget.duration} ${AppStrings.minutesLabel.tr(context)}',
                          style: context.text.labelMedium?.copyWith(
                            color: const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Divider(
                  color: AppColors.golden.withValues(alpha: 0.2),
                  thickness: 1,
                  height: 24,
                ),

                BookingFieldLabel(AppStrings.requestTitle.tr(context)),
                AppSizes.h(8),
                CustomTextField(
                  controller: widget.titleController,
                  hintText: '* ${AppStrings.requestTitleHint.tr(context)}',
                  onChanged: (_) => setState(() {}),
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.requestDetails.tr(context)),
                AppSizes.h(8),
                CustomTextField(
                  controller: widget.detailsController,
                  hintText: '* ${AppStrings.requestDetailsHint.tr(context)}',
                  maxLines: 6,
                  onChanged: (_) => setState(() {}),
                ),
                AppSizes.h(20),
                if (widget.requiredInputs.isNotEmpty) ...[
                  BookingFieldLabel(AppStrings.additionalDataTitle.tr(context)),
                  AppSizes.h(12),
                  ...widget.requiredInputs.map(_buildMetadataField),
                  AppSizes.h(4),
                ],
              ],
            ),
          ),
        ),
        BookingBottomButton(
          label: AppStrings.nextStep.tr(context),
          onPressed: isValid ? widget.onNext : null,
        ),
      ],
    );
  }

  Widget _buildMetadataField(ServiceRequiredInput input) {
    final controller = _metadataControllers[input.slug]!;
    final label = input.isRequired ? '* ${input.label}' : input.label;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingFieldLabel(label),
          AppSizes.h(8),
          CustomTextField(
            controller: controller,
            hintText: input.label,
            readOnly: input.isDate,
            maxLines: input.isLongText ? 4 : 1,
            keyboardType: input.isNumber
                ? TextInputType.number
                : TextInputType.text,
            suffixIcon: input.isDate
                ? const Icon(Icons.calendar_today_outlined, size: 18)
                : null,
            onTap: input.isDate ? () => _pickMetadataDate(input) : null,
            onChanged: (value) {
              widget.onMetadataChanged?.call(input.slug, value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickMetadataDate(ServiceRequiredInput input) async {
    final currentValue = widget.metadataValues[input.slug];
    final initialDate = DateTime.tryParse(currentValue ?? '') ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;

    final value = _formatDate(selected);
    final controller = _metadataControllers[input.slug];
    controller?.text = value;
    widget.onMetadataChanged?.call(input.slug, value);
    setState(() {});
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class LawyerModeStep extends StatelessWidget {
  final int? lawyerMode;
  final int selectedLawyersCount;
  final double servicePrice;
  final String currency;
  final bool isProviderFlow;
  final Function(int) onModeChanged;
  final VoidCallback onBrowseLawyers;
  final VoidCallback? onNext;

  const LawyerModeStep({
    super.key,
    required this.lawyerMode,
    required this.selectedLawyersCount,
    required this.servicePrice,
    required this.currency,
    required this.isProviderFlow,
    required this.onModeChanged,
    required this.onBrowseLawyers,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.golden.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.golden.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${AppStrings.stepPlatformFees.tr(context)}: ${servicePrice.toStringAsFixed(2)} $currency',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.golden,
                            size: 18,
                          ),
                        ],
                      ),
                      AppSizes.h(8),
                      Text(
                        AppStrings.lawyersReadyDesc.tr(context),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildModeCard(
                  context,
                  index: 0,
                  title: AppStrings.broadcastToAll.tr(context),
                  desc: AppStrings.broadcastDesc.tr(context),
                  icon: Icons.record_voice_over_outlined,
                ),
                AppSizes.h(16),
                _buildModeCard(
                  context,
                  index: 1,
                  title: AppStrings.chooseLawyerManually.tr(context),
                  desc: AppStrings.manualChooseDesc.tr(context),
                  icon: Icons.person_search_outlined,
                  extra: lawyerMode == 1
                      ? Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.golden.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedLawyersCount > 0
                                ? '${AppStrings.selected.tr(context)} ($selectedLawyersCount)'
                                : AppStrings.browseLawyers.tr(context),
                            style: const TextStyle(
                              color: AppColors.golden,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        BookingBottomButton(
          label: AppStrings.nextStep.tr(context),
          onPressed: onNext,
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required int index,
    required String title,
    required String desc,
    required IconData icon,
    Widget? extra,
  }) {
    final isSelected = lawyerMode == index;
    return GestureDetector(
      onTap: () => onModeChanged(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.golden : context.divColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.chipBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.golden : context.textSecondary,
              ),
            ),
            AppSizes.w(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                  AppSizes.h(4),
                  Text(
                    desc,
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                      fontSize: 10.sp,
                    ),
                  ),
                  if (extra != null) extra,
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.golden),
          ],
        ),
      ),
    );
  }
}

class PaymentStep extends StatelessWidget {
  final TextEditingController promoController;
  final int paymentMethod;
  final bool isApplyingCoupon;
  final CouponData? coupon;
  final VoidCallback onApplyCoupon;
  final VoidCallback? onClearCoupon;
  final Function(int) onPaymentMethodChanged;
  final double servicePrice;
  final double discount;
  final double tax;
  final double total;
  final bool isSubmitting;
  final VoidCallback onComplete;
  final String serviceName;

  const PaymentStep({
    super.key,
    required this.promoController,
    required this.paymentMethod,
    required this.isApplyingCoupon,
    this.coupon,
    required this.onApplyCoupon,
    this.onClearCoupon,
    required this.onPaymentMethodChanged,
    required this.servicePrice,
    required this.discount,
    required this.tax,
    required this.total,
    required this.isSubmitting,
    required this.onComplete,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact service info card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.golden.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.golden.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.golden,
                        size: 16,
                      ),
                      AppSizes.w(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.serviceNameLabel.tr(context),
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: context.textSecondary,
                                fontFamily: 'Rubik',
                              ),
                            ),
                            Text(
                              serviceName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Rubik',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      AppSizes.w(8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.security,
                            color: Colors.green,
                            size: 12,
                          ),
                          AppSizes.w(3),
                          Text(
                            AppStrings.securePayment.tr(context),
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.green,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.paymentMethod.tr(context)),
                AppSizes.h(10),
                _buildPaymentOption(
                  context,
                  index: 0,
                  title: AppStrings.payByCard.tr(context),
                  icon: Icons.credit_card,
                ),
                AppSizes.h(24),
                BookingFieldLabel(AppStrings.promoCode.tr(context)),
                AppSizes.h(10),
                if (coupon != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF27AE60),
                            size: 16,
                          ),
                        ),
                        AppSizes.w(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStrings.couponApplied.tr(context)} (${coupon!.code})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF27AE60),
                                ),
                              ),
                              if (discount > 0) ...[
                                AppSizes.h(2),
                                Text(
                                  '${AppStrings.discount.tr(context)}: -${discount.toStringAsFixed(2)} ${AppStrings.currencySymbol.tr(context)}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (onClearCoupon != null)
                          IconButton(
                            onPressed: onClearCoupon,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: promoController,
                          hintText: AppStrings.enterPromoCode.tr(context),
                          prefixIcon: Icon(
                            Icons.local_offer_outlined,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      AppSizes.w(10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isApplyingCoupon ? null : onApplyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.golden,
                            disabledBackgroundColor:
                                AppColors.golden.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isApplyingCoupon
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  AppStrings.apply.tr(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                AppSizes.h(24),
                Divider(
                  color: AppColors.golden.withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                AppSizes.h(16),
                SummaryRow(
                  label: AppStrings.stepPlatformFees.tr(context),
                  value: servicePrice,
                ),
                if (discount > 0)
                  SummaryRow(
                    label: AppStrings.discount.tr(context),
                    value: -discount,
                    isDiscount: true,
                  ),
                if (tax > 0)
                  SummaryRow(label: AppStrings.tax.tr(context), value: tax),
                AppSizes.h(8),
                Divider(
                  color: AppColors.golden.withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                AppSizes.h(8),
                SummaryRow(
                  label: AppStrings.total.tr(context),
                  value: total,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        BookingBottomButton(
          label: AppStrings.confirmAndPay.tr(context),
          isLoading: isSubmitting,
          onPressed: onComplete,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = paymentMethod == index;
    return GestureDetector(
      onTap: () => onPaymentMethodChanged(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.golden : context.divColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.golden : context.textSecondary,
            ),
            AppSizes.w(16),
            Text(
              title,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.golden, size: 20),
          ],
        ),
      ),
    );
  }
}

class PlatformFeeStep extends StatelessWidget {
  final VoidCallback onNext;
  final double serviceFee;

  const PlatformFeeStep({
    super.key,
    required this.onNext,
    this.serviceFee = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.golden.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: AppColors.golden,
                    ),
                  ),
                ),
                AppSizes.h(32),
                Text(
                  AppStrings.serviceFee.tr(context),
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                AppSizes.h(16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.serviceFeeDesc.tr(context),
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSizes.w(16),
                      Text(
                        '$serviceFee ${AppStrings.omr.tr(context)}',
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.golden,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        BookingBottomButton(
          label: AppStrings.nextStep.tr(context),
          onPressed: onNext,
        ),
      ],
    );
  }
}
