import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class hoggaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? color;
  final bool showBorder;

  const hoggaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
    this.onTap,
    this.color,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? context.cardBg,
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: showBorder
              ? Border.all(
                  color: context.isDark
                      ? context.divColor
                      : context.colors.primary.withValues(alpha: 0.6),
                  width: 1.0.w,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}
