import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_language_button.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_phone_country_prefix.dart';
import '../../widgets/auth_text_field.dart';

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
    final isEn = AppLocalizations.of(context)?.locale.languageCode == 'en';
    return AuthLayout(
      title: AppStrings.whatsYourPhone.tr(context),
      subtitle: isEn
          ? 'Enter your phone number to continue and create an account'
          : 'أدخل رقم هاتفك للمتابعة وإنشاء الحساب',
      showBack: true,
      topAction: const AuthLanguageButton(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _phoneController,
              hint: '9212 3456',
              keyboardType: TextInputType.phone,
              validator: (v) => AppValidators.validatePhone(context, v),
              prefixIcon: const AuthPhoneCountryPrefix(),
              suffixIcon: Icon(
                Icons.smartphone_rounded,
                color: const Color(0xFFDEC396),
                size: 20.r,
              ),
            ),
            SizedBox(height: 32.h),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthOperationSuccess) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.otpVerification,
                    arguments: _phoneController.text.trim(),
                  );
                } else if (state is AuthError) {
                  AppSnackbar.showError(context, message: state.message);
                }
              },
              builder: (context, state) {
                return SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().resendOtp(
                                    _phoneController.text.trim(),
                                    'register',
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDFBF7A),
                      foregroundColor: const Color(0xFF1B0F08),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: state is AuthLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF23150C),
                              ),
                            ),
                          )
                        : Text(
                            AppStrings.next.tr(context),
                            style: TextStyle(
                              color: const Color(0xFF23150C),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Rubik',
                            ),
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: 28.h),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppStrings.alreadyHaveAccount.tr(context),
                        style: TextStyle(
                          color: const Color(0xFFBBA89B),
                          fontSize: 12.sp,
                          fontFamily: 'Rubik',
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: AppStrings.login.tr(context),
                        style: TextStyle(
                          color: const Color(0xFFDFBF7A),
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFDFBF7A),
                          fontFamily: 'Rubik',
                        ),
                      ),
                    ],
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
