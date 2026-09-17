import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/localization/app_localizations.dart';

import 'package:hogga/core/widgets/app_snakbar.dart';

import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_language_button.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_phone_country_prefix.dart';
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
      showBack: false,
      topAction: const AuthLanguageButton(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(
              context,
              state.user.isProvider ? AppRoutes.lawyerMain : AppRoutes.main,
            );
          } else if (state is AuthNeedVerification) {
            Navigator.pushNamed(
              context,
              AppRoutes.verifyEmail,
              arguments: state.email,
            );
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
                // ── Phone Input ──────────────────────────────────
                AuthTextField(
                  hint: AppStrings.phone.tr(context),
                  controller: _emailController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const AuthPhoneCountryPrefix(),
                  suffixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(end: 14.w),
                    child: Icon(
                      Icons.smartphone_rounded,
                      color: const Color(0xFFDEC396),
                      size: 20.r,
                    ),
                  ),
                  validator: (v) => AppValidators.validatePhone(context, v),
                ),
                SizedBox(height: 16.h),

                // ── Password Input ───────────────────────────────
                AuthTextField(
                  hint: AppStrings.password.tr(context),
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Container(
                    width: 48.w,
                    height: 48.h,
                    margin: EdgeInsetsDirectional.only(end: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF382317),
                      borderRadius: BorderRadiusDirectional.horizontal(
                        start: Radius.circular(15.r),
                      ),
                      border: BorderDirectional(
                        end: BorderSide(
                          color: const Color(0xFF4A3425).withValues(alpha: 0.8),
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: const Color(0xFFF5E8D0),
                        size: 19.r,
                      ),
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(end: 6.w),
                    child: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFFDEC396),
                        size: 20.r,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  validator: (v) => AppValidators.validatePassword(context, v),
                ),
                SizedBox(height: 12.h),

                // ── Forgot password ──────────────────────────────
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.forgotPassword.tr(context),
                      style: TextStyle(
                        color: const Color(0xFFDEC396),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFDEC396),
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Login CTA Button ─────────────────────────────
                SizedBox(
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _login,
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
                            AppStrings.login.tr(context),
                            style: TextStyle(
                              color: const Color(0xFF23150C),
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Rubik',
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 22.h),

                // ── Signup prompt (Navigates to Account Selection) ──
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.welcome,
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppStrings.dontHaveAccount.tr(context),
                          style: TextStyle(
                            color: const Color(0xFFBBA89B),
                            fontSize: 11.sp,
                            fontFamily: 'Rubik',
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: AppStrings.register.tr(context),
                          style: TextStyle(
                            color: const Color(0xFFDFBF7A),
                            fontSize: 11.5.sp,
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
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
