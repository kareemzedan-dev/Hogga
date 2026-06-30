import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';
import '../theme/app_theme.dart';
import '../localization/app_localizations.dart';

class AppSnackbar {
  static void showError(BuildContext context, {String? messageKey, String? message}) {
    String displayMessage = '';
    if (message != null) {
      if (!message.contains(' ') && message.length > 2 && message[0].toLowerCase() == message[0]) {
        displayMessage = AppLocalizations.of(context)?.translate(message) ?? message;
      } else {
        displayMessage = message;
      }
    } else if (messageKey != null) {
      displayMessage = AppLocalizations.of(context)?.translate(messageKey) ?? '';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 24),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  displayMessage,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, {String? messageKey, String? message}) {
    String displayMessage = '';
    if (message != null) {
      if (!message.contains(' ') && message.length > 2 && message[0].toLowerCase() == message[0]) {
        displayMessage = AppLocalizations.of(context)?.translate(message) ?? message;
      } else {
        displayMessage = message;
      }
    } else if (messageKey != null) {
      displayMessage = AppLocalizations.of(context)?.translate(messageKey) ?? '';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  displayMessage,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(BuildContext context, {String? messageKey, String? message}) {
    final displayMessage = message ?? (messageKey != null ? AppLocalizations.of(context)!.translate(messageKey) : '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.golden.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              colors: [AppColors.golden, AppColors.golden.withValues(alpha: 0.8)],
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  displayMessage,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
