import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

class LawyerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? color;
  final bool showBorder;

  const LawyerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.onTap,
    this.color,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: context.isDark ? ImageFilter.blur(sigmaX: 25, sigmaY: 25) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color:  context.cardBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: context.isDark? Border.all(color:context.divColor, width: 1.0) : Border.all(color:context.colors.primary.withOpacity(0.6), width: 1.0),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
