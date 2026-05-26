import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? imagePath;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.imagePath,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: iconSize * 1.5,
                width: iconSize * 1.5,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.chipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize * 0.8,
                  color: context.textSecondary,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: TextStyle(
                      color: context.colors.onPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
