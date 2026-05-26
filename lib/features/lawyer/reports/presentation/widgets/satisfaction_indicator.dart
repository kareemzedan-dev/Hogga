import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

class SatisfactionIndicator extends StatelessWidget {
  final SatisfactionModel satisfaction;

  const SatisfactionIndicator({super.key, required this.satisfaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.clientSatisfaction.tr(context), style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 6.h),
        LawyerCard(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(satisfaction.formattedRating, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.accentGolden)),
                    Text(
                      AppStrings.basedOnEvaluations.tr(context, namedArgs: {'count': satisfaction.totalReviews.toString()}),
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: ((satisfaction.rating as num?)?.toDouble() ?? 0.0) / 5.0, 
                strokeWidth: 8.w, 
                color: context.accentGolden, 
                backgroundColor: context.divColor.withValues(alpha: 0.1)
              ),
            ],
          ),
        ),
      ],
    );
  }
}
