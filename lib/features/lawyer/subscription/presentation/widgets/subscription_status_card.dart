import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/features/lawyer/subscription/data/models/subscription_summary_model.dart';
import 'package:hogga/config/routes/app_routes.dart';

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
      return Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: context.mc.chipBg,
          borderRadius: BorderRadius.circular(12.r),
        ),
      );
    }

    if (summary == null) {
      return _buildNoSubscriptionCard(context);
    }

    return _buildActiveState(context);
  }

  Widget _buildActiveState(BuildContext context) {
    final bool isExpiring = summary?.isExpiringSoon ?? false;
    final color = isExpiring ? context.warning : context.success;
    final icon = isExpiring ? Icons.timer_outlined : Icons.verified_user_rounded;
    final title = isExpiring 
        ? AppStrings.subscriptionExpiringSoon.tr(context) 
        : AppStrings.visibleToClients.tr(context);

    return _buildBaseSubscriptionCard(
      context: context,
      color: color,
      icon: icon,
      title: title,
      buttonText: isExpiring ? AppStrings.renew.tr(context) : AppStrings.manage.tr(context),
    );
  }

  Widget _buildNoSubscriptionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.mc.chipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: context.colors.error, size: 20.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.notActive.tr(context),
                style: context.text.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.error,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerSubscription),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.accentGolden, context.accentGolden.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: context.accentGolden.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    AppStrings.activateNow.tr(context),
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:context.textPrimary
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Text(
              AppStrings.activateSubscriptionToStart.tr(context),
              style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontSize: 10.sp),
            ),
          ),
          SizedBox(height: 12.h),

        ],
      ),
    );
  }

  Widget _buildBaseSubscriptionCard({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String title,
    required String buttonText,
  }) {
    final remaining = summary?.remainingConsultations ?? 0;
    final percentage = summary?.completionPercentage ?? 0.0;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.mc.chipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: context.text.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerSubscription),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    buttonText,
                    style: context.text.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary?.planName ?? '',
                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$remaining ${AppStrings.consultationLeft.tr(context)}',
                    style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
              SizedBox(
                width: 80.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),
                    backgroundColor: context.divColor,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
