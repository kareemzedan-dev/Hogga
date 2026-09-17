import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

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
    final isEn = AppLocalizations.of(context)?.locale.languageCode == 'en';
    return AuthLayout(
      title: AppStrings.resetPassword.tr(context),
      subtitle: isEn
          ? 'Enter your new password to secure your account'
          : 'أدخل كلمة المرور الجديدة لتأمين حسابك',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _passwordController,
              hint: AppStrings.password.tr(context),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: const Color(0xFFDEC396), size: 20.sp),
              obscureText: !_isPasswordVisible,
              validator: (v) => AppValidators.validatePassword(context, v),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: const Color(0xFFDEC396),
                  size: 20.sp,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _confirmPasswordController,
              hint: AppStrings.confirmPassword.tr(context),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: const Color(0xFFDEC396), size: 20.sp),
              obscureText: !_isConfirmVisible,
              validator: (v) => AppValidators.validateConfirmPassword(context, v, _passwordController.text),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: const Color(0xFFDEC396),
                  size: 20.sp,
                ),
                onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
            SizedBox(height: 28.h),
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
                return SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDFBF7A),
                      foregroundColor: const Color(0xFF1B0F08),
                      elevation: 4,
                      shadowColor: const Color(0xFFDFBF7A).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFF1B0F08),
                            ),
                          )
                        : Text(
                            AppStrings.resetPassword.tr(context),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B0F08),
                            ),
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.backToLogin.tr(context),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFFDEC396),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFFDEC396),
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
