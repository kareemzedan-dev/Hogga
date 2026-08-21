import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';

import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';

import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

import './widgets/phone_step.dart';
import './widgets/basic_info_step.dart';
import './widgets/password_step.dart';

/// Multi-step signup screen inspired by Beinah app:
///  Step 0 → Phone number
///  Step 1 → Name + Email + Account type
///  Step 2 → Password creation
class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _agreedToTerms = false;
  String _accountType = AppStrings.individual;
  int _step = 0; // 0: phone, 1: name+email+type, 2: password

  static const _stepTitles = [
    AppStrings.phoneStepTitle,
    AppStrings.nameStepTitle,
    AppStrings.passwordStepTitle,
  ];
  static const _stepSubtitles = [
    AppStrings.phoneStepSubtitle,
    AppStrings.nameStepSubtitle,
    AppStrings.passwordStepSubtitle,
  ];

  void _next() {
    if (_formKey.currentState!.validate()) {
      if (_step == 1 && !_agreedToTerms) {
        AppSnackbar.showError(context, messageKey: AppStrings.agreeToTermsError);
        return;
      }
      if (_step == 2) {
        _signup();
      } else {
        setState(() => _step++);
      }
    }
  }

  void _signup() {
    if (!_agreedToTerms) {
      AppSnackbar.showError(context, messageKey: AppStrings.agreeToTermsError);
      return;
    }
    context.read<AuthCubit>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: widget.role,
          accountType: _accountType == AppStrings.individual ? 'Personal' : 'Institution',
          termsAccepted: _agreedToTerms,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: _stepTitles[_step].tr(context),
      subtitle: _stepSubtitles[_step].tr(context),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthNeedVerification) {
            Navigator.pushNamed(context, AppRoutes.verifyEmail,
                arguments: state.email);
          } else if (state is Authenticated) {
             Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
          } else if (state is AuthError) {
            AppSnackbar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Step Content ─────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _buildStep(key: ValueKey(_step)),
                ),

                const SizedBox(height: 32),

                // ── Next / Submit Button ─────────────────────────
                CustomButton(
                  onPressed: _next,
                  isLoading: state is AuthLoading,
                  text: (_step == 2 ? AppStrings.createAccountButton : AppStrings.next).tr(context),
                ),

                const SizedBox(height: 20),

                // ── Login Prompt ─────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppStrings.alreadyHaveAccount.tr(context),
                          style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
                        ),
                        TextSpan(
                          text: AppStrings.login.tr(context),
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep({required Key key}) {
    switch (_step) {
      case 0:
        return PhoneStep(key: key, phoneController: _phoneController);
      case 1:
        return BasicInfoStep(
          key: key,
          nameController: _nameController,
          emailController: _emailController,
          accountType: _accountType,
          agreedToTerms: _agreedToTerms,
          onAccountTypeChanged: (type) => setState(() => _accountType = type),
          onTermsToggled: () => setState(() => _agreedToTerms = !_agreedToTerms),
        );
      case 2:
      default:
        return PasswordStep(
          key: key,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
        );
    }
  }
}
