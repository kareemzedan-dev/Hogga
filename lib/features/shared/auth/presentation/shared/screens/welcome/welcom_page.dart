import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hogga/core/utils/extensions.dart';
import '../../../../../../../config/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.pageBg,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding * 2),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      isDark ? 'assets/images/hoga_dark.png' : 'assets/images/hoga_light.png',
                      height: 100.h,
                      width: 200.w,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    AppStrings.welcomeSubtitle.tr(context),
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      color: context.textPrimary,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ─── Role Cards ─────────────────────────────────────
                  _buildRoleCard(
                    context,
                    title: AppStrings.registerAsUser.tr(context),
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.phoneLogin,
                        arguments: 'user',
                      );
                    },
                  ),

                  AppSizes.h(20),

                  _buildRoleCard(
                    context,
                    title: AppStrings.registerAsLawyer.tr(context),
                    icon: Icons.gavel_rounded,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.lawyerOnboarding,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ─── Login Link ─────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppStrings.alreadyHaveAccount.tr(context),
                            style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: AppStrings.login.tr(context),
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.r20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.p20.w, vertical: AppSizes.p24.h),
          decoration: BoxDecoration(
            color: context.mc.cardBg,
            borderRadius: BorderRadius.circular(AppSizes.r20),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  icon,
                  color: AppColors.cream,
                  size: 24.r,
                ),
              ),
              AppSizes.w(16),
              Expanded(
                child: Text(
                  title,
                  style: context.text.titleMedium?.copyWith(
                    color: isDark ? AppColors.cream : context.colors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.colors.primary.withValues(alpha: 0.5),
                size: 14.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
