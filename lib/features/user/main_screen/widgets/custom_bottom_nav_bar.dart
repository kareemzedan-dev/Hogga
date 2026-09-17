import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

import '../../../../core/utils/app_strings.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = context.isDark
        ? context.mc.textPrimary
        : AppColors.primary;
    final unselectedColor = context.isDark
        ? const Color(0xFF6B4C30)
        : const Color(0xFFA69470);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.isDark
                ? context.divColor.withValues(alpha: 0.3)
                : const Color(0xFFEADBCA),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.mc.navBarBg,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
              size: 26,
              color: selectedIndex == 0 ? selectedColor : unselectedColor,
            ),
            label: AppStrings.home.tr(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1
                  ? Icons.receipt_long_rounded
                  : Icons.receipt_long_outlined,
              size: 26,
              color: selectedIndex == 1 ? selectedColor : unselectedColor,
            ),
            label: AppStrings.myOrders.tr(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2
                  ? Icons.forum_rounded
                  : Icons.forum_outlined,
              size: 26,
              color: selectedIndex == 2 ? selectedColor : unselectedColor,
            ),
            label: AppStrings.chats.tr(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3
                  ? Icons.person_rounded
                  : Icons.person_outline_rounded,
              size: 26,
              color: selectedIndex == 3 ? selectedColor : unselectedColor,
            ),
            label: AppStrings.profile.tr(context),
          ),
        ],
      ),
    );
  }
}
