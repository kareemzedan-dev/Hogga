import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/theme/theme_cubit.dart';
import 'package:hogga/core/localization/localization_cubit.dart';
import 'package:hogga/core/widgets/logout_confirmation_sheet.dart';
import 'package:hogga/core/widgets/main_appbar.dart';

class LawyerMoreScreen extends StatelessWidget {
  const LawyerMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.more.tr(context),
        backBtn: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: LawyerCard(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerWallet),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: context.accentGolden,
                              size: 28.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              AppStrings.lawyerWallet.tr(context),
                              textAlign: TextAlign.center,
                              style: context.text.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.accentGolden,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: LawyerCard(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerReferral),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.card_giftcard_rounded,
                              color: context.accentGolden,
                              size: 28.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              AppStrings.referralProgram.tr(context),
                              textAlign: TextAlign.center,
                              style: context.text.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.accentGolden,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            LawyerCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    AppStrings.myProposals.tr(context),
                    Icons.assignment_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.lawyerProposals),
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.mySpecializations.tr(context),
                    Icons.workspace_premium_rounded,
                    () => Navigator.pushNamed(context, AppRoutes.lawyerSpecializations),
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildThemeToggle(context),
                  Divider(height: 1, color: context.divColor),
                  _buildLanguageToggle(context),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.aboutApp.tr(context),
                    Icons.info_outline_rounded,
                    () => Navigator.pushNamed(context, AppRoutes.aboutApp),
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.privacyPolicy.tr(context),
                    Icons.privacy_tip_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.termsOfUseTitle.tr(context),
                    Icons.description_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.termsOfUse),
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.contactUs.tr(context),
                    Icons.headset_mic_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.contactUs),
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.deleteAccount.tr(context),
                    Icons.delete_forever_rounded,
                    () => showDeleteAccountConfirmationSheet(context),
                    isDestructive: true,
                  ),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(
                    context,
                    AppStrings.logout.tr(context),
                    Icons.logout_rounded,
                    () => showLogoutConfirmationSheet(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }



  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return ListTile(
          leading: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: context.accentGolden,
            size: 24.sp,
          ),
          title: Text(
            isDark
                ? AppStrings.darkMode.tr(context)
                : AppStrings.lightMode.tr(context),
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Switch.adaptive(
            value: isDark,
            activeThumbColor: context.accentGolden,
            activeTrackColor: context.accentGolden.withValues(alpha: 0.35),
            onChanged: (val) => context.read<ThemeCubit>().toggleTheme(val),
          ),
        );
      },
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return BlocBuilder<LocalizationCubit, Locale>(
      builder: (context, locale) {
        final isAr = locale.languageCode == 'ar';
        return ListTile(
          leading: Icon(
            Icons.language_rounded,
            color: context.accentGolden,
            size: 24.sp,
          ),
          title: Text(
            AppStrings.language.tr(context),
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Text(
            isAr ? 'العربية' : 'English',
            style: context.text.bodyMedium?.copyWith(
              color: context.accentGolden,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            final newLocale = isAr ? 'en' : 'ar';
            context.read<LocalizationCubit>().changeLanguage(newLocale);
          },
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final textColor = isDestructive ? context.colors.error : context.textPrimary;
    final iconColor = isDestructive ? context.colors.error : context.accentGolden;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 22.sp),
      title: Text(
        title,
        style: context.text.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
          fontSize: 13.sp,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.sp,
        color: isDestructive
            ? context.colors.error.withValues(alpha: 0.5)
            : context.accentGolden.withValues(alpha: 0.6),
      ).mirror(context),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final prefs = AppPreferences();
    final name = prefs.name ?? '';
    final phone = prefs.phone ?? '';
    final image = prefs.image ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: image.isNotEmpty
                ? CircleAvatar(
                    radius: 35.r,
                    backgroundColor: context.mc.chipBg,
                    backgroundImage: CachedNetworkImageProvider(image),
                  )
                : CircleAvatar(
                    radius: 35.r,
                    backgroundColor: context.mc.chipBg,
                    child: Icon(
                      Icons.person_rounded,
                      color: context.accentGolden,
                      size: 34.sp,
                    ),
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      size: 14.sp,
                      color: context.accentGolden,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      phone,
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                        fontSize: 12.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
