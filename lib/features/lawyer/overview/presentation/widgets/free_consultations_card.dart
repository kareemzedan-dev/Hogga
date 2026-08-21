import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class FreeConsultationsCard extends StatelessWidget {
  final FreeConsultations? freeConsultations;

  const FreeConsultationsCard({super.key, this.freeConsultations});

  @override
  Widget build(BuildContext context) {
    if (freeConsultations == null) {
      return const SizedBox.shrink();
    }

    final data = freeConsultations!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.mc.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.accentGolden.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.handshake_rounded,
                      color: context.accentGolden,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        AppStrings.freeConsultations.tr(context),
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  AppStrings.yourConsultationPercentage.tr(context, namedArgs: {
                    'percentage': data.lawyerPercentage.toStringAsFixed(0),
                  }),
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildStatColumn(
                      context,
                      data.used.toString(),
                      AppStrings.used.tr(context),
                    ),
                    SizedBox(width: 20.w),
                    _buildStatColumn(
                      context,
                      data.remaining.toString(),
                      AppStrings.remaining.tr(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            height: 75.w,
            width: 75.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: data.limit == 0 ? 0 : data.used / data.limit,
                  strokeWidth: 6.w,
                  backgroundColor: context.accentGolden.withValues(alpha: 0.1),
                  color: context.accentGolden,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${data.used}/${data.limit}',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        AppStrings.remaining.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 8.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
