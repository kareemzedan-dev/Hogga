import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  final String message;
  final String storeUrl;
  final bool canCancel;

  const UpdateDialog({
    super.key,
    required this.message,
    required this.storeUrl,
    this.canCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canCancel,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.system_update_rounded, color: context.accentGolden, size: 40.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                'تحديث جديد متاح',
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse(storeUrl)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    'تحديث الآن',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                ),
              ),
              if (canCancel) ...[
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('لاحقاً', style: TextStyle(color: context.textSecondary)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  final String message;

  const MaintenanceScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: context.accentGolden.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.handyman_rounded, color: context.accentGolden, size: 60.sp),
            ),
            SizedBox(height: 40.h),
            Text(
              'وضع الصيانة',
              style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(color: context.textSecondary, height: 1.5),
            ),
            SizedBox(height: 40.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: context.divColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'سنعود قريباً جداً',
                style: context.text.labelMedium?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
