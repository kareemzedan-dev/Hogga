import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/injection_container.dart' as di;
import 'package:hogga/features/user/hogga_services/domain/models/booking_flow_args.dart';
import 'package:hogga/features/user/hogga_services/data/models/legal_case_models.dart';
import '../../manager/service_request_cubit.dart';
import 'widgets/booking_components.dart';
import 'widgets/booking_steps.dart';
import 'widgets/booking_variants.dart';

/// 3-step booking flow: Request Details → Lawyer Mode → Payment
class BookingFlowScreen extends StatefulWidget {
  final BookingFlowArgs args;
  final int? typeOfBookingFlow; // 0 for main, 1 for provider core fixed, 2 for provider core, 3 admin core

  const BookingFlowScreen({super.key, required this.args, required this.typeOfBookingFlow});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final PageController _pageController = PageController();
  late final ServiceRequestCubit _serviceRequestCubit;
  int _currentStep = 0;

  // Step 1 state
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _infoDialogShown = false;
  int? _savedStep;

  // New Case 0 specific fields
  bool _canAttendRemotely = false;
  TextEditingController? _governorateController;
  TextEditingController? _cityController;

  String get _draftKey => 'draft_booking_${widget.args.childCategoryId}_${widget.args.itemCategoryId}';

  // Step 2 state
  int? _lawyerMode; // 0 = broadcast, 1 = manual
  Set<String> _selectedLawyerIds = {};

  // Step 3 state
  final _promoController = TextEditingController();
  int _paymentMethod = 0; // 0 = card, 1 = wallet

  double get _servicePrice => widget.args.price;
  static const double _taxRate = 0.0;

  double _computeDiscount(CouponData? coupon, double amount) {
    if (coupon == null) return 0;
    if (coupon.discountType == 'percent') {
      return amount * (coupon.discountValue / 100);
    }
    return coupon.discountValue;
  }

  String get _selectionType => _lawyerMode == 1 ? 'select' : 'send';
  String get _paymentMethodValue => _paymentMethod == 1 ? 'wallet' : 'card';

  @override
  void initState() {
    super.initState();
    _serviceRequestCubit = di.sl<ServiceRequestCubit>();
    if (widget.typeOfBookingFlow == 0) {
      _governorateController = TextEditingController();
      _cityController = TextEditingController();
      _governorateController!.addListener(_saveDraft);
      _cityController!.addListener(_saveDraft);
    }
    _loadDraft();
    _titleController.addListener(_saveDraft);
    _detailsController.addListener(_saveDraft);
    _promoController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveDraft);
    _detailsController.removeListener(_saveDraft);
    _promoController.removeListener(_saveDraft);
    _governorateController?.removeListener(_saveDraft);
    _cityController?.removeListener(_saveDraft);
    
    _serviceRequestCubit.close();
    
