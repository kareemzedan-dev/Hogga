import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import '../../../../data/models/order_details.dart';

class ProposalCard extends StatelessWidget {
  final CaseProposal proposal;
  final bool isSelected;
  final bool canAccept;
  final VoidCallback onAccept;
  final VoidCallback onViewProfile;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onAccept,
    required this.onViewProfile,
    this.isSelected = false,
    this.canAccept = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAccepted = proposal.isAccepted;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isAccepted
            ? const Color(0xFF27AE60).withValues(alpha: 0.05)
            : isSelected
            ? AppColors.golden.withValues(alpha: 0.05)
            : context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF27AE60)
              : isSelected
              ? AppColors.golden
              : context.divColor,
          width: isAccepted || isSelected ? 1.5 : 1,
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
                  radius: 20.r,
                  backgroundColor: AppColors.golden.withValues(alpha: 0.1),
                  child:
                      proposal.lawyerPhoto != null &&
                          proposal.lawyerPhoto!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: proposal.lawyerPhoto!,
                            width: 40.r,
                            height: 40.r,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.golden,
                              size: 24.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.golden,
                          size: 24.sp,
                        ),
                ),
              ),
              AppSizes.w(10),
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
                        fontSize: 11.sp,
                      ),
                    ),
                    if ((proposal.lawyerExperience.isNotEmpty &&
                            proposal.lawyerExperience != '0' &&
                            proposal.lawyerExperience != 'null') ||
                        (proposal.lawyerRating.isNotEmpty &&
                            proposal.lawyerRating != '0' &&
                            proposal.lawyerRating != '0.0' &&
                            proposal.lawyerRating != 'null')) ...[
                      AppSizes.h(4),
                      Row(
                        children: [
                          if (proposal.lawyerExperience.isNotEmpty &&
                              proposal.lawyerExperience != '0' &&
                              proposal.lawyerExperience != 'null') ...[
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
                            AppSizes.w(10),
                          ],
                          if (proposal.lawyerRating.isNotEmpty &&
                              proposal.lawyerRating != '0' &&
                              proposal.lawyerRating != '0.0' &&
                              proposal.lawyerRating != 'null') ...[
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
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (proposal.isPaid) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF27AE60),
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppStrings.paidStatus.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: const Color(0xFF27AE60),
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          AppSizes.h(12),

          _buildDetailItem(
            context,
            AppStrings.proposalPrice.tr(context),
            AppStrings.priceWithCurrency.tr(
              context,
              namedArgs: {'price': proposal.price},
            ),
            Icons.payments_outlined,
            AppColors.golden,
          ),

          if (proposal.days.isNotEmpty &&
              proposal.days != '0' &&
              proposal.days != 'null') ...[
            AppSizes.h(10),
            _buildDetailItem(
              context,
              AppStrings.deliveryTime.tr(context),
              '${proposal.days} ${AppStrings.days.tr(context)}',
              Icons.access_time_rounded,
              Colors.blue,
            ),
          ],

          if (proposal.description.isNotEmpty) ...[
            AppSizes.h(12),
            Text(
              AppStrings.proposalDescription.tr(context),
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
            AppSizes.h(4),
            Text(
              proposal.description,
              style: context.text.bodySmall?.copyWith(
                color: context.textSecondary,
                height: 1.35,
              ),
            ),
          ],

          if (isAccepted || canAccept) AppSizes.h(12),

          // Actions
          if (isAccepted) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF27AE60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF27AE60),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.acceptedProposal.tr(context),
                    style: context.text.labelLarge?.copyWith(
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (canAccept) ...[
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 17.sp,
                  color: Colors.white,
                ),
                label: Text(
                  AppStrings.accept.tr(context),
                  style: context.text.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.golden,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
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
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
