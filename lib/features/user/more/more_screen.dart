import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/theme/theme_cubit.dart';
import 'package:hogga/core/localization/localization_cubit.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/widgets/custom_avatar.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/core/utils/extensions.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _isFingerprintEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.profile.tr(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              AppSizes.h(10),
              _buildProfileCard(context, isDark),
              AppSizes.h(20),
              _buildWalletAndSupport(context, isDark),
              AppSizes.h(24),
              _buildSettingsList(context, isDark),
              AppSizes.h(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDark) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final prefs = AppPreferences();
        String userName = prefs.name ?? '';
        String? avatarUrl = prefs.image;

        if (state is Authenticated) {
          userName = state.user.name;
          avatarUrl = state.user.image;
        }

        return HoggaCard(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: Row(
            children: [
              // Avatar
              _buildProfileAvatar(context, avatarUrl),
              AppSizes.w(12),
              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleLarge?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      prefs.phone ?? '',
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.w(16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 55,
          height: 55,
          fit: BoxFit.cover,
          placeholder: (_, __) => _defaultAvatar(context),
          errorWidget: (_, __, ___) => _defaultAvatar(context),
        ),
      );
    }
    return _defaultAvatar(context);
  }

  Widget _defaultAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 27.5,
      backgroundColor: context.isDark
          ? AppColors.golden.withValues(alpha: 0.2)
          : AppColors.golden.withValues(alpha: 0.15),
      child: SvgPicture.asset(
        AppAssets.manLogo,
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(
          context.isDark ? context.colors.primary : context.iconColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildWalletAndSupport(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(context, isDark,
            icon: Icons.headset_mic_outlined,
            title: AppStrings.support.tr(context),
            onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
          ),
        ),
        AppSizes.w(16),
        Expanded(
          child: _buildActionCard(context, isDark,
            icon: Icons.account_balance_wallet_outlined,
            title: AppStrings.wallet.tr(context),
            onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, bool isDark, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final cardBg = context.cardBg;
    return HoggaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
            Icon(icon, color: context.isDark ? AppColors.golden : context.iconColor, size: 28),
            AppSizes.h(12),
            Text(
              title,
              style: context.text.bodyMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSettingsList(BuildContext context, bool isDark) {
    final isDarkMode = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return HoggaCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Dark mode toggle
          _buildSettingsItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: (isDarkMode ? AppStrings.darkMode : AppStrings.lightMode).tr(context),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) {
                context.read<ThemeCubit>().toggleTheme(val);
              },
              activeThumbColor: AppColors.golden,
              inactiveTrackColor: AppColors.cream.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.cream,
            ),
          ),
          _buildDivider(),
          // _buildSettingsItem(
          //   context,
          //   icon: Icons.fingerprint,
          //   title: AppStrings.fingerprintLogin,
          //   trailing: Switch(
          //     value: _isFingerprintEnabled,
          //     onChanged: (val) => setState(() => _isFingerprintEnabled = val),
          //     activeThumbColor: AppColors.golden,
          //     inactiveTrackColor: AppColors.cream.withValues(alpha: 0.3),
          //     inactiveThumbColor: AppColors.cream,
          //   ),
          // ),
          _buildDivider(),
          _buildDivider(),
          _buildSettingsItem(context, icon: Icons.description_outlined, title: AppStrings.instructions.tr(context), onTap: () => Navigator.pushNamed(context, AppRoutes.instructions)),
          _buildDivider(),
          _buildSettingsItem(context, icon: Icons.info_outline_rounded, title: AppStrings.aboutApp.tr(context), onTap: () => Navigator.pushNamed(context, AppRoutes.aboutApp)),
          _buildDivider(),
          _buildSettingsItem(context, icon: Icons.privacy_tip_outlined, title: AppStrings.privacyPolicy.tr(context), onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy)),
          _buildDivider(),
          _buildSettingsItem(context, icon: Icons.star_border, title: AppStrings.rateAppStore.tr(context), onTap: () {}),
          _buildDivider(),
          BlocBuilder<LocalizationCubit, Locale>(
            builder: (context, locale) {
              final isAr = locale.languageCode == 'ar';
              return _buildSettingsItem(
                context,
                icon: Icons.language_outlined,
                title: AppStrings.changeLanguage.tr(context),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (isAr ? AppStrings.arabic : AppStrings.english).tr(context),
                      style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
                onTap: () {
                  context.read<LocalizationCubit>().changeLanguage(isAr ? 'en' : 'ar');
                },
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            icon: Icons.logout,
            title: AppStrings.logout.tr(context),
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            showArrow: false,
            onTap: () => _showLogoutSheet(context),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            icon: Icons.delete_forever_outlined,
            title: AppStrings.deleteAccount.tr(context),
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            showArrow: false,
            onTap: () => _showDeleteAccountSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? context.iconColor, size: 22),
            AppSizes.w(16),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: context.text.bodyMedium?.copyWith(
                  color: titleColor ?? context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...[
              AppSizes.w(12),
              trailing,
            ] else if (showArrow) ...[
              AppSizes.w(12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: context.textSecondary.withValues(alpha: 0.5),
              ).mirror(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: context.divColor, indent: 16, endIndent: 16);
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomConfirmationSheet(
        iconPath: AppAssets.logoutLogo,
        title: AppStrings.logoutTitle.tr(context),
        subtitle: AppStrings.logoutSubtitle.tr(context),
        actionText: AppStrings.logout.tr(context),
        onAction: () {
          AppPreferences().logout();
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
        },
      ),
    );
  }

  void _showDeleteAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomConfirmationSheet(
        iconPath: AppAssets.logoutLogo, // Reuse logout logo or find a delete one
        title: AppStrings.deleteAccountTitle.tr(context),
        subtitle: AppStrings.deleteAccountSubtitle.tr(context),
        actionText: AppStrings.deleteAccountAction.tr(context),
        onAction: () {
          // Implement delete account logic here
          AppPreferences().logout();
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
        },
      ),
    );
  }
}
