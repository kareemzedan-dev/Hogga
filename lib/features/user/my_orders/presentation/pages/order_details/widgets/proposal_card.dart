import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import '../../../../data/models/order_details.dart';

class ProposalCard extends StatelessWidget {
  final CaseProposal proposal;
  final bool isSelected;
  final VoidCallback onAccept;
  final VoidCallback onViewProfile;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onAccept,
    required this.onViewProfile,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.golden.withValues(alpha: 0.05)
            : context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? AppColors.golden : context.divColor,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: onViewProfile,
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: context.chipBg,
                  backgroundImage:
                      proposal.lawyerPhoto != null &&
                          proposal.lawyerPhoto!.isNotEmpty
                      ? CachedNetworkImageProvider(proposal.lawyerPhoto!)
                            as ImageProvider
                      : const AssetImage(AppAssets.userPlaceholder)
                            as ImageProvider,
                  child:
                      proposal.lawyerPhoto == null ||
                          proposal.lawyerPhoto!.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.golden.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.golden,
                            size: 24.sp,
                          ),
                        )
                      : null,
                ),
              ),
              AppSizes.w(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.lawyerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                    AppSizes.h(4),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 12.sp,
                          color: context.textSecondary,
                        ),
                        AppSizes.w(4),
                        Text(
                          '${proposal.lawyerExperience} ${AppStrings.years.tr(context)}',
                          style: context.text.labelSmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        AppSizes.w(12),
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.golden,
                          size: 14.sp,
                        ),
                        AppSizes.w(4),
                        Text(
                          proposal.lawyerRating,
                          style: context.text.labelSmall?.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.h(16),

          _buildDetailItem(
            context,
            AppStrings.deliveryTime.tr(context),
            '${proposal.days} ${AppStrings.days.tr(context)}',
            Icons.access_time_rounded,
            Colors.blue,
          ),

          AppSizes.h(16),

          // Cover Letter
          Text(
            AppStrings.proposalDescription.tr(context),
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          AppSizes.h(6),
          Text(
            proposal.description,
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary,
              height: 1.5,
            ),
          ),

          AppSizes.h(24),

          // Actions
          CustomButton(
            onPressed: onAccept,
            text: AppStrings.accept.tr(context),
            backgroundColor: AppColors.golden,
            textColor: Colors.white,
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        AppSizes.w(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: context.textSecondary,
                fontSize: 10.sp,
              ),
            ),
            Text(
              value,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
