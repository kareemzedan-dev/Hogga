import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';

class ProposalCard extends StatelessWidget {
  final LawyerProposal proposal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return HoggaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.caseNumberLabel.tr(context)}: ${proposal.legalCase.caseNumber}',
                style: context.text.bodySmall?.copyWith(
                  color: context.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
              _buildStatusBadge(context, proposal.status),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            proposal.legalCase.title,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            proposal.legalCase.categoryName,
            style: context.text.bodySmall?.copyWith(
              color: context.accentGolden,
              fontSize: 10.5.sp,
            ),
          ),
          Divider(height: 20.h),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 16.sp,
                color: context.accentGolden,
              ),
              SizedBox(width: 6.w),
              Text(
                AppStrings.proposalPrice.tr(context),
                style: context.text.bodySmall?.copyWith(
                  color: context.textSecondary,
                  fontSize: 10.5.sp,
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.priceWithCurrency.tr(
                  context,
                  namedArgs: {'price': proposal.price},
                ),
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          Text(
            proposal.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              height: 1.4,
              fontSize: 10.5.sp,
            ),
          ),
          Builder(
            builder: (context) {
              final normStatus = proposal.status.trim().toLowerCase();
              final isAccepted = normStatus == 'accepted' ||
                  normStatus == 'approved' ||
                  normStatus == 'مقبول';
              final isPending = (normStatus == 'pending' ||
                      normStatus == 'in_review' ||
                      normStatus == 'under_review' ||
                      normStatus.isEmpty) &&
                  !isAccepted;

              if (!isPending) return const SizedBox.shrink();

              return Column(
                children: [
                  Divider(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: Icon(Icons.edit_outlined, size: 15.sp),
                          label: Text(
                            AppStrings.edit.tr(context),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.primary,
                            side: BorderSide(color: context.colors.primary),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.remove_circle_outline_rounded,
                            size: 15.sp,
                          ),
                          label: Text(
                            AppStrings.cancelProposal.tr(context),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String text;
    final normStatus = status.trim().toLowerCase();

    switch (normStatus) {
      case 'accepted':
      case 'approved':
      case 'مقبول':
        color = Colors.green;
        text = AppStrings.accepted.tr(context);
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        text = AppStrings.rejected.tr(context);
        break;
      case 'pending':
      default:
        color = Colors.orange;
        text = AppStrings.pendingReview.tr(context);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 9.5.sp,
        ),
      ),
    );
  }
}
