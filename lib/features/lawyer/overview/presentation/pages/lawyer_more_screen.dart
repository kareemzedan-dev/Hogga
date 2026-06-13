import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/overview/presentation/cubit/lawyer_overview_cubit.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import 'package:hogga/core/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/theme/theme_cubit.dart';
import 'package:hogga/core/localization/localization_cubit.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';

import 'package:hogga/features/lawyer/subscription/presentation/widgets/account_status_tile.dart';
import 'package:hogga/injection_container.dart';

class LawyerMoreScreen extends StatelessWidget {
  const LawyerMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.more.tr(context),
          style: context.theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            SizedBox(height: 24.h),

            LawyerCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // AccountStatusTile hidden - can be re-enabled when needed
                  // const AccountStatusTile(),
                  // Divider(height: 1, color: context.divColor),
                  _buildThemeToggle(context),
                  Divider(height: 1, color: context.divColor),
                  _buildLanguageToggle(context),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(context, AppStrings.aboutApp.tr(context), Icons.info_outline_rounded, () => Navigator.pushNamed(context, AppRoutes.aboutApp)),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(context, AppStrings.privacyPolicy.tr(context), Icons.privacy_tip_outlined, () => Navigator.pushNamed(context, AppRoutes.privacyPolicy)),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(context, AppStrings.termsOfUseTitle.tr(context), Icons.description_outlined, () => Navigator.pushNamed(context, AppRoutes.termsOfUse)),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(context, AppStrings.contactUs.tr(context), Icons.headset_mic_outlined, () => Navigator.pushNamed(context, AppRoutes.contactUs)),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(context, AppStrings.deleteAccount.tr(context), Icons.delete_forever_rounded, () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CustomConfirmationSheet(
                        iconPath: AppAssets.logoutLogo,
                        title: AppStrings.deleteAccountTitle.tr(context),
                        subtitle: AppStrings.deleteAccountSubtitle.tr(context),
                        actionText: AppStrings.deleteAccountAction.tr(context),
                        onAction: () async {
                          // TODO: Call delete account API when available
                          await AppPreferences().logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
                          }
                        },
                      ),
                    );
                  }, isDestructive: true),
                  Divider(height: 1, color: context.divColor),
                  _buildListTile(context, AppStrings.logout.tr(context), Icons.logout_rounded, () async {
                    await AppPreferences().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
                    }
                  }, isDestructive: true),
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
          leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: context.accentGolden, size: 24.sp),
          title: Text(isDark ? AppStrings.darkMode.tr(context) : AppStrings.lightMode.tr(context), style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          trailing: Switch.adaptive(
            value: isDark,
            activeColor: context.accentGolden,
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
          leading: Icon(Icons.language_rounded, color: context.accentGolden, size: 24.sp),
          title: Text(AppStrings.language.tr(context), style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          trailing: Text(
            isAr ? 'العربية' : 'English',
            style: context.text.bodyMedium?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            final newLocale = isAr ? 'en' : 'ar';
            context.read<LocalizationCubit>().changeLanguage(newLocale);
          },
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? context.colors.error : context.textPrimary;
    final iconColor = isDestructive ? context.colors.error : context.iconColor;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 24.sp),
      title: Text(title, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: isDestructive ? context.colors.error.withOpacity(0.5) : context.textSecondary).mirror(context),
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
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundColor: context.mc.chipBg,
              backgroundImage: image.isNotEmpty
                  ? CachedNetworkImageProvider(image) as ImageProvider
                  : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.phone_android_rounded, size: 14.sp, color: context.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      phone,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textSecondary,
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
