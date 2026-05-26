import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/auth_text_field.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/widgets/custom_button.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Header Logo/Text
            // Align(
            //   alignment: AlignmentDirectional.centerEnd,
            //   child: Text(
            //     AppStrings.appName.tr(context),
            //     style: context.text.headlineMedium?.copyWith(
            //       fontSize: 28.sp,
            //       fontWeight: FontWeight.w900,
            //       color: context.colors.primary,
            //       fontFamily: 'Rubik',
            //     ),
            //   ),
            // ),
            const SizedBox(height: 40),
            Text(
              AppStrings.whatsYourPhone.tr(context),
              style: context.text.headlineSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            AuthTextField(
              controller: _phoneController,
              hint: '9212 3456',
              keyboardType: TextInputType.phone,
              validator: (v) => AppValidators.validatePhone(context, v),
              prefixIcon: Container(
                width: 95.w,
                margin: EdgeInsetsDirectional.only(end: 8.w),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(14.r),
                    bottomStart: Radius.circular(14.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🇴🇲', style: TextStyle(fontSize: 18.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      '968+',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthOperationSuccess) {
                  Navigator.pushNamed(context, AppRoutes.otpVerification, arguments: _phoneController.text.trim());
                } else if (state is AuthError) {
                  AppSnackbar.showError(context, message: state.message);
                }
              },
              builder: (context, state) {
                return CustomButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthCubit>().resendOtp(_phoneController.text.trim(), 'register');
                    }
                  },
                  isLoading: state is AuthLoading,
                  text: AppStrings.login.tr(context),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: RichText(
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
          ],
        ),
      ),
    ),
  );
}
}
