import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/features/shared/onBoarding/widgets/localized_app_logo.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? topAction;
  final bool showLogo;
  final EdgeInsetsGeometry? contentPadding;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.topAction,
    this.showLogo = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFF1B0F08),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background with Scale of Justice Watermark ───────────
          Image.asset(
            AppAssets.authBackground,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Subtle dark tint to ensure text clarity across all screens
          Container(
            color: Colors.black.withValues(alpha: 0.15),
          ),

          // ── Foreground Content ──────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Bar ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (shown if enabled)
                      if (showBack)
                        GestureDetector(
                          onTap: onBack ?? () => Navigator.maybePop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E1E14).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: const Color(0xFF5A3D28).withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                              Icons.chevron_right_rounded,

                                color: const Color(0xFFF5E8D0),
                                size: 22.r,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(width: 42.r),

                      // Optional Top Action (e.g., Language Switcher)
                      if (topAction != null)
                        topAction!
                      else
                        SizedBox(width: 42.r),
                    ],
                  ),
                ),

                // ── Header (Logo + Diamond Motif + Title + Subtitle) ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showLogo) ...[
                        SizedBox(height: 2.h),
                        Hero(
                          tag: 'app_logo',
                          child: LocalizedAppLogo(
                            isDark: true,
                            imageHeight: 34.h,
                            imageWidth: 88.w,
                            fontSize: 20.sp,
                            textColor: const Color(0xFFF5E8D0),
                          ),
                        ),
                        SizedBox(height: 7.h),

                        // Diamond motif divider under the logo
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28.w,
                              height: 1,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFFDEC396),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Transform.rotate(
                              angle: 0.785398, // 45 degrees
                              child: Container(
                                width: 4.r,
                                height: 4.r,
                                color: const Color(0xFFDEC396),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              width: 28.w,
                              height: 1,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFDEC396),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFF5E8D0),
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Rubik',
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFDEC396),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            fontFamily: 'Rubik',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Scrollable Body Content ───────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: contentPadding ??
                        EdgeInsets.symmetric(horizontal: 20.w),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

