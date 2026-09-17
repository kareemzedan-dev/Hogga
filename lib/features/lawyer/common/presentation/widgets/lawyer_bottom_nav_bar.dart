import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';

class LawyerBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const LawyerBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.pageBg,
        border: Border(
          top: BorderSide(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.3)
                : context.colors.primary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                0,
                Icons.dashboard_rounded,
                AppStrings.home.tr(context),
              ),
              _buildNavItem(
                context,
                1,
                Icons.business_center_rounded,
                AppStrings.services.tr(context),
              ),
              _buildNavItem(
                context,
                2,
                Icons.gavel_rounded,
                AppStrings.myCases.tr(context),
              ),
              _buildNavItem(
                context,
                3,
                Icons.support_agent_rounded,
                AppStrings.consultationsTab.tr(context),
              ),
              _buildNavItem(
                context,
                4,
                Icons.more_horiz_rounded,
                AppStrings.more.tr(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedIndex == index;
    final activeColor = context.accentGolden;
    final inactiveColor = context.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22.sp,
              ),
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: context.text.labelSmall?.copyWith(
                    color: isSelected ? activeColor : inactiveColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: isSelected ? 12.sp : 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
