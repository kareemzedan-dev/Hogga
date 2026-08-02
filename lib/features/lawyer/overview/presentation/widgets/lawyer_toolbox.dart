import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';

class LawyerToolbox extends StatelessWidget {
  const LawyerToolbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.professionalTools.tr(context),
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
          childAspectRatio: 1.25,
          children: [
            _buildToolItem(
              context,
              AppStrings.myClients.tr(context),
              Icons.people_alt_rounded,
              context.accentGolden,
              () => Navigator.pushNamed(context, AppRoutes.lawyerClients),
            ),

            _buildToolItem(
              context,
              AppStrings.myServices.tr(context),
              Icons.design_services_rounded,
              context.accentGolden,
              () => Navigator.pushNamed(context, AppRoutes.lawyerServices),
            ),
            _buildToolItem(
              context,
              AppStrings.documents.tr(context),
              Icons.folder_copy_rounded,
              Colors.blue,
              () => Navigator.pushNamed(context, AppRoutes.lawyerDocuments),
            ),
            _buildToolItem(
              context,
              AppStrings.legalLibrary.tr(context),
              Icons.menu_book_rounded,
              Colors.brown,
              () => Navigator.pushNamed(context, AppRoutes.lawyerLibrary),
            ),
            _buildToolItem(
              context,
              AppStrings.myTasks.tr(context),
              Icons.task_alt_rounded,
              Colors.teal,
              () => Navigator.pushNamed(context, AppRoutes.lawyerTasks),
            ),
            _buildToolItem(
              context,
              AppStrings.reports.tr(context),
              Icons.bar_chart_rounded,
              Colors.indigo,
              () => Navigator.pushNamed(context, AppRoutes.lawyerReports),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    final direction = Directionality.of(context);
    final arrowIcon = direction == TextDirection.rtl
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_forward_ios_rounded;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                context.cardBg,
                color.withValues(alpha: context.isDark ? 0.16 : 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: color.withValues(alpha: context.isDark ? 0.75 : 0.62),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: context.isDark ? 0.10 : 0.08),
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: isFullWidth
              ? Row(
                  children: [
                    _ToolIcon(icon: icon, color: color),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        label,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _ArrowBadge(arrowIcon: arrowIcon, color: color),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ToolIcon(icon: icon, color: color),
                        const Spacer(),
                        _ArrowBadge(arrowIcon: arrowIcon, color: color),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      label,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ToolIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.22 : 0.16),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }
}

class _ArrowBadge extends StatelessWidget {
  final IconData arrowIcon;
  final Color color;

  const _ArrowBadge({required this.arrowIcon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.18 : 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Icon(arrowIcon, color: color, size: 10.sp),
    );
  }
}
