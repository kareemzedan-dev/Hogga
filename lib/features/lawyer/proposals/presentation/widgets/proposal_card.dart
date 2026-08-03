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
                ),
              ),
              _buildStatusBadge(context, proposal.status),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            proposal.legalCase.title,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            proposal.legalCase.categoryName,
            style: context.text.bodySmall?.copyWith(
              color: context.accentGolden,
            ),
          ),
          Divider(height: 24.h),
          Text(
            proposal.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(height: 1.5),
          ),
          if (proposal.status.toLowerCase() == 'pending') ...[
            Divider(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(AppStrings.edit.tr(context)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(AppStrings.delete.tr(context)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        text = AppStrings.accepted.tr(context);
        break;
      case 'rejected':
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
