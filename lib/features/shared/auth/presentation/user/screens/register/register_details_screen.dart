import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

import '../../../../../../../core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_back_button.dart';

class RegisterDetailsScreen extends StatefulWidget {
  final String phone;
  final String password;
  const RegisterDetailsScreen({
    super.key,
    required this.phone,
    required this.password,
  });

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isIndividual = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        AppSnackbar.showError(
          context,
          messageKey: AppStrings.agreeToTermsError,
        );
        return;
      }

      final referralCode = _referralCodeController.text.trim();
      context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: widget.password,
        name: _nameController.text.trim(),
        phone: widget.phone,
        role: 'user',
        accountType: _isIndividual ? 'Personal' : 'Institution',
        termsAccepted: _agreeToTerms,
        referralCode: referralCode.isNotEmpty ? referralCode : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CustomBackButton(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                AppStrings.nameStepTitle.tr(context),
                style: context.text.headlineSmall?.copyWith(
                  color: context.colors.primary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.nameStepSubtitle.tr(context),
                style: context.text.bodyMedium?.copyWith(
                  color: context.textSecondary,
                  fontSize: 11.sp,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              // Name & Email
              AuthTextField(
                controller: _nameController,
                hint: AppStrings.fullNameHint.tr(context),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: context.colors.primary,
                  size: 20,
                ),
                validator: (v) => AppValidators.validateRequired(context, v),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                hint: AppStrings.email.tr(context),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: context.colors.primary,
                  size: 20,
                ),
                validator: (v) => AppValidators.validateEmail(context, v),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _referralCodeController,
                hint: AppStrings.referralCodeOptional.tr(context),
                prefixIcon: Icon(
                  Icons.card_giftcard_rounded,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppStrings.accountTier.tr(context),
                style: context.text.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectableCard(
                      title: AppStrings.corporate.tr(context),
                      isSelected: !_isIndividual,
                      onTap: () => setState(() => _isIndividual = false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectableCard(
                      title: AppStrings.individual.tr(context),
                      isSelected: _isIndividual,
                      onTap: () => setState(() => _isIndividual = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _agreeToTerms
                            ? context.colors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreeToTerms
                              ? context.colors.primary
                              : context.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: _agreeToTerms
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.iAgreeTo.tr(context),
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.termsOfUseTitle.tr(context),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                      (route) => false,
                    );
                  } else if (state is AuthError) {
                    AppSnackbar.showError(context, message: state.message);
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _onRegister,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: context.divColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppStrings.createAccountButton.tr(context)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.lawyerOnboarding),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppStrings.areYouALawyer.tr(context),
                          style: context.text.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: AppStrings.registerAsNewLawyer.tr(context),
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.textPrimary
                : context.textSecondary.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: context.text.titleSmall?.copyWith(
              color: isSelected
                  ? context.colors.primary
                  : context.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
