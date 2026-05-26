import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

class ActivitySummarySection extends StatelessWidget {
  final ActivitySummaryModel summary;

  const ActivitySummarySection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.activitySummary.tr(context), style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(child: _buildReportStat(context, AppStrings.consultationsTab.tr(context), summary.totalConsultations.toString(), Icons.chat_bubble_outline, Colors.blue)),
            SizedBox(width: 12.w),
            Expanded(child: _buildReportStat(context, AppStrings.completedCases.tr(context), summary.completedCases.toString(), Icons.check_circle_outline, Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildReportStat(BuildContext context, String label, String val, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg, 
        borderRadius: BorderRadius.circular(16.r), 
        border: Border.all(color: context.divColor.withValues(alpha: 0.3))
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8.h),
          Text(val, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
        ],
      ),
    );
  }
}
