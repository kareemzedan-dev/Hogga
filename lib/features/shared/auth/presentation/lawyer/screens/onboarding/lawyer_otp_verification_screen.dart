import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';
import 'package:hogga/features/shared/auth/presentation/lawyer/cubit/lawyer_registration_cubit.dart';

class LawyerOtpVerificationScreen extends StatefulWidget {
  final String phone;
  const LawyerOtpVerificationScreen({super.key, required this.phone});

  @override
  State<LawyerOtpVerificationScreen> createState() =>
      _LawyerOtpVerificationScreenState();
}

class _LawyerOtpVerificationScreenState
    extends State<LawyerOtpVerificationScreen> {
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
      context.read<LawyerRegistrationCubit>().verifyOtp(widget.phone, otp);
    } else {
      AppSnackbar.showError(context, messageKey: AppStrings.invalidOtp);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
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
      body: BlocConsumer<LawyerRegistrationCubit, LawyerRegistrationState>(
        listenWhen: (previous, current) =>
            !previous.isPhoneVerified && current.isPhoneVerified,
        listener: (context, state) {
          if (state.isPhoneVerified && state.verifiedPhone == widget.phone) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                const SizedBox(height: 8),
                Text(
                  AppStrings.enterVerificationCode.tr(
                    context,
                    namedArgs: {'phone': widget.phone},
                  ),
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 60),
                // OTP Inputs
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 6,
                      controller: _otpController,
                      focusNode: _focusNode,
                      defaultPinTheme: PinTheme(
                        width: 46,
                        height: 56,
                        textStyle: context.text.headlineMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.divColor),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 46,
                        height: 56,
                        textStyle: context.text.headlineMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 46,
                        height: 56,
                        textStyle: context.text.headlineMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
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
                            style: context.text.bodyMedium?.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _timerSeconds == 0
                                ? () {
                                    context
                                        .read<LawyerRegistrationCubit>()
                                        .sendOtp(widget.phone);
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
                                    ? context.textSecondary.withValues(
                                        alpha: 0.3,
                                      )
                                    : context.colors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: _timerSeconds == 0
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationColor: context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onPressed: _verifyOtp,
                        isLoading: state.isVerifyingOtp,
                        text: AppStrings.verifyCodeButton.tr(context),
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
