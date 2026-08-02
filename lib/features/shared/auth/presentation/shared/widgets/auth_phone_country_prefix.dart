import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';

class AuthPhoneCountryPrefix extends StatelessWidget {
  const AuthPhoneCountryPrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.w,
      margin: EdgeInsetsDirectional.only(end: 8.w),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(14.r),
          bottomStart: Radius.circular(14.r),
        ),
      ),
      child: Center(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '+968',
            style: context.text.bodyMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
