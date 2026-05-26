import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/reports/presentation/cubit/lawyer_reports_cubit.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/injection_container.dart';

import 'package:hogga/features/lawyer/reports/presentation/widgets/income_bar_chart.dart';
import 'package:hogga/features/lawyer/reports/presentation/widgets/activity_summary_section.dart';
import 'package:hogga/features/lawyer/reports/presentation/widgets/satisfaction_indicator.dart';

class LawyerReportsScreen extends StatefulWidget {
  const LawyerReportsScreen({super.key});

  @override
  State<LawyerReportsScreen> createState() => _LawyerReportsScreenState();
}

class _LawyerReportsScreenState extends State<LawyerReportsScreen> {
  String _selectedPeriodKey = 'weekly';
  
  final Map<String, String> _periods = {
    'weekly': AppStrings.weekly,
    'monthly': AppStrings.monthly,
    'yearly': AppStrings.yearly,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LawyerReportsCubit>()..fetchReports(period: _selectedPeriodKey),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.pageBg,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: context.divColor.withValues(alpha: 0.5), width: 1)),
          title: Text(AppStrings.performanceReports.tr(context), style: context.theme.appBarTheme.titleTextStyle),
          centerTitle: true,
        ),
        body: BlocBuilder<LawyerReportsCubit, LawyerReportsState>(
          builder: (context, state) {
            if (state is LawyerReportsLoading) {
              return const LawyerShimmerLoading();
            } else if (state is LawyerReportsError) {
              return Center(child: Text(state.message.tr(context)));
            } else if (state is LawyerReportsLoaded) {
              final report = state.report;
              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildPeriodSelector(context),
                    SizedBox(height: 24.h),
                    IncomeBarChart(data: report.incomeChart),
                    SizedBox(height: 24.h),
                    ActivitySummarySection(summary: report.activitySummary),
                    SizedBox(height: 24.h),
                    SatisfactionIndicator(satisfaction: report.satisfaction),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.entries.map((entry) {
          final isSelected = _selectedPeriodKey == entry.key;
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: ChoiceChip(
              label: Text(entry.value.tr(context)),
              selected: isSelected,
              onSelected: (v) {
                if (v) {
                  setState(() => _selectedPeriodKey = entry.key);
                  context.read<LawyerReportsCubit>().fetchReports(period: entry.key);
                }
              },
              selectedColor: context.accentGolden,
              labelStyle: context.text.labelSmall?.copyWith(
                color: isSelected ? AppColors.cream : context.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: isSelected ? context.accentGolden : context.divColor)),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
