import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String caseNumber;
  final int? caseId;
  final String? recordType;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.caseNumber,
    this.caseId,
    this.recordType,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _didNavigateToSuccess = false;
  bool _isHandlingPaymentFailure = false;
  bool _isCancelDialogVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = true;
            });
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
            });
            _checkUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // Assuming backend returns a URL containing 'success' or 'status=paid' on success
    // Modify these keywords if backend uses different return URLs
    if (lowerUrl.contains('success') ||
        lowerUrl.contains('status=paid') ||
        lowerUrl.contains('callback?status=1')) {
      _navigateToSuccess();
    } else if (lowerUrl.contains('fail') ||
        lowerUrl.contains('cancel') ||
        lowerUrl.contains('status=unpaid') ||
        lowerUrl.contains('callback?status=0')) {
      unawaited(_handlePaymentFailure());
    }
  }

  void _navigateToSuccess() {
    if (_didNavigateToSuccess || !mounted) {
      return;
    }
    _didNavigateToSuccess = true;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderConfirmed,
      (route) => false,
      arguments: {
        'caseNumber': widget.caseNumber,
        'caseId': widget.caseId,
        'recordType': widget.recordType,
      },
    );
  }

  Future<void> _onWillPop() async {
    final shouldLeave = await _showCancelDialog();
    if (shouldLeave == true && mounted) {
      _leavePayment();
    }
  }

  Future<void> _handlePaymentFailure() async {
    if (_isHandlingPaymentFailure || _didNavigateToSuccess || !mounted) {
      return;
    }

    _isHandlingPaymentFailure = true;
    try {
      final shouldLeave = await _showCancelDialog(isFromFailUrl: true);
      if (!mounted || _didNavigateToSuccess) {
        return;
      }

      if (shouldLeave == true) {
        _leavePayment();
      } else if (shouldLeave == false) {
        await _controller.loadRequest(Uri.parse(widget.paymentUrl));
      }
    } finally {
      _isHandlingPaymentFailure = false;
    }
  }

  void _leavePayment() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
    );
  }

  Future<bool?> _showCancelDialog({bool isFromFailUrl = false}) async {
    if (_isCancelDialogVisible || !mounted) {
      return null;
    }

    _isCancelDialogVisible = true;
    try {
      return await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierLabel:
            (isFromFailUrl
                    ? AppStrings.paymentFailedDialogTitle
                    : AppStrings.cancelPaymentDialogTitle)
                .tr(context),
        barrierColor: Colors.black.withValues(alpha: 0.62),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return PopScope(
            canPop: false,
            child: _PaymentCancelDialog(
              isPaymentFailed: isFromFailUrl,
              onContinue: () => Navigator.pop(dialogContext, false),
              onLeave: () => Navigator.pop(dialogContext, true),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.92,
                end: 1,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      );
    } finally {
      _isCancelDialogVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          title: Text(
            AppStrings.paymentScreenTitle.tr(context),
            style: const TextStyle(fontSize: 16),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onWillPop,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.golden),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCancelDialog extends StatelessWidget {
  final bool isPaymentFailed;
  final VoidCallback onContinue;
  final VoidCallback onLeave;

  const _PaymentCancelDialog({
    required this.isPaymentFailed,
    required this.onContinue,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        (isPaymentFailed
                ? AppStrings.paymentFailedDialogTitle
                : AppStrings.cancelPaymentDialogTitle)
            .tr(context);
    final description =
        (isPaymentFailed
                ? AppStrings.paymentFailedDialogMessage
                : AppStrings.cancelPaymentDialogMessage)
            .tr(context);
    final primaryText =
        (isPaymentFailed ? AppStrings.retry : AppStrings.continuePayment).tr(
          context,
        );
    final secondaryText =
        (isPaymentFailed ? AppStrings.backToHome : AppStrings.confirm).tr(
          context,
        );

    return Dialog(
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 420.w),
        padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isPaymentFailed
                ? context.warning.withValues(alpha: 0.32)
                : AppColors.error.withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: (isPaymentFailed ? context.warning : AppColors.error)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPaymentFailed
                    ? Icons.payment_rounded
                    : Icons.credit_card_off_rounded,
                size: 34.sp,
                color: isPaymentFailed ? context.warning : AppColors.error,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.textSecondary,
                fontSize: 11.sp,
                height: 1.55,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.golden,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  primaryText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: OutlinedButton(
                onPressed: onLeave,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isPaymentFailed
                      ? context.textSecondary
                      : AppColors.error,
                  backgroundColor: isPaymentFailed
                      ? Colors.transparent
                      : AppColors.error.withValues(alpha: 0.06),
                  side: BorderSide(
                    color: isPaymentFailed
                        ? context.divColor
                        : AppColors.error.withValues(alpha: 0.48),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
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
