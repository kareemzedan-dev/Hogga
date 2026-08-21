import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/localization/localization_cubit.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/shared/onBoarding/widgets/localized_app_logo.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: BlocBuilder<LocalizationCubit, Locale>(
                        builder: (context, locale) {
                          final isArabic = locale.languageCode == 'ar';
                          return _buildLanguageButton(
                            context,
                            label: isArabic ? 'English' : 'العربية',
                            onTap: () {
                              context.read<LocalizationCubit>().changeLanguage(
                                isArabic ? 'en' : 'ar',
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Hero(
                      tag: 'app_logo',
                      child: LocalizedAppLogo(
                        isDark: isDark,
                        imageHeight: 86.h,
                        imageWidth: 184.w,
                        fontSize: 44.sp,
                        textColor: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      AppStrings.welcomeSubtitle.tr(context),
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 54.h),
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
                    AppSizes.h(14),
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
                    SizedBox(height: 48.h),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.login),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: AppStrings.alreadyHaveAccount.tr(context),
                              style: context.text.bodySmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 13.sp,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: AppStrings.login.tr(context),
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: context.cardBg.withValues(alpha: context.isDark ? 0.65 : 1),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                color: context.colors.primary,
                size: 16.r,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
          decoration: BoxDecoration(
            color: context.mc.cardBg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: context.colors.primary.withValues(
                alpha: isDark ? 0.28 : 0.14,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.cream, size: 22.r),
                ),
              ),
              AppSizes.w(12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge?.copyWith(
                    color: isDark ? AppColors.cream : context.colors.primary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.colors.primary.withValues(alpha: 0.5),
                size: 13.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
