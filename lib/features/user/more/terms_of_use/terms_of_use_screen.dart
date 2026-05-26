import 'package:hogga/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/utils/app_colors.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppbar(
        title: AppStrings.termsOfUseTitle.tr(context),
        backBtn: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.gavel_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              AppStrings.firstUserSection.tr(context),
              AppStrings.userObligations.tr(context),
              Icons.person_outline,
            ),
            _buildSection(
              context,
              AppStrings.secondProviderSection.tr(context),
              AppStrings.providerObligations.tr(context),
              Icons.storefront_outlined,
            ),
            _buildSection(
              context,
              AppStrings.thirdGeneralSection.tr(context),
              AppStrings.generalProvisions.tr(context),
              Icons.info_outline,
            ),
            _buildSection(
              context,
              AppStrings.cancellationPolicyTitle.tr(context),
              AppStrings.cancellationPolicyContent.tr(context),
              Icons.cancel_outlined,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                AppStrings.copyright.tr(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.isDark ? AppColors.golden : AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: context.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
