import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final IconData? icon;
  final bool isSmall;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.width,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? (isOutlined ? Colors.transparent : context.colors.primary);
    
    // Determine the color for text/icons on a solid background
    Color defaultOnSolid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (backgroundColor == null || backgroundColor == context.colors.primary) {
      defaultOnSolid = context.colors.onPrimary;
    } else if (backgroundColor == context.colors.error || backgroundColor == AppColors.error) {
      defaultOnSolid = context.colors.onError;
    } else {
      defaultOnSolid = isDark ? AppColors.cream : Colors.white;
    }
    
    // For outlined buttons in dark mode, if no custom color is provided, use cream or primary
    final Color outlinedColor = isDark ? AppColors.cream : (backgroundColor ?? context.colors.primary);
    final effectiveTextColor = textColor ?? (isOutlined ? outlinedColor : defaultOnSolid);
    final effectiveFontSize = fontSize ?? (isSmall ? 11 : 13);

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveTextColor,
      disabledBackgroundColor: isLoading ? effectiveBackgroundColor : null,
      disabledForegroundColor: isLoading ? effectiveTextColor : null,
      elevation: isOutlined ? 0 : 2,
      shadowColor: isOutlined ? Colors.transparent : effectiveBackgroundColor.withValues(alpha: 0.3),
      padding: EdgeInsets.symmetric(
        vertical: (height ?? (isSmall ? 10 : 14)).h,
        horizontal: (width ?? 16).w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmall ? 10.r : 16.r),
        side: isOutlined
            ? BorderSide(color: backgroundColor ?? context.colors.primary, width: 1.5)
            : BorderSide.none,
      ),
    );

    Widget content = isLoading
        ? SizedBox(
            height: (isSmall ? 18 : 22).h,
            width: (isSmall ? 18 : 22).h,
            child: CircularProgressIndicator(
              color: effectiveTextColor,
              strokeWidth: 2.8,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: (isSmall ? 16 : 18).sp, color: effectiveTextColor),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontSize: effectiveFontSize.sp,
                      fontWeight: fontWeight ?? FontWeight.bold,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      width: width != null ? width!.w : (isSmall ? null : double.infinity),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
