import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import '../../data/models/package_model.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? context.accentGolden : context.divColor;
    final bgColor = isSelected 
        ? context.accentGolden.withValues(alpha: 0.05) 
        : context.pageBg;

    return GestureDetector(
      onTap: isCurrent ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCurrent)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                ),
                child: Text(
                  AppStrings.currentSubscription.tr(context),
                  textAlign: TextAlign.center,
                  style: context.text.labelMedium?.copyWith(
                    color: context.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? context.accentGolden : context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          package.subtitle,
                          style: context.text.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${package.price.toInt()} ${package.currency}',
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '/${package.durationDays} ${AppStrings.days.tr(context)}',
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.divColor),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildFeatureRow(
                    context,
                    AppStrings.freeConsultationsLimit.tr(context).replaceFirst('{}', package.entitlements.freeConsultationsLimit.toString()),
                  ),
                  _buildFeatureRow(
                    context,
                    AppStrings.consultationDurationLimit.tr(context).replaceFirst('{}', package.entitlements.consultationDurationLimitMinutes.toString()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: context.accentGolden, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: context.text.bodyMedium?.copyWith(color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
