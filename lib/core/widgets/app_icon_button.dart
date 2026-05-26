import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';

class AppIconButton extends StatelessWidget {
  final String? svgAsset;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double radius;
  final double iconSize;
  final bool? isPrimary;

  const AppIconButton({
    super.key,
    this.svgAsset,
    this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.isPrimary = false,
    this.radius = 18,
    this.iconSize = 18,
  }) : assert(svgAsset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? (isPrimary == true ? context.colors.primary : context.cardBg);
    final fg = iconColor ?? (isPrimary == true ? context.colors.onPrimary : context.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: bg,
        radius: radius.r,
        child: svgAsset != null
            ? SvgPicture.asset(
                svgAsset!,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                width: iconSize.w,
              )
            : Icon(icon, color: fg, size: iconSize.sp),
      ),
    );
  }
}
