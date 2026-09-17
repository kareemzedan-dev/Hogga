import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_avatar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/features/user/hogga_services/data/models/legal_case_models.dart';
import 'package:hogga/features/user/hogga_services/data/repositories/hogga_repository.dart';
import 'package:hogga/features/user/hogga_services/domain/models/booking_flow_args.dart';
import 'package:hogga/features/user/hogga_services/presentation/pages/booking/widgets/booking_components.dart';
import 'package:hogga/injection_container.dart' as di;

class ConsultationBookingFlowScreen extends StatefulWidget {
  final BookingFlowArgs args;

  const ConsultationBookingFlowScreen({super.key, required this.args});

  @override
  State<ConsultationBookingFlowScreen> createState() =>
      _ConsultationBookingFlowScreenState();
}

class _ConsultationBookingFlowScreenState
    extends State<ConsultationBookingFlowScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _promoController = TextEditingController();
  late final HoggaRepository _repository;

  int _currentStep = 0;
  bool _isLoadingLawyers = true;
  bool _isLoadingPrices = false;
  bool _isSubmitting = false;
  bool _isApplyingCoupon = false;
  String? _error;
  String? _activeCouponCode;
  List<ConsultationLawyerModel> _lawyers = const [];
  List<ConsultationPriceModel> _prices = const [];
  ConsultationLawyerModel? _selectedLawyer;
  ConsultationPriceModel? _selectedPrice;
  DateTime? _scheduledAt;

  String get _paymentMethodValue => 'card';
  int get _categorySubId =>
      (widget.args.subCategoryId != null && widget.args.subCategoryId! > 0)
          ? widget.args.subCategoryId!
          : widget.args.childCategoryId;
  bool get _requiresSchedule {
    if (_categorySubId == 2) {
      return true;
    }

    final consultationType = widget.args.consultationType?.toLowerCase().trim();
    if (consultationType == 'scheduled' ||
        consultationType == 'schedule' ||
        consultationType == 'audio_video_scheduled') {
      return true;
    }

    final values = [
      widget.args.consultationType,
      widget.args.serviceType,
      widget.args.parentServiceType,
      widget.args.sectionName,
      widget.args.subCategoryName,
      widget.args.childCategoryName,
      widget.args.itemName,
    ].whereType<String>().join(' ').toLowerCase();

    return values.contains('scheduled') ||
        values.contains('schedule') ||
        values.contains('\u0645\u062c\u062f\u0648\u0644');
  }

  @override
  void initState() {
    super.initState();
    _repository = di.sl<HoggaRepository>();
    _loadLawyers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _detailsController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadLawyers({String? coupon}) async {
    setState(() {
      _isLoadingLawyers = true;
      _error = null;
    });

    final result = await _repository.getConsultationLawyers(
      _categorySubId,
      coupon: coupon,
    );
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoadingLawyers = false;
        _error = failure.message;
      }),
      (lawyers) => setState(() {
        _isLoadingLawyers = false;
        _lawyers = lawyers;
        final updatedSelected = _findLawyerById(lawyers, _selectedLawyer?.id);
        if (_selectedLawyer != null && updatedSelected == null) {
          _selectedLawyer = null;
          _selectedPrice = null;
          _prices = const [];
        } else if (updatedSelected != null) {
          _selectedLawyer = updatedSelected;
          if (updatedSelected.prices.isNotEmpty) {
            _prices = updatedSelected.prices;
            _selectedPrice = _findPriceById(_prices, _selectedPrice?.id);
          }
        }
      }),
    );
  }

  Future<void> _applyCouponFilter() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _activeCouponCode = null;
        _selectedLawyer = null;
        _selectedPrice = null;
        _prices = const [];
      });
      await _loadLawyers();
      return;
    }

    setState(() => _isApplyingCoupon = true);
    final result = await _repository.getConsultationLawyers(
      _categorySubId,
      coupon: code,
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isApplyingCoupon = false);
        AppSnackbar.showError(context, message: failure.message);
      },
      (visibleLawyers) {
        final updatedSelected = _findLawyerById(
          visibleLawyers,
          _selectedLawyer?.id,
        );

        setState(() {
          _isApplyingCoupon = false;
          _activeCouponCode = code;
          _lawyers = visibleLawyers;
          if (_selectedLawyer != null && updatedSelected == null) {
            _selectedLawyer = null;
            _selectedPrice = null;
            _prices = const [];
          } else if (updatedSelected != null) {
            _selectedLawyer = updatedSelected;
            if (updatedSelected.prices.isNotEmpty) {
              _prices = updatedSelected.prices;
              _selectedPrice =
                  _findPriceById(_prices, _selectedPrice?.id) ??
                  (_prices.length == 1 ? _prices.first : null);
            }
          }
        });

        AppSnackbar.showSuccess(
          context,
          message: AppStrings.couponApplied.tr(
            context,
            namedArgs: {'code': code},
          ),
        );
      },
    );
  }

  Future<void> _selectLawyer(ConsultationLawyerModel lawyer) async {
    final initialPrices = lawyer.prices;
    setState(() {
      _selectedLawyer = lawyer;
      _prices = initialPrices;
      _selectedPrice = initialPrices.isNotEmpty ? initialPrices.first : null;
      _isLoadingPrices = initialPrices.isEmpty;
    });

    final result = await _repository.getConsultationLawyerPrices(
      lawyerId: lawyer.id,
      categorySubId: _categorySubId,
    );
    if (!mounted) return;
    if (_selectedLawyer?.id != lawyer.id) return;

    result.fold(
      (failure) {
        setState(() => _isLoadingPrices = false);
        if (initialPrices.isEmpty) {
          AppSnackbar.showError(context, message: failure.message);
        }
      },
      (prices) => setState(() {
        _isLoadingPrices = false;
        _prices = prices.isNotEmpty ? prices : lawyer.prices;
        _selectedPrice =
            _findPriceById(_prices, _selectedPrice?.id) ??
            (_prices.isNotEmpty ? _prices.first : null);
      }),
    );
  }

  ConsultationLawyerModel? _findLawyerById(
    List<ConsultationLawyerModel> lawyers,
    int? id,
  ) {
    if (id == null) return null;
    for (final lawyer in lawyers) {
      if (lawyer.id == id) return lawyer;
    }
    return null;
  }

  ConsultationPriceModel? _findPriceById(
    List<ConsultationPriceModel> prices,
    int? id,
  ) {
    if (id == null) return null;
    for (final price in prices) {
      if (price.id == id) return price;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_validateDetailsStep() || !_validateLawyerStep()) return;

    setState(() => _isSubmitting = true);
    final request = BookConsultationRequest(
      categorySubId: _categorySubId,
      categoriesItemId: widget.args.itemCategoryId,
      providerId: _selectedLawyer!.id,
      priceId: _selectedPrice!.id,
      title: _titleController.text.trim(),
      description: _detailsController.text.trim(),
      scheduledAt: _scheduledAt == null
          ? null
          : _formatBackendDateTime(_scheduledAt!),
      couponCode: _promoController.text.trim().isEmpty
          ? null
          : _promoController.text.trim(),
      paymentMethod: _paymentMethodValue,
    );

    final result = await _repository.bookConsultation(request);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => AppSnackbar.showError(context, message: failure.message),
      (response) {
        if (!response.status) {
          AppSnackbar.showError(context, message: response.message);
          return;
        }

        final paymentUrl = response.paymentUrl;
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.paymentWebView,
            arguments: {
              'paymentUrl': paymentUrl,
              'caseNumber': response.caseNumber ?? '',
              'caseId': response.caseId,
              'recordType': 'consultation',
            },
          );
          return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.orderConfirmed,
          (route) => false,
          arguments: {
            'caseNumber': response.caseNumber ?? '',
            'caseId': response.caseId,
            'recordType': 'consultation',
          },
        );
      },
    );
  }

  bool _validateDetailsStep() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _validateLawyerStep() {
    if (_selectedLawyer == null) {
      AppSnackbar.showError(
        context,
        messageKey: AppStrings.pleaseSelectAtLeastOneLawyer,
      );
      return false;
    }
    if (_selectedPrice == null) {
      AppSnackbar.showError(context, messageKey: AppStrings.requiredField);
      return false;
    }
    if (_requiresSchedule && _scheduledAt == null) {
      AppSnackbar.showError(
        context,
        messageKey: AppStrings.pleaseSelectExecutionDate,
      );
      return false;
    }
    return true;
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _nextFromDetails() {
    if (_validateDetailsStep()) _goToStep(1);
  }

  void _nextFromLawyer() {
    if (_validateLawyerStep()) _goToStep(2);
  }

  void _handleBack() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    _goToStep(_currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.args.sectionName.isNotEmpty
        ? widget.args.sectionName
        : (widget.args.itemName.isNotEmpty
              ? widget.args.itemName
              : AppStrings.consultation.tr(context));

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: appBarTitle,
        onBack: _handleBack,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: BookingStepProgressBar(
            currentStep: _currentStep,
            steps: [
              AppStrings.stepSendRequest,
              AppStrings.stepChooseLawyer,
              AppStrings.stepPayment,
            ],
          ),
        ),
      ),
      body: _isLoadingLawyers
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _loadLawyers)
          : Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (step) => setState(() => _currentStep = step),
                children: [
                  _ConsultationStepScaffold(
                    buttonText: AppStrings.nextStep.tr(context),
                    onNext: _nextFromDetails,
                    child: _RequestDetailsCard(
                      titleController: _titleController,
                      detailsController: _detailsController,
                      subCategoryName: widget.args.subCategoryName,
                      childCategoryName: widget.args.childCategoryName,
                      itemName: widget.args.itemName,
                      duration: widget.args.duration,
                      isCallType: widget.args.isCallType,
                    ),
                  ),
                  _ConsultationStepScaffold(
                    buttonText: AppStrings.nextStep.tr(context),
                    onNext: _nextFromLawyer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CouponFilterCard(
                          controller: _promoController,
                          isApplying: _isApplyingCoupon,
                          activeCouponCode: _activeCouponCode,
                          onApply: _applyCouponFilter,
                        ),
                        AppSizes.h(16),
                        _LawyersCard(
                          lawyers: _lawyers,
                          selectedLawyer: _selectedLawyer,
                          onSelect: _selectLawyer,
                          prices: _prices,
                          selectedPrice: _selectedPrice,
                          isLoadingPrices: _isLoadingPrices,
                          onSelectPrice: (price) => setState(() {
                            _selectedPrice = price;
                          }),
                        ),
                        if (_requiresSchedule) ...[
                          AppSizes.h(16),
                          _ScheduleCard(
                            value: _scheduledAt,
                            onTap: _pickScheduledAt,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _ConsultationStepScaffold(
                    buttonText: AppStrings.confirmAndPay.tr(context),
                    isLoading: _isSubmitting,
                    onNext: _submit,
                    child: _PaymentCard(
                      activeCouponCode: _activeCouponCode,
                      total: _selectedPrice?.price ?? 0,
                      selectedLawyer: _selectedLawyer,
                      selectedPrice: _selectedPrice,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickScheduledAt() async {
    final now = DateTime.now();
    final initial = _scheduledAt ?? now.add(const Duration(hours: 1));
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (selectedTime == null || !mounted) return;

    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (selected.isBefore(now)) {
      AppSnackbar.showError(
        context,
        messageKey: AppStrings.pleaseSelectExecutionDate,
      );
      return;
    }

    setState(() => _scheduledAt = selected);
  }

  String _formatBackendDateTime(DateTime value) {
    String two(int part) => part.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}:00';
  }
}

class _ConsultationStepScaffold extends StatelessWidget {
  final Widget child;
  final String buttonText;
  final VoidCallback onNext;
  final bool isLoading;

  const _ConsultationStepScaffold({
    required this.child,
    required this.buttonText,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: child,
          ),
        ),
        BookingBottomButton(
          label: buttonText,
          onPressed: onNext,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _CouponFilterCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplying;
  final String? activeCouponCode;
  final VoidCallback onApply;

  const _CouponFilterCard({
    required this.controller,
    required this.isApplying,
    required this.activeCouponCode,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: AppStrings.promoCode.tr(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: AppStrings.enterPromoCode.tr(context),
                  controller: controller,
                  prefixIcon: Icon(
                    Icons.local_offer_outlined,
                    size: 18.sp,
                    color: context.textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 9.h,
                  ),
                ),
              ),
              AppSizes.w(8),
              ElevatedButton(
                onPressed: isApplying ? null : onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.golden,
                  disabledBackgroundColor: AppColors.golden.withValues(
                    alpha: 0.55,
                  ),
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: 13.w,
                    vertical: 11.h,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: isApplying
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cream,
                        ),
                      )
                    : Text(
                        AppStrings.apply.tr(context),
                        style: TextStyle(
                          color: AppColors.cream,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5.sp,
                        ),
                      ),
              ),
            ],
          ),
          if (activeCouponCode != null) ...[
            AppSizes.h(8),
            Text(
              AppStrings.couponApplied.tr(
                context,
                namedArgs: {'code': activeCouponCode!},
              ),
              style: context.text.labelSmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestDetailsCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final String subCategoryName;
  final String childCategoryName;
  final String itemName;
  final int? duration;
  final bool isCallType;

  const _RequestDetailsCard({
    required this.titleController,
    required this.detailsController,
    required this.subCategoryName,
    required this.childCategoryName,
    required this.itemName,
    this.duration,
    this.isCallType = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Breadcrumb
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: context.chipBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 14.sp,
                color: context.colors.primary,
              ),
              AppSizes.w(6),
              Expanded(
                child: Text(
                  '$subCategoryName  ›  $childCategoryName${itemName.isNotEmpty ? '  ›  $itemName' : ''}',
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
        if (isCallType && duration != null) ...[
          AppSizes.h(12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
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
                  '$duration ${AppStrings.minutesLabel.tr(context)}',
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
          height: 24.h,
        ),
        BookingFieldLabel(AppStrings.requestTitle.tr(context)),
        AppSizes.h(8),
        CustomTextField(
          controller: titleController,
          hintText: '* ${AppStrings.requestTitleHint.tr(context)}',
          prefixIcon: const Icon(Icons.title_outlined),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? AppStrings.requiredField.tr(context)
              : null,
        ),
        AppSizes.h(20),
        BookingFieldLabel(AppStrings.requestDetails.tr(context)),
        AppSizes.h(8),
        CustomTextField(
          controller: detailsController,
          hintText: '* ${AppStrings.requestDetailsHint.tr(context)}',
          maxLines: 5,
          prefixIcon: const Icon(Icons.description_outlined),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? AppStrings.requiredField.tr(context)
              : null,
        ),
      ],
    );
  }
}

class _LawyersCard extends StatelessWidget {
  final List<ConsultationLawyerModel> lawyers;
  final ConsultationLawyerModel? selectedLawyer;
  final ValueChanged<ConsultationLawyerModel> onSelect;
  final List<ConsultationPriceModel> prices;
  final ConsultationPriceModel? selectedPrice;
  final bool isLoadingPrices;
  final ValueChanged<ConsultationPriceModel> onSelectPrice;

  const _LawyersCard({
    required this.lawyers,
    required this.selectedLawyer,
    required this.onSelect,
    required this.prices,
    required this.selectedPrice,
    required this.isLoadingPrices,
    required this.onSelectPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (lawyers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.divColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 40.sp,
              color: context.textSecondary,
            ),
            AppSizes.h(8),
            Text(
              AppStrings.noDataFound.tr(context),
              style: context.text.bodySmall?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.availableLawyers.tr(context),
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
                fontFamily: 'Rubik',
              ),
            ),
            Text(
              '${lawyers.length}',
              style: TextStyle(
                fontSize: 10.sp,
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
        AppSizes.h(12),
        ...lawyers.map((lawyer) {
          final isSelected = selectedLawyer?.id == lawyer.id;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _LawyerTile(
              lawyer: lawyer,
              isSelected: isSelected,
              onTap: () => onSelect(lawyer),
              prices: isSelected ? prices : const [],
              selectedPrice: isSelected ? selectedPrice : null,
              isLoadingPrices: isSelected && isLoadingPrices,
              onSelectPrice: onSelectPrice,
            ),
          );
        }),
      ],
    );
  }
}

class _LawyerTile extends StatelessWidget {
  final ConsultationLawyerModel lawyer;
  final bool isSelected;
  final VoidCallback onTap;
  final List<ConsultationPriceModel> prices;
  final ConsultationPriceModel? selectedPrice;
  final bool isLoadingPrices;
  final ValueChanged<ConsultationPriceModel> onSelectPrice;

  const _LawyerTile({
    required this.lawyer,
    required this.isSelected,
    required this.onTap,
    required this.prices,
    required this.selectedPrice,
    required this.isLoadingPrices,
    required this.onSelectPrice,
  });

  @override
  Widget build(BuildContext context) {
    final ratingText = lawyer.rating?.toStringAsFixed(1);
    final pricePreview = lawyer.prices.isEmpty ? null : lawyer.prices.first;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.golden : context.divColor,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.golden.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleImageWithBorder(
                      width: 46.w,
                      height: 46.w,
                      imageUrl: _cleanPhotoUrl(lawyer.photo),
                      borderWidth: 1.5,
                      borderColor: isSelected ? AppColors.golden : null,
                    ),
                    if (lawyer.isOnline)
                      PositionedDirectional(
                        end: 0,
                        bottom: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.cardBg, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                AppSizes.w(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lawyer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5.sp,
                              ),
                            ),
                          ),
                          if (lawyer.isVerified) ...[
                            AppSizes.w(4),
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.golden,
                              size: 16.sp,
                            ),
                          ],
                        ],
                      ),
                      AppSizes.h(6),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: [
                          if (lawyer.city.isNotEmpty) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12.sp,
                                  color: context.textSecondary,
                                ),
                                AppSizes.w(2),
                                Text(
                                  lawyer.city,
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.textSecondary,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (ratingText != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.golden.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ratingText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.sp,
                                      color: AppColors.golden,
                                    ),
                                  ),
                                  AppSizes.w(2),
                                  Icon(
                                    Icons.star_rounded,
                                    color: AppColors.golden,
                                    size: 11.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (lawyer.experienceYears > 0) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 12.sp,
                                  color: context.textSecondary,
                                ),
                                AppSizes.w(2),
                                Text(
                                  '${lawyer.experienceYears} ${AppStrings.yearsExperience.tr(context)}',
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.textSecondary,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                AppSizes.w(8),
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.golden : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.golden : context.divColor,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: AppColors.cream, size: 14.sp)
                      : null,
                ),
              ],
            ),
            if (lawyer.level != null ||
                lawyer.isOnline ||
                (!isSelected && pricePreview != null)) ...[
              AppSizes.h(10),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  if (lawyer.isOnline)
                    _LawyerBadge(
                      icon: Icons.circle,
                      text: AppStrings.availableNow.tr(context),
                      color: Colors.green,
                    ),
                  if (lawyer.level != null)
                    _LawyerBadge(
                      icon: Icons.workspace_premium_outlined,
                      text: lawyer.level!,
                      color: AppColors.golden,
                    ),
                  if (!isSelected && pricePreview != null)
                    _LawyerBadge(
                      icon: Icons.payments_outlined,
                      text:
                          '${pricePreview.price.toStringAsFixed(2)} ${AppStrings.currency.tr(context)} / ${pricePreview.duration} ${AppStrings.minutesLabel.tr(context)}',
                      color: AppColors.golden,
                    ),
                ],
              ),
            ],
            if (isSelected) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(
                  color: context.divColor,
                  height: 1,
                  thickness: 1,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 15.sp,
                    color: AppColors.golden,
                  ),
                  AppSizes.w(6),
                  Text(
                    AppStrings.servicesAndPrices.tr(context),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ],
              ),
              AppSizes.h(10),
              if (isLoadingPrices)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.golden,
                      ),
                    ),
                  ),
                )
              else if (prices.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    AppStrings.noDataFound.tr(context),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: context.textSecondary,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: prices.map((price) {
                    final isPriceSelected = selectedPrice?.id == price.id;
                    return InkWell(
                      onTap: () => onSelectPrice(price),
                      borderRadius: BorderRadius.circular(10.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: isPriceSelected
                              ? AppColors.golden.withValues(alpha: 0.12)
                              : context.chipBg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isPriceSelected
                                ? AppColors.golden
                                : context.divColor,
                            width: isPriceSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPriceSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 14.sp,
                              color: isPriceSelected
                                  ? AppColors.golden
                                  : context.textSecondary,
                            ),
                            AppSizes.w(6),
                            Text(
                              '${price.duration} ${AppStrings.minutesLabel.tr(context)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: isPriceSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isPriceSelected
                                    ? AppColors.golden
                                    : context.textPrimary,
                                fontFamily: 'Rubik',
                              ),
                            ),
                            AppSizes.w(8),
                            Container(
                              height: 12.h,
                              width: 1,
                              color: context.divColor,
                            ),
                            AppSizes.w(8),
                            Text(
                              '${price.price.toStringAsFixed(2)} ${AppStrings.currency.tr(context)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: isPriceSelected
                                    ? AppColors.golden
                                    : context.textPrimary,
                                fontFamily: 'Rubik',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String? _cleanPhotoUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final markdownMatch = RegExp(r'\]\((.*?)\)').firstMatch(value);
    return markdownMatch?.group(1) ?? value;
  }
}

class _LawyerBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _LawyerBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          AppSizes.w(4),
          Text(
            text,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _ScheduleCard({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasValue ? AppColors.golden : context.divColor,
          width: hasValue ? 1.5 : 1,
        ),
        boxShadow: hasValue
            ? [
                BoxShadow(
                  color: AppColors.golden.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: hasValue
                        ? AppColors.golden.withValues(alpha: 0.12)
                        : context.chipBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_calendar_rounded,
                    color: hasValue ? AppColors.golden : context.textSecondary,
                    size: 20.sp,
                  ),
                ),
                AppSizes.w(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.executionDateTime.tr(context),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          fontFamily: 'Rubik',
                        ),
                      ),
                      AppSizes.h(4),
                      Text(
                        hasValue
                            ? _formatVisibleDateTime(context, value!)
                            : AppStrings.chooseExecutionDateTime.tr(context),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: hasValue
                              ? context.textPrimary
                              : context.textSecondary,
                          fontWeight: hasValue
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.textSecondary,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatVisibleDateTime(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(value);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
    return '$date - $time';
  }
}

class _PaymentCard extends StatelessWidget {
  final String? activeCouponCode;
  final double total;
  final ConsultationLawyerModel? selectedLawyer;
  final ConsultationPriceModel? selectedPrice;

  const _PaymentCard({
    required this.activeCouponCode,
    required this.total,
    this.selectedLawyer,
    this.selectedPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedLawyer != null && selectedPrice != null) ...[
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.divColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 16.sp,
                      color: AppColors.golden,
                    ),
                    AppSizes.w(6),
                    Text(
                      AppStrings.serviceDetails.tr(context),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ],
                ),
                AppSizes.h(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedLawyer!.name,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      '${selectedPrice!.duration} ${AppStrings.minutesLabel.tr(context)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.golden,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.h(16),
        ],
        _SectionCard(
          title: AppStrings.paymentMethod.tr(context),
          child: Column(
            children: [
              _PaymentOption(
                title: AppStrings.payByCard.tr(context),
                icon: Icons.credit_card,
                selected: true,
                onTap: () {},
              ),
              if (activeCouponCode != null) ...[
                AppSizes.h(10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    AppStrings.couponApplied.tr(
                      context,
                      namedArgs: {'code': activeCouponCode!},
                    ),
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              AppSizes.h(14),
              SummaryRow(
                label: AppStrings.totalDue.tr(context),
                value: total,
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.primary.withValues(alpha: 0.10)
              : context.chipBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? context.colors.primary : context.divColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary, size: 20.sp),
            AppSizes.w(10),
            Expanded(
              child: Text(
                title,
                style: context.text.bodyMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? context.colors.primary : context.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSizes.h(14),
          child,
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: context.colors.error, size: 42.sp),
            AppSizes.h(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
            AppSizes.h(16),
            CustomButton(
              text: AppStrings.retry.tr(context),
              onPressed: onRetry,
              isSmall: true,
            ),
          ],
        ),
      ),
    );
  }
}
