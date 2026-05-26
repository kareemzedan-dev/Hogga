import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/widgets/update_dialog.dart';
import 'package:hogga/features/shared/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hogga/injection_container.dart';
import '../../../config/shared_preference/shared_preference.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    // Proceed directly to navigation as app config endpoint doesn't exist
    await Future.delayed(const Duration(seconds: 1)); // Small delay for smooth transition
    if (!mounted) return;
    _navigateNext();
  }

  bool _isUpdateRequired(String current, String minimum) {
    return _compareVersions(current, minimum) < 0;
  }

  bool _isUpdateAvailable(String current, String latest) {
    return _compareVersions(current, latest) < 0;
  }

  int _compareVersions(String v1, String v2) {
    final nums1 = v1.split('.').map(int.parse).toList();
    final nums2 = v2.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      if (nums1[i] > nums2[i]) return 1;
      if (nums1[i] < nums2[i]) return -1;
    }
    return 0;
  }

  void _showUpdateDialog(String message, String url, bool force) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => UpdateDialog(
        message: message,
        storeUrl: url,
        canCancel: !force,
      ),
    );
  }

  void _navigateNext() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final prefs = AppPreferences();
      String screen = AppRoutes.onBoarding;
      if (prefs.isLoggedIn) {
        screen = prefs.isProvider ? AppRoutes.lawyerDashboard : AppRoutes.main;
      }
      Navigator.pushReplacementNamed(context, screen);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final bgColor = isDark ? AppColors.primary : AppColors.cream;
    final fgColor = isDark ? AppColors.cream : AppColors.primary;
    final accentColor = AppColors.golden;

    return Scaffold(
      backgroundColor: bgColor,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      isDark ? AppAssets.hoggaDark : AppAssets.hoggaLight,
                      width: size.width * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.82),
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Text(
                    AppStrings.splashSubtitle.tr(context),
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: fgColor.withOpacity(0.55),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
