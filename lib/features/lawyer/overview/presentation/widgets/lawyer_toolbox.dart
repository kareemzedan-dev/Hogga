import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';

class LawyerToolbox extends StatelessWidget {
  const LawyerToolbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.professionalTools.tr(context),
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.4,
          children: [
            _buildToolItem(context, AppStrings.myClients.tr(context), Icons.people_alt_rounded, context.accentGolden, () => Navigator.pushNamed(context, AppRoutes.lawyerClients)),

            _buildToolItem(context, AppStrings.myServices.tr(context), Icons.design_services_rounded, context.accentGolden, () => Navigator.pushNamed(context, AppRoutes.lawyerServices)),
            // _buildToolItem(context, AppStrings.documents.tr(context), Icons.folder_copy_rounded, Colors.blue, () => Navigator.pushNamed(context, AppRoutes.lawyerDocuments)),
            // _buildToolItem(context, AppStrings.legalLibrary.tr(context), Icons.menu_book_rounded, Colors.brown, () => Navigator.pushNamed(context, AppRoutes.lawyerLibrary)),
            _buildToolItem(context, AppStrings.myTasks.tr(context), Icons.task_alt_rounded, Colors.teal, () => Navigator.pushNamed(context, AppRoutes.lawyerTasks)),
            _buildToolItem(context, AppStrings.reports.tr(context), Icons.bar_chart_rounded, Colors.indigo, () => Navigator.pushNamed(context, AppRoutes.lawyerReports)),
          ],
        ),
      ],
    );
  }

  Widget _buildToolItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap, {bool isFullWidth = false}) {
    return LawyerCard(
      onTap: onTap,
      padding: EdgeInsets.all(12.w),
      child: isFullWidth 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32.sp),
              SizedBox(width: 12.w),
              Text(
                label,
                style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32.sp),
              SizedBox(height: 12.h),
              Text(
                label,
                style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 11.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
    );
  }
}
