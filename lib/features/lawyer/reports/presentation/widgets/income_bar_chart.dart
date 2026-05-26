import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

class IncomeBarChart extends StatelessWidget {
  final List<IncomeChartItemModel> data;

  const IncomeBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVal = data.map((e) => (e.value as num?)?.toDouble() ?? 0.0).reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal * 1.2).clamp(100.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.consultationIncome.tr(context),
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6.h),
        LawyerCard(
          padding: EdgeInsets.fromLTRB(10.w, 30.h, 25.w, 10.h),
          child: SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.accentGolden,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}',
                        context.text.labelSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.bold, fontSize: 10.sp) ?? const TextStyle(),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(data[value.toInt()].label, style: context.text.labelSmall?.copyWith(fontSize: 9.sp)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, 
                      reservedSize: 35.w, 
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: context.text.labelSmall?.copyWith(fontSize: 8.sp))
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return _makeGroupData(entry.key, (entry.value.value as num?)?.toDouble() ?? 0.0, context.accentGolden, maxY);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color, double maxY) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14.w,
          borderRadius: BorderRadius.circular(4.r),
          backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: color.withValues(alpha: 0.1)),
        ),
      ],
    );
  }
}
