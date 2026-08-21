import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';

class ReferralBannerCard extends StatelessWidget {
  final ReferralCampaign? campaign;

  const ReferralBannerCard({super.key, this.campaign});

  @override
  Widget build(BuildContext context) {
    if (campaign == null) {
      return const SizedBox.shrink();
    }

    final code = campaign!.referralCode;
    final bonus = campaign!.bonusAmount;
    final isOn = campaign!.isOn;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.mc.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.accentGolden.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: context.accentGolden,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        AppStrings.referralProgram.tr(context),
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  isOn ? AppStrings.referralCampaignSubtitle.tr(context, namedArgs: {
                    'amount': bonus.toStringAsFixed(0),
                    'currency': AppStrings.currencySymbol.tr(context),
                  }) : AppStrings.campaignNotActive.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: isOn ? context.accentGolden : context.textSecondary,
                    fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      AppStrings.rewardValue.tr(context),
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      bonus.toStringAsFixed(0),
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppStrings.referralCodeTitle.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      AppSnackbar.showSuccess(context, message: AppStrings.codeCopied.tr(context));
                    }
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: context.pageBg,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: context.accentGolden.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 16.sp,
                          color: context.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            code,
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
