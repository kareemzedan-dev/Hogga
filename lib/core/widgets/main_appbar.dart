import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? mainWidget;
  final bool backBtn;
  final double? appBarHeight;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const MainAppbar({
    super.key,
    this.appBarHeight,
    this.backgroundColor,
    this.title,
    this.backBtn = true,
    this.mainWidget,
    this.bottom,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    (appBarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl ||
        Localizations.localeOf(context).languageCode == 'ar';
    final bgColor =
        backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark;

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkBg ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkBg ? Brightness.dark : Brightness.light,
      ),
      bottom: bottom,
      actions: actions,
      leading: backBtn
          ? IconButton(
              onPressed: onBack ?? () => Navigator.maybePop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.textPrimary,
                size: 20.sp,
              ),
            )
          : null,
      title:
          mainWidget ??
          Text(
            title ?? '',
            style: context.text.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
    );
  }
}
