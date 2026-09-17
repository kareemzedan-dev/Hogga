import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/subscription/data/models/subscription_summary_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final SubscriptionSummary? summary;
  final bool isLoading;

  const SubscriptionStatusCard({
    super.key,
    this.summary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LawyerCard(child: SizedBox(height: 92));
    }

    if (summary == null || summary!.planName.isEmpty || !summary!.isActive) {
      return _buildNoSubscriptionCard(context);
    }

    return _buildCurrentSubscriptionCard(context);
  }

  Widget _buildNoSubscriptionCard(BuildContext context) {
    return LawyerCard(
      padding: EdgeInsets.all(14.w),
      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerSubscription),
      child: Row(
        children: [
          _IconBadge(
            icon: Icons.workspace_premium_outlined,
            color: context.colors.error,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentSubscription.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppStrings.notActive.tr(context),
                  style: context.text.titleSmall?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppStrings.activateSubscriptionToStart.tr(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _ActionPill(
            label: AppStrings.activateNow.tr(context),
            color: context.accentGolden,
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context) {
    final data = summary!;
    final isFree = data.isDefaultFree;
    final isExpiring = data.isExpiringSoon;
    final statusColor = isExpiring
        ? context.warning
        : isFree
        ? context.accentGolden
        : context.success;
    final statusText = isExpiring
        ? AppStrings.subscriptionExpiringSoon.tr(context)
        : isFree
        ? AppStrings.defaultFreePackage.tr(context)
        : AppStrings.active.tr(context);
    final subtitle = isFree || data.endDate == null
        ? AppStrings.noExpiryDate.tr(context)
        : '${AppStrings.remainingDays.tr(context)}: ${data.remainingDays.clamp(0, 9999)} ${AppStrings.days.tr(context)}';

    return LawyerCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              statusColor.withValues(alpha: context.isDark ? 0.22 : 0.14),
              context.cardBg,
            ],
          ),
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBadge(
                  icon: isFree
                      ? Icons.card_giftcard_rounded
                      : Icons.verified_user_rounded,
                  color: statusColor,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.currentSubscription.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        data.planName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(
                          color: context.textPrimary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _InfoChip(
                  icon: Icons.circle,
                  label: statusText,
                  color: statusColor,
                ),
                _InfoChip(
                  icon: Icons.event_available_rounded,
                  label: subtitle,
                  color: context.accentGolden,
                ),
              ],
            ),
            if (data.canOpenPackages) ...[
              SizedBox(height: 12.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _PackagesButton(
                  color: statusColor,
                  onTap: () => _openPackagesLink(data.packageLink),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPackagesLink(String? link) async {
    final url = link?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11.sp),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: context.textPrimary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _ActionPill({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = filled ? context.textPrimary : color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PackagesButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _PackagesButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.packages.tr(context),
              style: context.text.labelSmall?.copyWith(
                color: context.textPrimary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              Icons.open_in_new_rounded,
              color: context.textPrimary,
              size: 13.sp,
            ),
          ],
        ),
      ),
    );
  }
}
