import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_language_button.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_layout.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AuthLayout(
      title: AppStrings.welcomeTitle.tr(context),
      subtitle: AppStrings.welcomeSubtitle.tr(context),
      showBack: Navigator.canPop(context),
      topAction: const AuthLanguageButton(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),

          // ── Card 1: User Account ────────────────────────────────
          _buildRoleCard(
            context,
            isRtl: isRtl,
            title: AppStrings.registerAsUser.tr(context),
            subtitle: AppStrings.userCardSubtitle.tr(context),
            icon: Icons.person_rounded,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.phoneLogin,
                arguments: 'user',
              );
            },
          ),

          SizedBox(height: 14.h),

          // ── Card 2: Consultant / Lawyer Account ──────────────────
          _buildRoleCard(
            context,
            isRtl: isRtl,
            title: AppStrings.registerAsLawyer.tr(context),
            subtitle: AppStrings.lawyerCardSubtitle.tr(context),
            icon: Icons.gavel_rounded,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.lawyerOnboarding,
              );
            },
          ),

          SizedBox(height: 32.h),

          // ── Bottom Prompt: Already have account? Login ──────────
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppStrings.alreadyHaveAccount.tr(context),
                    style: TextStyle(
                      color: const Color(0xFFBBA89B),
                      fontSize: 12.sp,
                      fontFamily: 'Rubik',
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: AppStrings.login.tr(context),
                    style: TextStyle(
                      color: const Color(0xFFDFBF7A),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFFDFBF7A),
                      fontFamily: 'Rubik',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required bool isRtl,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF261810).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF4A3425).withValues(alpha: 0.85),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Icon container with higher contrast
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF382317),
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(
                    color: const Color(0xFF5A3D28).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: const Color(0xFFF5E8D0),
                    size: 21.r,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFF5E8D0),
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Rubik',
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFDEC396),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Forward arrow (auto-mirrored in RTL by Flutter)
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF382317).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFFDEC396),
                    size: 18.r,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
