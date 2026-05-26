import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_sizes.dart';

class MoreLanguageToggle extends StatefulWidget {
  final bool initialIsArabic;
  final Function(bool) onLanguageChanged;

  const MoreLanguageToggle({
    super.key,
    required this.initialIsArabic,
    required this.onLanguageChanged,
  });

  @override
  State<MoreLanguageToggle> createState() => _MoreLanguageToggleState();
}

class _MoreLanguageToggleState extends State<MoreLanguageToggle> {
  late bool _isArabic;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialIsArabic;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.divColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: context.isDark ? 0.1 : 0.02), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              AppAssets.omanLogo,
              width: 20,
              colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn),
            ),
          ),
          AppSizes.w(12),
          Text(AppStrings.language.tr(context), style: context.text.bodyMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.primaryLight.withValues(alpha: 0.1) : AppColors.borderColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildToggleOption("En", !_isArabic),
                _buildToggleOption("Ar", _isArabic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _isArabic = label == "Ar");
        widget.onLanguageChanged(_isArabic);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: isSelected ? AppColors.cream : context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
