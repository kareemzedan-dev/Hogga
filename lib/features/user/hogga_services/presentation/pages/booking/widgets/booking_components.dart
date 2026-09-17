import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

// ─── Step Progress Bar ─────────────────────────────────────────────────────────
class BookingStepProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const BookingStepProgressBar({super.key, required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < steps.length - 1 ? 6 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.golden
                          : (isActive ? AppColors.golden : context.divColor),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AppSizes.h(5),
                  Text(
                    steps[i].tr(context),
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      color: isActive 
                          ? AppColors.golden 
                          : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5E6D3) : context.textSecondary),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'Rubik',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Bottom Action Button ───────────────────────────────────────────────────────
class BookingBottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const BookingBottomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.pageBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? context.divColor : AppColors.golden,
          foregroundColor: const Color(0xFFF5E6D3),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? Shimmer.fromColors(
                baseColor: const Color(0xFFF5E6D3).withValues(alpha: 0.5),
                highlightColor: const Color(0xFFF5E6D3),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF5E6D3),
                    fontSize: 12.sp,
                    fontFamily: 'Rubik',
                  ),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF5E6D3),
                  fontSize: 12.sp,
                  fontFamily: 'Rubik',
                ),
              ),
      ),
    );
  }
}

// ─── Section Label ──────────────────────────────────────────────────────────────
class BookingFieldLabel extends StatelessWidget {
  final String text;
  const BookingFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.sp,
        color: context.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: 'Rubik',
      ),
    );
  }
}

// ─── Summary Row (Payment breakdown) ───────────────────────────────────────────
class SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  final bool isDiscount;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 13.sp : 11.5.sp,
              color: isTotal ? context.textPrimary : context.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Rubik',
            ),
          ),
          Text(
            '${value.abs().toStringAsFixed(2)} ${AppStrings.currency.tr(context)}',
            style: TextStyle(
              fontSize: isTotal ? 13.5.sp : 12.sp,
              color: isDiscount ? Colors.green : (isTotal ? AppColors.golden : context.textPrimary),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Rubik',
            ),
          ),
        ],
      ),
    );
  }
}
