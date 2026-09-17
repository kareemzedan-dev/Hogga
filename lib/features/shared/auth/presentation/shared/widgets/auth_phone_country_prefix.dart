import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthPhoneCountryPrefix extends StatelessWidget {
  const AuthPhoneCountryPrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 48.h,
      margin: EdgeInsetsDirectional.only(end: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF382317),
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(15.r),
        ),
        border: BorderDirectional(
          end: BorderSide(
            color: const Color(0xFF4A3425).withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: Center(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '+968',
            style: TextStyle(
              color: const Color(0xFFF5E8D0),
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              fontFamily: 'Rubik',
            ),
          ),
        ),
      ),
    );
  }
}
