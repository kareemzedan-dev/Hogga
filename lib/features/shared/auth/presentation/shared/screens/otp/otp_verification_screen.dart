import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'dart:async';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/core/widgets/custom_button.dart';
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
    if (otp.length == 4) {
      context.read<AuthCubit>().verifyOtp(widget.phone, otp, isForReset: widget.isForReset);
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthVerified) {
            Navigator.pushNamed(context, AppRoutes.createPassword, arguments: widget.phone);
          } else if (state is AuthResetPasswordOtpVerified) {
            Navigator.pushReplacementNamed(context, AppRoutes.resetPassword, arguments: widget.phone);
          } else if (state is AuthError) {
            AppSnackbar.showError(context, message: state.message);
          } else if (state is AuthOperationSuccess) {
            AppSnackbar.showSuccess(context, message: state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    AppStrings.activationCode.tr(context),
                    textAlign: TextAlign.center,
                    style: context.text.headlineLarge?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // OTP Inputs
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 4,
                      controller: _otpController,
                      focusNode: _focusNode,
                      defaultPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: context.text.headlineMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.divColor),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: context.text.headlineMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.primary, width: 2),
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: context.text.headlineMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.divColor),
                        ),
                      ),
                      showCursor: true,
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.didNotReceiveCode.tr(context),
                            style: context.text.bodyMedium
                                ?.copyWith(color: context.textSecondary),
                          ),
                          TextButton(
                            onPressed: _timerSeconds == 0
                                ? () {
                                    context.read<AuthCubit>().resendOtp(widget.phone, 'register');
                                    setState(() => _timerSeconds = 120);
                                    _startTimer();
                                  }
                                : null,
                            child: Text(
                              _timerSeconds > 0
                                  ? '${AppStrings.resendAfter.tr(context)} $_timerSeconds ${AppStrings.seconds.tr(context)}'
                                  : AppStrings.resendNow.tr(context),
                              style: context.text.bodyMedium?.copyWith(
                                color: _timerSeconds > 0
                                    ? context.textSecondary
                                        .withValues(alpha: 0.3)
                                    : context.colors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: _timerSeconds == 0 ? TextDecoration.underline : TextDecoration.none,
                                decorationColor: context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onPressed: _verifyOtp,
                        isLoading: state is AuthLoading,
                        text: AppStrings.next.tr(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
