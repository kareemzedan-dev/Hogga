import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';
import 'package:hogga/config/routes/app_routes.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const int _codeLength = 4;
  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) _canResend = true;
      });
      return _resendCountdown > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _fullCode =>
      _controllers.map((c) => c.text).join();

  void _verify() {
    if (_fullCode.length == _codeLength) {
      context.read<AuthCubit>().verifyOtp(widget.email, _fullCode);
    }
  }

  void _resend() {
    if (!_canResend) return;
    context.read<AuthCubit>().resendOtp(widget.email, 'register');
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppStrings.activationCode.tr(context),
      subtitle: AppStrings.enterOtpSentTo.tr(context, namedArgs: {'email': widget.email}),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthVerified) {
            AppSnackbar.showSuccess(context, messageKey: AppStrings.verifiedSuccessfully);
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (r) => false);
          } else if (state is AuthError) {
            AppSnackbar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── OTP Boxes ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_codeLength, (i) {
                  return Container(
                    width: 60,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _focusNodes[i].hasFocus
                            ? context.colors.primary
                            : context.colors.primary.withOpacity(0.2),
                        width: _focusNodes[i].hasFocus ? 1.5 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: context.text.headlineMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < _codeLength - 1) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (v.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // ── Resend ────────────────────────────────────────
              GestureDetector(
                onTap: _canResend ? _resend : null,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${AppStrings.didNotReceiveCode.tr(context)}  ',
                        style: context.text.bodySmall?.copyWith(color: context.colors.primary.withOpacity(0.5)),
                      ),
                      TextSpan(
                        text: _canResend
                            ? AppStrings.resendCode.tr(context)
                            : AppStrings.resendIn.tr(context, namedArgs: {'seconds': '$_resendCountdown'}),
                        style: context.text.bodySmall?.copyWith(
                          color: _canResend
                              ? context.colors.primary
                              : context.colors.primary.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                          decoration: _canResend
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Verify Button ─────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: (state is AuthLoading ||
                          _fullCode.length < _codeLength)
                      ? null
                      : _verify,
                  child: state is AuthLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.onPrimary,
                          ))
                      : Text(AppStrings.next.tr(context)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
