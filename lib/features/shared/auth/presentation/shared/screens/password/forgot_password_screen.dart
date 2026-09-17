import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_phone_country_prefix.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resendOtp(_phoneController.text.trim(), 'reset');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.of(context)?.locale.languageCode == 'en';
    return AuthLayout(
      title: AppStrings.forgotPassword.tr(context),
      subtitle: isEn
          ? 'Enter your phone number to receive a verification code'
          : 'أدخل رقم هاتفك المسجل لاستلام رمز التحقق',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _phoneController,
              hint: AppStrings.phone.tr(context),
              keyboardType: TextInputType.phone,
              prefixIcon: const AuthPhoneCountryPrefix(),
              suffixIcon: Icon(
                Icons.phone_iphone_rounded,
                color: const Color(0xFFDEC396),
                size: 20.sp,
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? AppStrings.requiredField.tr(context)
                  : null,
            ),
            SizedBox(height: 28.h),
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
                return SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _sendResetLink,
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
                            AppStrings.confirm.tr(context),
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
            TextButton(
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
          ],
        ),
      ),
    );
  }
}
