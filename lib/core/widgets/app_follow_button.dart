import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class AppFollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const AppFollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFollowing ? Icons.check : Icons.add,
              color: AppColors.cream,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isFollowing ? AppStrings.following.tr(context) : AppStrings.follow.tr(context),
            style: context.text.labelLarge?.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          ],
        ),
      ),
    );
  }
}
