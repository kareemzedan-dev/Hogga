import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? stackWidget;
  final Widget? mainWidget;
  final bool backBtn;
  final double? appBarHeight;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;

  const MainAppbar({
    super.key,
    this.appBarHeight,
    this.backgroundColor,
    this.title,
    this.backBtn = true,
    this.mainWidget,
    this.bottom,
    this.stackWidget,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight ?? 80);

  @override
  Widget build(BuildContext context) {
    // Use provided background or fall back to theme's AppBar bg
    final bgColor =
        backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark;
    final buttonBg = context.cardBg;
    final buttonFg = context.textSecondary;

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 1,
      centerTitle: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkBg ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkBg ? Brightness.dark : Brightness.light,
      ),
      bottom: bottom,
      leading: Padding(
        padding: const EdgeInsets.all(11),
        child: GestureDetector(
          onTap: onBack ?? () => Navigator.pop(context),
          child: backBtn
              ? Container(
                  decoration: BoxDecoration(
                    color: buttonBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.divColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: buttonFg,
                      size: 15,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
      title:
          mainWidget ??
          Text(
            title ?? '',
            style: context.text.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }
}
