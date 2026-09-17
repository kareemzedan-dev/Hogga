import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/localization_cubit.dart';

class AuthLanguageButton extends StatelessWidget {
  const AuthLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';
        return GestureDetector(
          onTap: () {
            context.read<LocalizationCubit>().changeLanguage(
                  isArabic ? 'en' : 'ar',
                );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2E1E14).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: const Color(0xFF5A3D28).withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? 'English' : 'العربية',
                  style: TextStyle(
                    color: const Color(0xFFF5E8D0),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    fontFamily: 'Rubik',
                  ),
                ),
                SizedBox(width: 5.w),
                Icon(
                  Icons.language_rounded,
                  color: const Color(0xFFDEC396),
                  size: 15.r,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
