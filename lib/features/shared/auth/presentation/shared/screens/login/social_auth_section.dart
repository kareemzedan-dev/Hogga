import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';

class SocialAuthSection extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onGoogleTap;

  const SocialAuthSection({
    super.key, 
    required this.isLogin, 
    required this.onGoogleTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSizes.h(8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
            ),
            onPressed: onGoogleTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (isLogin ? AppStrings.loginWithGoogle : AppStrings.registerWithGoogle).tr(context),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSizes.w(8),
                SvgPicture.asset(
                  AppAssets.googleLogo,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
