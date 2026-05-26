import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/utils/app_colors.dart';



class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppbar(
        title: AppStrings.aboutUs.tr(context),
        backBtn: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 64,
                  color: context.colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.aboutUsDescription.tr(context),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              context,
              AppStrings.ourGoals.tr(context),
              AppStrings.ourGoalsContent.tr(context),
              Icons.track_changes_rounded,
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              AppStrings.whyZoneApp.tr(context),
              AppStrings.aboutUsContent.tr(context),
              Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                   const Icon(Icons.handshake_outlined, color: AppColors.cream, size: 32),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Text(
                       AppStrings.linkBetweenUserAndProvider.tr(context),
                       style: const TextStyle(
                         color: AppColors.cream,
                         fontSize: 14,
                         fontWeight: FontWeight.bold,
                         fontFamily: 'Rubik',
                       ),
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              AppStrings.copyright.tr(context),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
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
              Icon(icon, color: context.colors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.text.titleMedium?.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
