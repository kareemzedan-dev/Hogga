import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_status_badge.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_info_row.dart';
import 'package:hogga/core/utils/extensions.dart';

class CaseCard extends StatelessWidget {
  final LawyerCase lawyerCase;

  const CaseCard({super.key, required this.lawyerCase});

  @override
  Widget build(BuildContext context) {
    return HoggaCard(
      color: context.cardBg,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.lawyerCaseDetails,
          arguments: {'id': lawyerCase.id, 'title': lawyerCase.title},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LawyerStatusBadge(text: lawyerCase.statusText.toLocalizedStatus(context)),
              Text(
                lawyerCase.realCaseNumber,
                style: context.text.labelSmall?.copyWith(color: context.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            lawyerCase.title,
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: LawyerInfoRow(icon: Icons.calendar_today_outlined, label: AppStrings.date.tr(context), value: lawyerCase.date)),
              const SizedBox(width: 8),
              Expanded(child: LawyerInfoRow(icon: Icons.location_on_outlined, label: AppStrings.courtLabel.tr(context), value: lawyerCase.court ?? '')),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: LawyerInfoRow(
                  icon: Icons.person_outline,
                  label: AppStrings.client.tr(context),
                  value: lawyerCase.clientName,
                ),
              ),
              Expanded(
                child: LawyerInfoRow(
                  icon: Icons.gavel_outlined,
                  label: AppStrings.caseDetails.tr(context),
                  value: lawyerCase.descriptionSnippet ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
