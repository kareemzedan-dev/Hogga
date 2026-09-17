import 'package:hogga/core/theme/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar' ||
        Directionality.of(context) == TextDirection.rtl;

    return Center(
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isArabic
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            color: context.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
