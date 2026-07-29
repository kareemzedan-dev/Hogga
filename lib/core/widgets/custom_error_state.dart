import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';

class CustomErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const CustomErrorState({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final displayMessage = (message ?? AppStrings.noInternetConnection).tr(
      context,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60.sp,
                color: context.colors.error,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.error.tr(context),
              textAlign: TextAlign.center,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                AppStrings.retry.tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              style: TextButton.styleFrom(
                foregroundColor: context.accentGolden,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: context.accentGolden),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
