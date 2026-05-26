import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final bool showDropdownIcon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leadingIcon,
    this.showDropdownIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary.withValues(alpha: 0.1) : context.cardBg,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.divColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(leadingIcon,
                    size: 14.sp,
                    color: isSelected
                        ? context.colors.primary
                        : context.textSecondary),
              ),
            Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: isSelected
                    ? context.colors.primary
                    : context.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (showDropdownIcon && isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 14.sp, color: context.colors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
