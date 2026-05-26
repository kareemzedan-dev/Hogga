import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

class PasswordStep extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const PasswordStep({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          hint: AppStrings.password.tr(context),
          controller: widget.passwordController,
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
        const SizedBox(height: 14),
        AuthTextField(
          hint: AppStrings.confirmPassword.tr(context),
          controller: widget.confirmPasswordController,
          obscureText: !_isConfirmVisible,
          prefixIcon: Icon(Icons.lock_outline,
              color: context.textPrimary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: context.textPrimary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _isConfirmVisible = !_isConfirmVisible),
          ),
          validator: (v) => AppValidators.validateConfirmPassword(context, v, widget.passwordController.text),
        ),
      ],
    );
  }
}
