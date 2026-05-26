import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';

class MoreMenuItem extends StatelessWidget {
  final String assetPath;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;
  final bool isDelete;

  const MoreMenuItem({
    super.key,
    required this.assetPath,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = isLogout || isDelete;
    final Color highlightColor = AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.divColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                assetPath,
                width: 20,
                colorFilter: ColorFilter.mode(
                  isHighlighted ? highlightColor : AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AppSizes.w(16),
            Expanded(
              child: Text(
                title,
                style: context.text.bodyMedium?.copyWith(
                  color: isHighlighted ? highlightColor : context.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
