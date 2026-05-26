import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/localization/app_localizations.dart';

import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';

import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/config/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  final bool isLawyerLogin;
  const LoginScreen({super.key, this.isLawyerLogin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text,
            isLawyer: widget.isLawyerLogin,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppStrings.login.tr(context),
      subtitle: AppStrings.loginSubtitle.tr(context),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(
              context,
              state.user.isProvider ? AppRoutes.lawyerMain : AppRoutes.main,
            );
          } else if (state is AuthNeedVerification) {
            Navigator.pushNamed(context, AppRoutes.verifyEmail,
                arguments: state.email);
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
                // ── Fields ──────────────────────────────────────
                AuthTextField(
                  hint: AppStrings.phone.tr(context),
                  controller: _emailController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone,
                      color: context.textPrimary, size: 20),
                  validator: (v) => AppValidators.validatePhone(context, v),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  hint: AppStrings.password.tr(context),
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icon(Icons.lock_outline,
                      color: context.textPrimary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: context.textPrimary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (v) => AppValidators.validatePassword(context, v),
                ),

                // ── Forgot password ──────────────────────────────
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: Text(
                        AppStrings.forgotPassword.tr(context),
                        style: context.text.titleSmall?.copyWith(
                          color: context.colors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: context.colors.primary,
                        ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Login Button ─────────────────────────────────
                CustomButton(
                  onPressed: _login,
                  isLoading: state is AuthLoading,
                  text: AppStrings.login.tr(context),
                ),

                const SizedBox(height: 28),

                // ── Signup prompt ────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    widget.isLawyerLogin ? AppRoutes.lawyerOnboarding : AppRoutes.register,
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppStrings.dontHaveAccount.tr(context),
                          style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
                        ),
                        TextSpan(
                          text: AppStrings.register.tr(context),
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
}
