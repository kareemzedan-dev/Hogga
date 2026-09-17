import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/features/shared/auth/presentation/lawyer/cubit/lawyer_registration_cubit.dart';
import 'package:hogga/features/shared/auth/data/models/lawyer_registration_models.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/utils/image_helper.dart';

// Modular Step Widgets
import 'widgets/provider_types_step.dart';
import 'widgets/specializations_step.dart';
import 'widgets/basic_info_step.dart';
import 'widgets/metadata_step.dart';
import 'lawyer_otp_verification_screen.dart';
import 'widgets/onboarding_status_step.dart';

class LawyerOnboardingScreen extends StatelessWidget {
  const LawyerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LawyerRegistrationCubit>()..loadOnboardingOptions(),
      child: const _LawyerOnboardingView(),
    );
  }
}

class _LawyerOnboardingView extends StatefulWidget {
  const _LawyerOnboardingView();

  @override
  State<_LawyerOnboardingView> createState() => _LawyerOnboardingViewState();
}

class _LawyerOnboardingViewState extends State<_LawyerOnboardingView> {
  static const int _maxUploadBytes = 5 * 1024 * 1024;
  static const String _draftKey = 'draft_lawyer_registration';

  final PageController _pageController = PageController();
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _metadataFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _civilIdController = TextEditingController();
  final _cityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _otpController = TextEditingController();

  final Map<String, TextEditingController> _metadataControllers = {};
  final Map<String, String> _metadataFiles = {};
  final Map<String, bool> _metadataLoading = {};
  
