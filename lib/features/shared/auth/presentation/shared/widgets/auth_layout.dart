import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final bool showBack;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Arrow on right (RTL: appers on the right)
                  if (showBack)
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: context.textPrimary,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  // Placeholder for spacing
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Title + Subtitle ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.text.headlineLarge?.copyWith(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Content Area ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 32),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

