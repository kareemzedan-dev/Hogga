import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_strings.dart';

class LocalizedAppLogo extends StatelessWidget {
  const LocalizedAppLogo({
    super.key,
    required this.isDark,
    this.imageWidth,
    this.imageHeight,
    this.fontSize = 44,
    this.textColor,
  });

  final bool isDark;
  final double? imageWidth;
  final double? imageHeight;
  final double fontSize;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return Image.asset(
        isDark ? AppAssets.hoggaDark : AppAssets.hoggaLight,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.contain,
      );
    }

    return Text(
      AppStrings.appName.tr(context),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontFamily: 'Rubik',
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.4,
      ),
    );
  }
}
