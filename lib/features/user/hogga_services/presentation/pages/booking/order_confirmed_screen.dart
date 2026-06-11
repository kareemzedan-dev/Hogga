import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/config/routes/app_routes.dart';

class OrderConfirmedScreen extends StatelessWidget {
  final String caseNumber;
  const OrderConfirmedScreen({super.key, required this.caseNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade700.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: Colors.green.shade400,
                ),
              ),
              AppSizes.h(32),
              Text(
                AppStrings.orderSentSuccessfully.tr(context),
                textAlign: TextAlign.center,
                style: context.text.titleLarge?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              AppSizes.h(12),
              Text(
                AppStrings.orderProcessingDesc.tr(context),
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                      color: context.textSecondary,
                      height: 1.6,
                    ),
              ),
              AppSizes.h(24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.divColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (caseNumber.isNotEmpty) ...[
                      Text(
                        caseNumber,
                        style: const TextStyle(
                          color: AppColors.golden,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      AppSizes.w(12),
                    ],
                    Text(
                      AppStrings.orderNumber.tr(context),
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to order details or tracking
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:  Text(
                    AppStrings.trackOrder.tr(context),
                    style: context.text.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              AppSizes.h(12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.divColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:  Text(
                    AppStrings.backToHome.tr(context),
                    style:context.text.bodyLarge,
                  ),
                ),
              ),
              AppSizes.h(24),
            ],
          ),
        ),
      ),
    );
  }
}
