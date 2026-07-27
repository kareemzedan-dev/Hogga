import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';

Future<void> showCallSummaryDialog({
  required BuildContext context,
  required int usedSeconds,
  required VoidCallback onDone,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: AppStrings.callEnded.tr(context),
    barrierColor: Colors.black.withValues(alpha: 0.58),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _CallSummaryDialog(
        usedSeconds: usedSeconds,
        onDone: () {
          Navigator.of(dialogContext).pop();
          onDone();
        },
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _CallSummaryDialog extends StatelessWidget {
  final int usedSeconds;
  final VoidCallback onDone;

  const _CallSummaryDialog({required this.usedSeconds, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final durationText = _formatDuration(usedSeconds);
    final dark = context.isDark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 0.86.sw,
          padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: dark
                  ? const [Color(0xFF3B1E0E), Color(0xFF1F0E06)]
                  : const [Color(0xFFFFF6DD), Color(0xFFFDE5A5)],
            ),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.golden.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.36 : 0.14),
                blurRadius: 30,
                offset: Offset(0, 16.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82.w,
                height: 82.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.20),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error,
                    ),
                    child: Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                AppStrings.callEnded.tr(context),
                textAlign: TextAlign.center,
                style: context.text.titleLarge?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.golden.withValues(alpha: 0.20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      AppStrings.callDurationLabel.tr(context),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      durationText,
                      textDirection: TextDirection.ltr,
                      style: context.text.displaySmall?.copyWith(
                        color: AppColors.golden,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.cream,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.ok.tr(context),
                    style: context.text.titleMedium?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w800,
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

String _formatDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final hours = safeSeconds ~/ 3600;
  final minutes = (safeSeconds ~/ 60) % 60;
  final remainingSeconds = safeSeconds % 60;
  final minuteText = minutes.toString().padLeft(2, '0');
  final secondText = remainingSeconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:$minuteText:$secondText';
  }

  return '$minuteText:$secondText';
}
