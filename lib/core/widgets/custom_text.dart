import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isTitle;
  final bool isSecondary;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isTitle = false,
    this.isSecondary = false,
    this.fontSize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle = isTitle
        ? (context.text.titleMedium ?? const TextStyle())
        : (context.text.bodyMedium ?? const TextStyle());

    if (isSecondary) {
      baseStyle = baseStyle.copyWith(color: context.textSecondary);
    }

    final finalStyle = (style ?? baseStyle).copyWith(
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'Rubik',
    );

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
