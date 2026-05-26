import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';
import 'package:hogga/core/utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;

  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(
            phone: widget.phone,
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppStrings.resetPassword.tr(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            AuthTextField(
              controller: _passwordController,
              hint: AppStrings.password.tr(context),
              prefixIcon: Icon(Icons.lock_outline, color: context.colors.primary, size: 20),
              obscureText: !_isPasswordVisible,
              validator: (v) => AppValidators.validatePassword(context, v),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: context.colors.primary, size: 20),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordController,
              hint: AppStrings.confirmPassword.tr(context),
              prefixIcon: Icon(Icons.lock_outline, color: context.colors.primary, size: 20),
              obscureText: !_isConfirmVisible,
              validator: (v) => AppValidators.validateConfirmPassword(context, v, _passwordController.text),
              suffixIcon: IconButton(
                icon: Icon(_isConfirmVisible ? Icons.visibility : Icons.visibility_off, color: context.colors.primary, size: 20),
                onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
            
            AppSizes.h(45),
            
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthOperationSuccess) {
                  AppSnackbar.showSuccess(context, messageKey: AppStrings.passwordChanged);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else if (state is AuthError) {
                  AppSnackbar.showError(context, message: state.message);
                }
              },
              builder: (context, state) {
                return CustomButton(
                  text: AppStrings.resetPassword.tr(context),
                  isLoading: state is AuthLoading,
                  onPressed: _resetPassword,
                  textColor: context.isDark ? AppColors.primary : AppColors.cream,
                );
              },
            ),
            
            AppSizes.h(20),
            
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.backToLogin.tr(context),
                  style: context.text.labelSmall?.copyWith(
                        color: context.textPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: context.textPrimary,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
