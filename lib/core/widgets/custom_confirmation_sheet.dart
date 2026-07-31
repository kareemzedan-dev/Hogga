import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class CustomConfirmationSheet extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onAction;
  final Color? actionColor;
  final Color? iconColor;

  const CustomConfirmationSheet({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onAction,
    this.actionColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final destructiveColor = actionColor ?? context.colors.error;
    final symbolColor = iconColor ?? destructiveColor;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: context.pageBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: context.divColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AppSizes.h(18),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: context.divColor.withValues(alpha: 0.45),
                    minimumSize: const Size(38, 38),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              AppSizes.h(4),
              SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: destructiveColor.withValues(alpha: 0.08),
                      ),
                    ),
                    Container(
                      width: 78,
                      height: 78,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: destructiveColor.withValues(alpha: 0.14),
                      ),
                      child: SvgPicture.asset(
                        iconPath,
                        colorFilter: ColorFilter.mode(
                          symbolColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.h(24),
              Text(
                title,
                style: context.text.titleLarge?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              AppSizes.h(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  subtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              AppSizes.h(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: destructiveColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              AppSizes.h(12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: context.divColor),
                    ),
                  ),
                  child: Text(
                    AppStrings.cancel.tr(context),
                    style: TextStyle(
                      color: context.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
