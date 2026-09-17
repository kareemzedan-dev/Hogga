import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'package:hogga/features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/user/notifications/presentation/widgets/notification_badge.dart';
import 'package:hogga/features/user/notifications/presentation/cubit/notifications_cubit.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final prefs = AppPreferences();
        String userName = prefs.name ?? '';
        String? avatarUrl = prefs.image;

        if (state is Authenticated) {
          userName = state.user.name;
          avatarUrl = state.user.image;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 12.h,
          ),
          color: Colors.transparent,
          child: Row(
            children: [
              // ── User avatar ──────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: _buildAvatar(context, avatarUrl),
              ),
              AppSizes.w(12),

              // ── Greeting ─────────────────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '👋 ${AppStrings.hello.tr(context)} ',
                            textAlign: TextAlign.start,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              userName,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppStrings.howCanWeHelp.tr(context),
                        textAlign: TextAlign.start,
                        style: context.text.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSizes.w(8),
              NotificationBadge(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                  context.read<NotificationsCubit>().getNotifications();
                },
                child: const _HeaderIconButton(icon: Icons.notifications_none_rounded),
              ),
              AppSizes.w(8),
              // TODO: Re-enable search button when ready
              /*
              _HeaderIconButton(icon: Icons.search_rounded, onTap: () {
                Navigator.pushNamed(context, AppRoutes.lawyerSearch);
              }),
              */
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 44.r,
          height: 44.r,
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
      radius: 22.r,
      backgroundColor: context.isDark
          ? AppColors.golden.withValues(alpha: 0.2)
          : AppColors.golden.withValues(alpha: 0.15),
      child: ClipOval(
        child: SvgPicture.asset(
          AppAssets.manLogo,
          fit: BoxFit.cover,
          width: 44.w,
          height: 44.h,
          colorFilter: ColorFilter.mode(
            context.isDark ? context.colors.primary : context.iconColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: context.cardBg,
          shape: BoxShape.circle,
          border: Border.all(color: context.divColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, color: context.iconColor, size: 22.sp),
      ),
    );
  }
}
