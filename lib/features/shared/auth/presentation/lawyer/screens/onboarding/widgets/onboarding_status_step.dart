import 'package:flutter/material.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

class OnboardingStatusStep extends StatelessWidget {
  const OnboardingStatusStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fact_check_rounded, size: 64, color: AppColors.golden),
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.applicationSentSuccess.tr(context),
              style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.applicationUnderReviewNotice.tr(context),
              style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.lawyerMain),
                child: Text(AppStrings.goToLawyerDashboard.tr(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
