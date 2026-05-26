import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';

import '../../../../../../../core/utils/app_colors.dart';
import '../../../../../../../core/utils/app_strings.dart';
import '../../../../../../../core/widgets/app_snackbar.dart';
import '../../../../../../../core/widgets/custom_button.dart';
import '../../../../../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _sendResetLink() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resendOtp(_phoneController.text.trim(), 'reset');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppStrings.forgotPassword.tr(context),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 24),
            CustomTextField(
              hintText: AppStrings.phone.tr(context),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (val) => val!.isEmpty ? AppStrings.requiredField.tr(context) : null,
            ),
            AppSizes.h(45),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthOperationSuccess) {
                  AppSnackbar.showSuccess(context, messageKey: AppStrings.otpSentMessage);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.otpVerification,
                    arguments: {
                      'phone': _phoneController.text.trim(),
                      'isForReset': true,
                    },
                  );
                } else if (state is AuthError) {
                  AppSnackbar.showError(context, message: state.message);
                }
              },
              builder: (context, state) {
                return CustomButton(
                  text: AppStrings.confirm.tr(context),
                  isLoading: state is AuthLoading,
                  onPressed: _sendResetLink,
                  textColor: context.isDark ? AppColors.primary : AppColors.cream,
                );
              },
            ),
             AppSizes.h(20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text(
                AppStrings.backToLogin.tr(context),
                style: context.text.labelSmall?.copyWith(
                  color: context.textPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
