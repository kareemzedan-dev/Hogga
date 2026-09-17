import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String phone;
  const CreatePasswordScreen({super.key, required this.phone});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        AppRoutes.registerDetails,
        arguments: {
          'phone': widget.phone,
          'password': _passwordController.text,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.of(context)?.locale.languageCode == 'en';
    return AuthLayout(
      title: AppStrings.passwordStepTitle.tr(context),
      subtitle: isEn
          ? 'Create a secure password for your account'
          : 'أنشئ كلمة مرور قوية لتأمين حسابك',
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
              controller: _confirmController,
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
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDFBF7A),
                  foregroundColor: const Color(0xFF1B0F08),
                  elevation: 4,
                  shadowColor: const Color(0xFFDFBF7A).withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  AppStrings.next.tr(context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B0F08),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