    _titleController.dispose();
    _detailsController.dispose();
    _promoController.dispose();
    _governorateController?.dispose();
    _cityController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadDraft() {
    final draftJson = AppPreferences().getDraft(_draftKey);
    if (draftJson != null) {
      try {
        final data = jsonDecode(draftJson) as Map<String, dynamic>;
        _titleController.text = data['title'] ?? '';
        _detailsController.text = data['details'] ?? '';
        _savedStep = data['currentStep'];
        _lawyerMode = data['lawyerMode'] as int?;
        _paymentMethod = (data['paymentMethod'] as int?) ?? 0;
        _promoController.text = data['promoCode'] ?? '';
        _canAttendRemotely = data['canAttendRemotely'] ?? false;
        if (_governorateController != null) _governorateController!.text = data['governorate'] ?? '';
        if (_cityController != null) _cityController!.text = data['city'] ?? '';

        final lawyerIds = data['selectedLawyerIds'];
        if (lawyerIds is List) {
          _selectedLawyerIds = lawyerIds.map((e) => e.toString()).toSet();
        }

        if (_savedStep != null && _savedStep! > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _currentStep = _savedStep!;
              _pageController.jumpToPage(_savedStep!);
            }
          });
        }
      } catch (_) {}
    }
  }

  void _saveDraft() {
    if (!mounted) return;
    final data = {
      'currentStep': _currentStep,
      'title': _titleController.text.trim(),
      'details': _detailsController.text.trim(),
      'lawyerMode': _lawyerMode,
      'paymentMethod': _paymentMethod,
      'promoCode': _promoController.text.trim(),
      'selectedLawyerIds': _selectedLawyerIds.toList(),
      'canAttendRemotely': _canAttendRemotely,
      'governorate': _governorateController?.text.trim(),
      'city': _cityController?.text.trim(),
    };
    AppPreferences().saveDraft(_draftKey, jsonEncode(data));
  }



  Future<void> _submitRequest() async {
    if (_selectionType == 'select' && _selectedLawyerIds.isEmpty) {
      AppSnackbar.showError(context, messageKey: AppStrings.pleaseSelectAtLeastOneLawyer);
      return;
    }

    final request = CreateLegalCaseRequest(
      categoriesItemId: widget.args.itemCategoryId,
      title: _titleController.text.trim(),
      description: _detailsController.text.trim(),
      selectionType: _selectionType,
      lawyerIds: _selectedLawyerIds.map(int.parse).toList(),
      couponCode: _promoController.text.trim().isEmpty ? null : _promoController.text.trim(),
      paymentMethod: _paymentMethodValue,
    );

    await _serviceRequestCubit.submitRequest(request);
  }

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _prevPage() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceRequestCubit,
      child: BlocListener<ServiceRequestCubit, ServiceRequestState>(
        listenWhen: (previous, current) => previous.isSubmitting && !current.isSubmitting,
        listener: (context, state) async {
          if (state.errorMessage != null) {
            AppSnackbar.showError(context, message: state.errorMessage!);
          } else if (state.createdCase != null) {
            AppPreferences().clearDraft(_draftKey);
            final caseNum = state.createdCase!.caseNumber ?? '';
            final paymentUrl = state.createdCase!.paymentUrl;

            if (paymentUrl != null && paymentUrl.isNotEmpty) {
              if (mounted) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.paymentWebView,
                  arguments: {
                    'paymentUrl': paymentUrl,
                    'caseNumber': caseNum,
                  },
                );
              }
            } else {
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.orderConfirmed,
                  (route) => false,
                  arguments: {'caseNumber': caseNum},
                );
              }
            }
          }
        },
        child: BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
          builder: (context, state) {
            CouponData? currentCoupon = state.coupon;
            bool isVerifying = state.isVerifyingCoupon;
            bool isSubmitting = state.isSubmitting;

            final discount = _computeDiscount(currentCoupon, _servicePrice);
            final tax = (_servicePrice - discount) * _taxRate;
            final total = (_servicePrice - discount) + tax;

            List<String> stepKeys;
            List<Widget> stepWidgets;

            final paymentStepWidget = PaymentStep(
              promoController: _promoController,
              paymentMethod: _paymentMethod,
              isApplyingCoupon: isVerifying,
              coupon: currentCoupon,
              onApplyCoupon: () {
                final code = _promoController.text.trim();
                if (code.isEmpty) {
                  context.read<ServiceRequestCubit>().clearCoupon();
                  return;
                }
                context.read<ServiceRequestCubit>().verifyCoupon(code);
              },
              onPaymentMethodChanged: (m) {
                setState(() => _paymentMethod = m);
                _saveDraft();
              },
              servicePrice: _servicePrice,
              discount: discount,
              tax: tax,
              total: total,
              isSubmitting: isSubmitting,
              onComplete: _submitRequest,
              serviceName: widget.args.itemName ?? widget.args.subCategoryName ?? '',
            );

            final lawyerModeStepWidget = LawyerModeStep(
              lawyerMode: _lawyerMode,
              selectedLawyersCount: _selectedLawyerIds.length,
              servicePrice: _servicePrice,
              currency: AppStrings.currencySymbol.tr(context),
              isProviderFlow: widget.typeOfBookingFlow == 1 || widget.typeOfBookingFlow == 2,
              onModeChanged: (m) async {
                setState(() => _lawyerMode = m);
                _saveDraft();
                if (m == 1) {
                  final result = await Navigator.pushNamed(context, AppRoutes.lawyerBrowser, arguments: {
                    'categories_item_id': widget.args.childCategoryId,
                    'typeOfBookingFlow': widget.typeOfBookingFlow,
                  });
                  if (result != null && result is Iterable) {
                    setState(() => _selectedLawyerIds = result.map((e) => e.toString()).toSet());
                    _saveDraft();
                  }
                }
              },
              onBrowseLawyers: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.lawyerBrowser, arguments: {
                  'categories_item_id': widget.args.childCategoryId,
                  'typeOfBookingFlow': widget.typeOfBookingFlow,
                });
                if (result != null && result is Iterable) {
                  setState(() => _selectedLawyerIds = result.map((e) => e.toString()).toSet());
                  _saveDraft();
                }
              },
              onNext: _lawyerMode != null ? _nextPage : null,
            );

            if (widget.typeOfBookingFlow == 3) {
              stepKeys = [AppStrings.stepSendRequest, AppStrings.stepPayment];
              stepWidgets = [
                BookingFlowAdminCore(
                  titleController: _titleController,
                  detailsController: _detailsController,
                  onNext: _nextPage,
                  categoryTitle: widget.args.subCategoryName,
                  categoryDesc: '${widget.args.childCategoryName} - ${widget.args.itemName}',
                  items: const [],
                  isValid: _titleController.text.isNotEmpty && _detailsController.text.isNotEmpty,
                  duration: widget.args.duration,
                  isCallType: widget.args.isCallType,
                ),
                paymentStepWidget,
              ];
            } else if (widget.typeOfBookingFlow == 1 || widget.typeOfBookingFlow == 2) {
              stepKeys = [AppStrings.stepSendRequest, AppStrings.stepChooseLawyer, AppStrings.stepPayment];
              stepWidgets = [
                BookingFlowProviderCore(
                  titleController: _titleController,
                  detailsController: _detailsController,
                  onNext: _nextPage,
                  categoryTitle: widget.args.subCategoryName,
                  categoryDesc: '${widget.args.childCategoryName} - ${widget.args.itemName}',
                  items: const [],
                  isValid: _titleController.text.isNotEmpty && _detailsController.text.isNotEmpty,
                  duration: widget.args.duration,
                  isCallType: widget.args.isCallType,
                ),
                lawyerModeStepWidget,
                paymentStepWidget,
              ];
            } else {
              stepKeys = [AppStrings.stepSendRequest, AppStrings.stepChooseLawyer, AppStrings.stepPayment];
              stepWidgets = [
                RequestDetailsStep(
                  titleController: _titleController,
                  detailsController: _detailsController,
                  showInfoDialog: !_infoDialogShown,
                  onInfoDialogDismissed: () => setState(() => _infoDialogShown = true),
                  onNext: _nextPage,
                  subCategoryName: widget.args.subCategoryName,
                  childCategoryName: widget.args.childCategoryName,
                  itemName: widget.args.itemName,
                  canAttendRemotely: _canAttendRemotely,
                  onRemoteAttendanceChanged: (val) {
                    setState(() => _canAttendRemotely = val);
                    _saveDraft();
                  },
                  governorateController: _governorateController,
                  cityController: _cityController,
                  duration: widget.args.duration,
                  isCallType: widget.args.isCallType,
                ),
                lawyerModeStepWidget,
                paymentStepWidget,
              ];
            }

            final appBarTitle = widget.args.sectionName;

            return Scaffold(
              backgroundColor: context.pageBg,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: context.textPrimary),
                  onPressed: _prevPage,
                ),
                centerTitle: true,
                title: Text(
                  appBarTitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontFamily: 'Rubik',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(46),
                  child: BookingStepProgressBar(currentStep: _currentStep, steps: stepKeys),
                ),
              ),
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) {
                  setState(() => _currentStep = i);
                  _saveDraft();
                },
                children: stepWidgets,
              ),
            );
          },
        ),
      ),
    );
  }
}
