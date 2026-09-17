import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'dart:async';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final bool isForReset;
  const OTPScreen({super.key, required this.phone, this.isForReset = false});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _timerSeconds = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _verifyOtp() {
    final otp = _otpController.text;
    if (otp.length == 6) {
      context.read<AuthCubit>().verifyOtp(
        widget.phone,
        otp,
        isForReset: widget.isForReset,
      );
    } else {
      AppSnackbar.showError(context, messageKey: AppStrings.invalidOtp);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.of(context)?.locale.languageCode == 'en';
    return AuthLayout(
      title: AppStrings.otpCode.tr(context),
      subtitle: isEn
          ? 'Enter the 6-digit verification code sent to your phone'
          : 'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى هاتفك',
      showBack: true,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthVerified) {
            Navigator.pushNamed(
              context,
              AppRoutes.createPassword,
              arguments: widget.phone,
            );
          } else if (state is AuthResetPasswordOtpVerified) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.resetPassword,
              arguments: widget.phone,
            );
          } else if (state is AuthError) {
            AppSnackbar.showError(context, message: state.message);
          } else if (state is AuthOperationSuccess) {
            AppSnackbar.showSuccess(context, message: state.message);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),

              // ── 6-digit Pinput inputs ────────────────────────────
              Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    focusNode: _focusNode,
                    defaultPinTheme: PinTheme(
                      width: 48.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        color: const Color(0xFFF5E8D0),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rubik',
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF261810).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFF4A3425).withValues(alpha: 0.85),
                          width: 1.2,
                        ),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 48.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        color: const Color(0xFFF5E8D0),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rubik',
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF382317),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFDFBF7A),
                          width: 1.8,
                        ),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 48.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        color: const Color(0xFFF5E8D0),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rubik',
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF382317).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFDFBF7A).withValues(alpha: 0.8),
                          width: 1.2,
                        ),
                      ),
                    ),
                    showCursor: true,
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // ── Resend Code Block ────────────────────────────────
              Text(
                AppStrings.didNotReceiveCode.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFDEC396),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rubik',
                ),
              ),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: _timerSeconds == 0
                    ? () {
                        context.read<AuthCubit>().resendOtp(
                              widget.phone,
                              'register',
                            );
                        setState(() => _timerSeconds = 120);
                        _startTimer();
                      }
                    : null,
                child: Text(
                  _timerSeconds > 0
                      ? '${AppStrings.resendAfter.tr(context)} $_timerSeconds ${AppStrings.seconds.tr(context)}'
                      : AppStrings.resendNow.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _timerSeconds > 0
                        ? const Color(0xFFBBA89B)
                        : const Color(0xFFDFBF7A),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    decoration: _timerSeconds == 0
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: const Color(0xFFDFBF7A),
                    fontFamily: 'Rubik',
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ── Next CTA Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: state is AuthLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDFBF7A),
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
              ),
              SizedBox(height: 24.h),
            ],
          );
        },
      ),
    );
  }
}
