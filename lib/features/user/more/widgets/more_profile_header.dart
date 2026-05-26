import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/custom_avatar.dart';

class MoreProfileHeader extends StatelessWidget {
  const MoreProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleImageWithBorder(
          width: 55,
          height: 55,
          isBorder: false,
        ),
        AppSizes.w(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mahmoud Ahmed", // Placeholder or from user data
              style: context.text.titleMedium,
            ),
            Text(
              "tocaan@gmail.com",
              style: context.text.bodySmall?.copyWith(color: AppColors.grey),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: context.divColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.05), blurRadius: 10)
              ],
            ),
            child: Icon(Icons.edit, size: 20, color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
