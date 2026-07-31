import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/theme/theme_cubit.dart';
import 'package:hogga/core/localization/localization_cubit.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/features/user/profile/presentation/cubit/profile_cubit.dart';
import 'package:hogga/features/user/profile/presentation/cubit/profile_state.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/widgets/logout_confirmation_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LawyerSettingsScreen extends StatelessWidget {
  const LawyerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          title: Text(
            AppStrings.settings.tr(context),
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              AppSnackbar.showError(context, message: state.message);
            } else if (state is ProfileAvatarUpdateSuccess) {
              AppSnackbar.showSuccess(
                context,
                messageKey: AppStrings.profileUpdatedSuccessfully,
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return _buildShimmer(context);
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(context, state),
                    const SizedBox(height: 32),
                    _buildSettingsGroup(
                      context,
                      AppStrings.prefsAndApp.tr(context),
                      [
                        _buildThemeToggle(context),
                        _buildDivider(context),
                        _buildLanguageToggle(context),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CustomShimmer.circular(width: 110, height: 110),
            const SizedBox(height: 16),
            CustomShimmer.rectangular(height: 24, width: 150),
            const SizedBox(height: 8),
            CustomShimmer.rectangular(height: 16, width: 100),
            const SizedBox(height: 40),
            CustomShimmer.rectangular(height: 150),
            const SizedBox(height: 32),
            CustomShimmer.rectangular(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    final isUpdating = state is ProfileAvatarUpdating;

    // Read image reactively from state, fallback to prefs
    String? image;
    if (state is ProfileLoaded) {
      image = state.user.image;
    } else if (state is ProfileAvatarUpdateSuccess) {
      image = state.user.image;
    } else if (state is ProfileUpdating) {
      image = state.user.image;
    } else {
      image = AppPreferences().image;
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.read<ProfileCubit>().updateAvatar(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.accentGolden.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.accentGolden, width: 2),
                    image: DecorationImage(
                      image: image != null && image.isNotEmpty
                          ? CachedNetworkImageProvider(image) as ImageProvider
                          : const AssetImage(AppAssets.userPlaceholder)
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.accentGolden.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: isUpdating
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: context.accentGolden,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.pageBg, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt_rounded,
                          color: context.isDark
                              ? AppColors.primary
                              : Colors.white,
                          size: 18.sp,
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppPreferences().name ?? "-",
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AppStrings.licensedLawyer.tr(context),
          style: context.text.bodySmall?.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 12),
          child: Text(
            title,
            style: context.text.titleSmall?.copyWith(
              color: context.accentGolden,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.divColor),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(height: 1, indent: 64, color: context.divColor);
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.isDark ? context.divColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: context.textSecondary,
              size: 20,
            ),
          ),
          title: Text(
            AppStrings.darkMode.tr(context),
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              context.read<ThemeCubit>().toggleTheme(value);
            },
            activeThumbColor: context.colors.onPrimary,
            activeTrackColor: context.accentGolden,
            inactiveThumbColor: context.colors.onPrimary,
            inactiveTrackColor: Colors.grey.shade300,
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
          onTap: () {
            context.read<LocalizationCubit>().changeLanguage(
              isAr ? 'en' : 'ar',
            );
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.isDark ? context.divColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.language_rounded,
              color: context.textSecondary,
              size: 20,
            ),
          ),
          title: Text(
            AppStrings.language.tr(context),
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.accentGolden.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isAr
                  ? AppStrings.arabic.tr(context)
                  : AppStrings.english.tr(context),
              style: context.text.labelSmall?.copyWith(
                color: context.accentGolden,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showLogoutConfirmationSheet(context),
        icon: Icon(Icons.logout_rounded, color: context.colors.error),
        label: Text(
          AppStrings.logout.tr(context),
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: context.colors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
