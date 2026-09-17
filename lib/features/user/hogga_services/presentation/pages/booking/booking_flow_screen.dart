import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
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
  final int?
  typeOfBookingFlow; // 0 for main, 1 for provider core fixed, 2 for provider core, 3 admin core

  const BookingFlowScreen({
    super.key,
    required this.args,
    required this.typeOfBookingFlow,
  });

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
  Map<String, String> _metadataValues = {};
  bool _infoDialogShown = false;
  int? _savedStep;

  // New Case 0 specific fields
  bool _canAttendRemotely = false;
  TextEditingController? _governorateController;
  TextEditingController? _cityController;

  String get _draftKey =>
      'draft_booking_${widget.args.childCategoryId}_${widget.args.itemCategoryId}';

  // Step 2 state
  int? _lawyerMode; // 0 = broadcast, 1 = manual
  Set<String> _selectedLawyerIds = {};

  // Step 3 state
  final _promoController = TextEditingController();
  int _paymentMethod = 0; // Card only for the current booking flow.

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
  String get _paymentMethodValue => 'card';

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
        _paymentMethod = 0;
        _promoController.text = data['promoCode'] ?? '';
        final promoCode = _promoController.text.trim();
        if (promoCode.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _serviceRequestCubit.verifyCoupon(promoCode);
            }
          });
        }
        _canAttendRemotely = data['canAttendRemotely'] ?? false;
        final metadata = data['metadata'];
        if (metadata is Map) {
          _metadataValues = metadata.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          );
        }
        if (_governorateController != null) {
          _governorateController!.text = data['governorate'] ?? '';
        }
        if (_cityController != null) {
          _cityController!.text = data['city'] ?? '';
        }

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
      'paymentMethod': 0,
      'promoCode': _promoController.text.trim(),
      'selectedLawyerIds': _selectedLawyerIds.toList(),
      'metadata': _metadataValues,
      'canAttendRemotely': _canAttendRemotely,
      'governorate': _governorateController?.text.trim(),
      'city': _cityController?.text.trim(),
    };
    AppPreferences().saveDraft(_draftKey, jsonEncode(data));
  }

  Future<void> _submitRequest() async {
    if (_selectionType == 'select' && _selectedLawyerIds.isEmpty) {
      AppSnackbar.showError(
        context,
        messageKey: AppStrings.pleaseSelectAtLeastOneLawyer,
      );
      return;
    }

    final missingInput = widget.args.requiredInputs.any(
      (input) =>
          input.isRequired &&
          (_metadataValues[input.slug]?.trim().isEmpty ?? true),
    );
    if (missingInput) {
      AppSnackbar.showError(
        context,
        messageKey: AppStrings.pleaseCompleteAllFields,
      );
      return;
    }

    final metadata = Map<String, dynamic>.fromEntries(
      _metadataValues.entries.where((entry) => entry.value.trim().isNotEmpty),
    );

    final effectiveSubCategoryId = (widget.args.subCategoryId != null &&
            widget.args.subCategoryId! > 0)
        ? widget.args.subCategoryId!
        : widget.args.childCategoryId;

    final request = CreateLegalCaseRequest(
      categoriesItemId: widget.args.itemCategoryId,
      categoriesSubId: effectiveSubCategoryId,
      title: _titleController.text.trim(),
      description: _detailsController.text.trim(),
      selectionType: _selectionType,
      lawyerIds: _selectionType == 'select'
          ? _selectedLawyerIds.map(int.parse).toList()
          : const [],
      couponCode: _promoController.text.trim().isEmpty
          ? null
          : _promoController.text.trim(),
      paymentMethod: _paymentMethodValue,
      metadata: metadata,
    );

    await _serviceRequestCubit.submitRequest(request);
  }

  Future<void> _openLawyerBrowser() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.lawyerBrowser,
      arguments: {
        'categories_item_id': widget.args.itemCategoryId,
        'typeOfBookingFlow': widget.typeOfBookingFlow,
        'coupon': _promoController.text.trim(),
      },
    );

    if (result == null) return;
    Iterable<dynamic>? lawyerIds;
    String? coupon;
    bool hasCouponInfo = false;

    if (result is Map) {
      final rawIds = result['lawyerIds'] ?? result['lawyer_ids'];
      if (rawIds is Iterable) lawyerIds = rawIds;
      if (result.containsKey('coupon')) {
        hasCouponInfo = true;
        coupon = result['coupon']?.toString().trim();
      }
    } else if (result is Iterable) {
      lawyerIds = result;
    }

    setState(() {
      final selectedLawyerIds = lawyerIds;
      if (selectedLawyerIds != null) {
        _selectedLawyerIds = selectedLawyerIds.map((e) => e.toString()).toSet();
      }
      if (hasCouponInfo) {
        if (coupon != null && coupon.isNotEmpty) {
          _promoController.text = coupon;
        } else {
          _promoController.clear();
        }
      }
    });
    _saveDraft();
    if (hasCouponInfo) {
      if (coupon != null && coupon.isNotEmpty) {
        _serviceRequestCubit.verifyCoupon(coupon);
      } else {
        _serviceRequestCubit.clearCoupon();
      }
    }
  }

  void _nextPage() {
    final promo = _promoController.text.trim();
    if (promo.isNotEmpty && _serviceRequestCubit.state.coupon == null) {
      _serviceRequestCubit.verifyCoupon(promo);
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceRequestCubit,
      child: BlocListener<ServiceRequestCubit, ServiceRequestState>(
        listenWhen: (previous, current) =>
            (previous.isSubmitting && !current.isSubmitting) ||
            (previous.isVerifyingCoupon &&
                !current.isVerifyingCoupon &&
                current.errorMessage != null),
        listener: (context, state) async {
          if (state.errorMessage != null) {
            AppSnackbar.showError(context, message: state.errorMessage!);
          } else if (state.createdCase != null) {
            AppPreferences().clearDraft(_draftKey);
            final caseNum = state.createdCase!.caseNumber ?? '';
            final caseId = state.createdCase!.caseId;
            final paymentUrl = state.createdCase!.paymentUrl;

            if (paymentUrl != null && paymentUrl.isNotEmpty) {
              if (mounted) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.paymentWebView,
                  arguments: {
                    'paymentUrl': paymentUrl,
                    'caseNumber': caseNum,
                    'caseId': caseId,
                    'recordType': 'service',
                  },
                );
              }
            } else {
              if (mounted) {
                AppSnackbar.showError(
                  context,
                  messageKey: AppStrings.paymentLinkUnavailable,
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

            final discount =
                currentCoupon?.discountAmount ??
                _computeDiscount(currentCoupon, _servicePrice);
            final tax = (_servicePrice - discount) * _taxRate;
            final total =
                currentCoupon?.totalPrice ?? ((_servicePrice - discount) + tax);

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
              onClearCoupon: () {
                _promoController.clear();
                context.read<ServiceRequestCubit>().clearCoupon();
                _saveDraft();
              },
              onPaymentMethodChanged: (m) {
                setState(() => _paymentMethod = 0);
                _saveDraft();
              },
              servicePrice: _servicePrice,
              discount: discount,
              tax: tax,
              total: total,
              isSubmitting: isSubmitting,
              onComplete: _submitRequest,
              serviceName: widget.args.itemName.isNotEmpty
                  ? widget.args.itemName
                  : widget.args.subCategoryName,
            );

            final lawyerModeStepWidget = LawyerModeStep(
              lawyerMode: _lawyerMode,
              selectedLawyersCount: _selectedLawyerIds.length,
              servicePrice: _servicePrice,
              currency: AppStrings.currencySymbol.tr(context),
              isProviderFlow:
                  widget.typeOfBookingFlow == 1 ||
                  widget.typeOfBookingFlow == 2,
              onModeChanged: (m) async {
                setState(() => _lawyerMode = m);
                _saveDraft();
                if (m == 1) {
                  await _openLawyerBrowser();
                }
              },
              onBrowseLawyers: _openLawyerBrowser,
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
                  categoryDesc:
                      '${widget.args.childCategoryName} - ${widget.args.itemName}',
                  items: const [],
                  isValid:
                      _titleController.text.isNotEmpty &&
                      _detailsController.text.isNotEmpty,
                  duration: widget.args.duration,
                  isCallType: widget.args.isCallType,
                ),
                paymentStepWidget,
              ];
            } else if (widget.typeOfBookingFlow == 1 ||
                widget.typeOfBookingFlow == 2) {
              stepKeys = [
                AppStrings.stepSendRequest,
                AppStrings.stepChooseLawyer,
                AppStrings.stepPayment,
              ];
              stepWidgets = [
                BookingFlowProviderCore(
                  titleController: _titleController,
                  detailsController: _detailsController,
                  onNext: _nextPage,
                  categoryTitle: widget.args.subCategoryName,
                  categoryDesc:
                      '${widget.args.childCategoryName} - ${widget.args.itemName}',
                  items: const [],
                  isValid:
                      _titleController.text.isNotEmpty &&
                      _detailsController.text.isNotEmpty,
                  duration: widget.args.duration,
                  isCallType: widget.args.isCallType,
                ),
                lawyerModeStepWidget,
                paymentStepWidget,
              ];
            } else {
              stepKeys = [
                AppStrings.stepSendRequest,
                AppStrings.stepChooseLawyer,
                AppStrings.stepPayment,
              ];
              stepWidgets = [
                RequestDetailsStep(
                  titleController: _titleController,
                  detailsController: _detailsController,
                  showInfoDialog: !_infoDialogShown,
                  onInfoDialogDismissed: () =>
                      setState(() => _infoDialogShown = true),
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
                  requiredInputs: widget.args.requiredInputs,
                  metadataValues: _metadataValues,
                  onMetadataChanged: (slug, value) {
                    setState(() => _metadataValues[slug] = value);
                    _saveDraft();
                  },
                ),
                lawyerModeStepWidget,
                paymentStepWidget,
              ];
            }

            final appBarTitle = widget.args.sectionName;

            return Scaffold(
              backgroundColor: context.pageBg,
              appBar: MainAppbar(
                title: appBarTitle,
                onBack: _prevPage,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(46),
                  child: BookingStepProgressBar(
                    currentStep: _currentStep,
                    steps: stepKeys,
                  ),
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
