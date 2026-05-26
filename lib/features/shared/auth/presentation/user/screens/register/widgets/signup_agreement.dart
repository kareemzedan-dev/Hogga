import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';

class SignupAgreement extends StatelessWidget {
  const SignupAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    final smallStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.grey,
    );
    final linkStyle = smallStyle?.copyWith(
      color: AppColors.cream,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.cream,
    );

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: smallStyle,
          children: [
            TextSpan(text: '${AppStrings.termsAgreementIntro.tr(context)} '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.termsOfUse),
                child: Text(
                  AppStrings.termsOfUseTitle.tr(context),
                  style: linkStyle,
                ),
              ),
            ),
            TextSpan(text: ' ${AppStrings.and.tr(context)} '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                child: Text(
                  AppStrings.privacyPolicy.tr(context),
                  style: linkStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
