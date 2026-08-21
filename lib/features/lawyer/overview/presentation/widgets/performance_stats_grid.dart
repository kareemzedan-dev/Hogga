import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';

class PerformanceStatsGrid extends StatelessWidget {
  final LawyerOverview overview;

  const PerformanceStatsGrid({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.performanceOverview.tr(context),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.18,
          children: [
            _buildGridStatCard(
              context,
              AppStrings.monthlyIncome.tr(context),
              '${overview.monthlyIncome} ${AppStrings.currencySymbol.tr(context)}',
              Icons.payments_rounded,
              context.success,
            ),
            _buildGridStatCard(
              context,
              AppStrings.activeCasesLabel.tr(context),
              overview.ongoingCases.toString(),
              Icons.gavel_rounded,
              context.accentGolden,
            ),
            _buildGridStatCard(
              context,
              AppStrings.totalBookings.tr(context),
              overview.totalBookings.toString(),
              Icons.event_available_rounded,
              context.colors.primary,
            ),
            _buildGridStatCard(
              context,
              AppStrings.clientsRating.tr(context),
              overview.rating.toString(),
              Icons.star_rounded,
              context.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.isDark
            ? context.cardBg.withValues(alpha: 0.72)
            : context.colors.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: context.divColor.withValues(
            alpha: context.isDark ? 0.45 : 0.38,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          const Spacer(),
          Text(
            value,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
              fontSize: 15.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: context.textSecondary,
              fontSize: 9.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