  int _currentStep = 0;
  String? _personalImagePath;
  bool _isPersonalImageLoading = false;
  String? _selectedLevel;
  late List<String> _levels;
  int? _savedProviderTypeId;
  List<int>? _savedSpecializationIds;
  int? _savedStep;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _levels = [
      AppStrings.primaryDegree.tr(context),
      AppStrings.appealDegree.tr(context),
      AppStrings.supremeDegree.tr(context)
    ];
    _selectedLevel ??= _levels[0];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _civilIdController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    _otpController.dispose();
    for (final c in _metadataControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Draft Persistence ---

  void _loadDraft() {
    final draftJson = AppPreferences().getDraft(_draftKey);
    if (draftJson == null) return;
    try {
      final data = jsonDecode(draftJson) as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _civilIdController.text = data['civilId'] ?? '';
      _cityController.text = data['city'] ?? '';
      _selectedLevel = data['level'] ?? _levels[0];
      _experienceController.text = data['experience'] ?? '';
      _savedProviderTypeId = data['providerTypeId'];
      if (data['specializationIds'] != null) {
        _savedSpecializationIds = List<int>.from(data['specializationIds']);
      }
      _savedStep = data['currentStep'];
    } catch (_) {}
  }

  void _saveDraft() {
    if (!mounted) return;
    final state = context.read<LawyerRegistrationCubit>().state;
    final draftData = {
      'currentStep': _currentStep,
      'providerTypeId': state.selectedProviderType?.id,
      'specializationIds': state.selectedSpecializationIds,
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'civilId': _civilIdController.text.trim(),
      'city': _cityController.text.trim(),
      'level': _selectedLevel,
      'experience': _experienceController.text.trim(),
    };
    AppPreferences().saveDraft(_draftKey, jsonEncode(draftData));
  }

  // --- Navigation & State ---

  void _handleStateChanges(BuildContext context, LawyerRegistrationState state) {
    if (state.errorMessageKey != null) {
      AppSnackbar.showError(context, messageKey: state.errorMessageKey);
      context.read<LawyerRegistrationCubit>().clearMessages();
    } else if (state.errorMessage?.isNotEmpty ?? false) {
      AppSnackbar.showError(context, message: state.errorMessage!);
      context.read<LawyerRegistrationCubit>().clearMessages();
    }

    if (state.successMessageKey != null) {
      AppSnackbar.showSuccess(context, messageKey: state.successMessageKey);
      context.read<LawyerRegistrationCubit>().clearMessages();
    } else if (state.successMessage?.isNotEmpty ?? false) {
      AppSnackbar.showSuccess(context, message: state.successMessage!);
      context.read<LawyerRegistrationCubit>().clearMessages();
    }
    if (state.draft != null && _currentStep == 2) _goToNextStep();
    if (state.isCompleted && _currentStep == 3) {
      AppPreferences().clearDraft(_draftKey);
      _goToNextStep();
    }

    // Auto-select draft options
    if (state.providerTypes.isNotEmpty && _savedProviderTypeId != null) {
      try {
        final pt = state.providerTypes.firstWhere((ProviderTypeModel e) => e.id == _savedProviderTypeId);
        context.read<LawyerRegistrationCubit>().selectProviderType(pt);
        _savedProviderTypeId = null;
      } catch (_) {}
    }
    if (state.specializations.isNotEmpty && (_savedSpecializationIds?.isNotEmpty ?? false)) {
      for (final id in _savedSpecializationIds!) {
        context.read<LawyerRegistrationCubit>().toggleSpecialization(id);
      }
      _savedSpecializationIds = null;
    }
    if (_savedStep != null && state.providerTypes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_savedStep! > 0 && _savedStep! <= 3) _pageController.jumpToPage(_savedStep!);
        _savedStep = null;
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  // --- Form Submissions ---

  Future<void> _handleContinue(LawyerRegistrationState state) async {
    switch (_currentStep) {
      case 0:
        if (state.selectedProviderType == null) {
          AppSnackbar.showError(context, messageKey: AppStrings.pleaseSelectAccountType);
          return;
        }
        _goToNextStep();
        break;
      case 1:
        if (state.selectedSpecializationIds.isEmpty) {
          AppSnackbar.showError(context, messageKey: AppStrings.pleaseSelectAtLeastOneSpec);
          return;
        }
        _goToNextStep();
        break;
      case 2:
        await _submitBasicInfo(state);
        break;
      case 3:
        await _submitMetadata(state);
        break;
    }
  }

  Future<void> _submitBasicInfo(LawyerRegistrationState state) async {
    if (!(_basicInfoFormKey.currentState?.validate() ?? false)) return;
    if (_personalImagePath == null) {
      AppSnackbar.showError(context, messageKey: AppStrings.pleaseUploadPersonalPhoto);
      return;
    }
    
    if (!state.isPhoneVerified || state.verifiedPhone != _phoneController.text.trim()) {
      final success = await context.read<LawyerRegistrationCubit>().sendOtp(_phoneController.text.trim());
      if (success && mounted) {
        final isVerified = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<LawyerRegistrationCubit>(),
              child: LawyerOtpVerificationScreen(phone: _phoneController.text.trim()),
            ),
          ),
        );
        if (isVerified == true && mounted) {
          // Proceed directly to registration since validation passed prior to OTP
          await context.read<LawyerRegistrationCubit>().registerBasicInfo(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            civilId: _civilIdController.text.trim(),
            city: _cityController.text.trim(),
            level: _selectedLevel ?? '',
            experienceYears: _experienceController.text.trim(),
            imagePath: _personalImagePath!,
          );
        }
      }
      return;
    }

    await context.read<LawyerRegistrationCubit>().registerBasicInfo(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      civilId: _civilIdController.text.trim(),
      city: _cityController.text.trim(),
      level: _selectedLevel ?? '',
      experienceYears: _experienceController.text.trim(),
      imagePath: _personalImagePath!,
    );
  }

  Future<void> _submitMetadata(LawyerRegistrationState state) async {
    final providerType = state.selectedProviderType;
    if (providerType == null) return;
    if (!(_metadataFormKey.currentState?.validate() ?? false)) return;

    final metadata = <String, dynamic>{};
    for (final field in providerType.fields) {
      if (field.type == 'file') {
        final path = _metadataFiles[field.key];
        if (field.isRequired && (path?.isEmpty ?? true)) {
          AppSnackbar.showError(context, message: AppStrings.pleaseUploadField.tr(context, namedArgs: {'field': field.name}));
          return;
        }
        if (path?.isNotEmpty ?? false) {
          metadata[field.key] = await MultipartFile.fromFile(path!);
        }
      } else {
        final value = _metadataControllers[field.key]?.text.trim() ?? '';
        if (field.isRequired && value.isEmpty) {
          AppSnackbar.showError(context, message: AppStrings.pleaseEnterField.tr(context, namedArgs: {'field': field.name}));
          return;
        }
        if (value.isNotEmpty) metadata[field.key] = value;
      }
    }
    await context.read<LawyerRegistrationCubit>().completeProfile(metadata: metadata);
  }

  // --- File Picking ---

  Future<void> _pickFile({required bool isPersonal, String? metadataKey}) async {
    final result = await FilePicker.platform.pickFiles(
      type: isPersonal ? FileType.image : FileType.custom,
      allowedExtensions: isPersonal ? null : const ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
    );
    if (result == null || result.files.single.path == null) return;
    
    final file = result.files.single;
    final ext = (file.extension ?? '').toLowerCase();
    if (!isPersonal && !['jpg', 'jpeg', 'png', 'pdf', 'webp'].contains(ext)) {
      AppSnackbar.showError(context, messageKey: AppStrings.unsupportedFileFormat);
      return;
    }
    if (file.size > _maxUploadBytes) {
      AppSnackbar.showError(context, messageKey: AppStrings.fileSizeTooLarge);
      return;
    }

    if (isPersonal) {
      setState(() => _isPersonalImageLoading = true);
      final compressed = await ImageHelper.compressImage(File(file.path!));
      setState(() { _personalImagePath = compressed.path; _isPersonalImageLoading = false; });
    } else if (metadataKey != null) {
      setState(() => _metadataLoading[metadataKey] = true);
      final compressed = await ImageHelper.compressImage(File(file.path!));
      setState(() { _metadataFiles[metadataKey] = compressed.path; _metadataLoading[metadataKey] = false; });
    }
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerRegistrationCubit, LawyerRegistrationState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.pageBg,
          body: SafeArea(
            child: state.isLoadingOptions
                ? const LawyerShimmerLoading()
                : Column(
                    children: [
                      _buildTopBar(context),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _currentStep = index);
                            _saveDraft();
                          },
                          children: [
                            ProviderTypesStep(state: state, onContinue: () => _handleContinue(state)),
                            SpecializationsStep(state: state, onContinue: () => _handleContinue(state)),
                            BasicInfoStep(
                              state: state,
                              formKey: _basicInfoFormKey,
                              nameController: _nameController,
                              phoneController: _phoneController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              civilIdController: _civilIdController,
                              cityController: _cityController,
                              experienceController: _experienceController,
                              personalImagePath: _personalImagePath,
                              isPersonalImageLoading: _isPersonalImageLoading,
                              selectedLevel: _selectedLevel ?? '',
                              levels: _levels,
                              onPickImage: () => _pickFile(isPersonal: true),
                              onClearImage: () => setState(() => _personalImagePath = null),
                              onLevelChanged: (v) => setState(() => _selectedLevel = v),
                              onPhoneChanged: (v) {
                                if (state.verifiedPhone != v.trim()) context.read<LawyerRegistrationCubit>().resetPhoneVerification();
                              },
                              onContinue: () => _handleContinue(state),
                            ),
                            MetadataStep(
                              state: state,
                              formKey: _metadataFormKey,
                              controllers: _metadataControllers,
                              files: _metadataFiles,
                              loadingStates: _metadataLoading,
                              onPickFile: (key) => _pickFile(isPersonal: false, metadataKey: key),
                              onClearFile: (key) => setState(() => _metadataFiles.remove(key)),
                              onContinue: () => _handleContinue(state),
                            ),
                            const OnboardingStatusStep(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final steps = [
      AppStrings.stepAccount.tr(context),
      AppStrings.stepSpecialization.tr(context),
      AppStrings.stepDataLabel.tr(context),
      AppStrings.stepDocuments.tr(context),
      AppStrings.stepStatus.tr(context),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _currentStep == 0 ? () => Navigator.pop(context) : () => _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
                icon: Icon(
                  Directionality.of(context) == TextDirection.rtl ||
                          Localizations.localeOf(context).languageCode == 'ar'
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Text(AppStrings.joinhoggaTeam.tr(context), style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / steps.length,
              minHeight: 8,
              backgroundColor: context.divColor.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.golden),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.stepXofY.tr(context, namedArgs: {
                  'current': (_currentStep + 1).toString(),
                  'total': steps.length.toString()
                }),
                style: context.text.bodySmall?.copyWith(color: AppColors.golden),
              ),
              Text(steps[_currentStep], style: context.text.bodySmall?.copyWith(color: context.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
