import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/features/user/home/data/models/lawyer_service_model.dart';
import 'package:hogga/config/routes/app_routes.dart';

class LawyerCard extends StatelessWidget {
  final ProviderProfileModel provider;
  final bool isAdded;
  final VoidCallback? onAdd;
  final  int? typeOfBookingFlow ; // 0 for main, 1 for admin core, 2 for provider core

  const LawyerCard({
    super.key,
    required this.provider,
    this.isAdded = false,
    this.onAdd,
    this.typeOfBookingFlow=0,
  });

  @override
  Widget build(BuildContext context) {
    final userName = provider.name;
    final userPhoto = provider.photo;

    // Mocking missing fields temporarily until backend provides them
    final double mockPrice = 0.0; 
    final String mockTime = '00:00';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdded ? AppColors.golden : context.divColor,
          width: isAdded ? 1.5 : 1,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with online status
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.lawyerProfile, arguments: provider.id);
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                      radius: 22,
                      backgroundColor: context.chipBg,
                      backgroundImage: userPhoto != null && userPhoto.isNotEmpty
                          ? CachedNetworkImageProvider(userPhoto) as ImageProvider
                          : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
                      child: userPhoto == null || userPhoto.isEmpty
                          ? Icon(Icons.person, color: context.textPrimary, size: 22)
                          : null,
                    ),
                    if (provider.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.cardBg, width: 2),
                          ),
                        ),
                      ),
                  ],
                      ),
                  ),
                AppSizes.w(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          if (provider.isVerified) ...[
                            AppSizes.w(4),
                            const Icon(Icons.verified, color: Colors.blue, size: 14),
                          ],
                        ],
                      ),
                      AppSizes.h(4),
                      Row(
                        children: [
                          if (provider.city != null && provider.city!.isNotEmpty) ...[
                            Icon(Icons.location_on_outlined, size: 12, color: context.textSecondary),
                            AppSizes.w(2),
                            Text(
                              provider.city!,
                              style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontSize: 10.sp),
                            ),
                            AppSizes.w(8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.golden.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  provider.rating.toStringAsFixed(1),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: AppColors.golden),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.star_rounded, color: AppColors.golden, size: 10),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
  
            AppSizes.h(12),
            // Stats row
            if (provider.services.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on_outlined, size: 14, color: context.colors.primary),
                        AppSizes.w(6),
                        Flexible(
                          child: Text(
                            '${AppStrings.servicePrice.tr(context)} / ${provider.services.first.price} ${provider.services.first.currency}',
                            style: context.text.labelMedium?.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (provider.services.first.taxStatusText != null && provider.services.first.taxStatusText!.isNotEmpty) ...[
                    AppSizes.w(4),
                    Text(
                      provider.services.first.taxStatusText!,
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontSize: 10.sp),
                    ),
                  ],
                ],
              ),
            AppSizes.h(6),

            if(typeOfBookingFlow==0)
              MainBookingFlowButton(onAdd: onAdd, isAdded: isAdded, provider: provider),
            if(typeOfBookingFlow==1)
              ProviderCoreFixedBookingFlowButton(onAdd: onAdd, provider: provider, mockPrice: mockPrice),
            if(typeOfBookingFlow==2)
              ProviderCoreBookingFlowButton(onAdd: onAdd, provider: provider, mockPrice: mockPrice, mockTime: mockTime),
          ],
        ),
    );
  }
}

class MainBookingFlowButton extends StatelessWidget{
   final VoidCallback? onAdd;
   final bool isAdded;
   final provider;
  const MainBookingFlowButton({super.key, this.onAdd, this.isAdded = false,this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.work_outline, size: 14, color: context.colors.primary),
              AppSizes.w(6),
              Flexible(
                child: Text(
                  '${AppStrings.experienceLabel.tr(context)} / ${provider?.experience ?? 0} ${AppStrings.years.tr(context)}',
                  style: context.text.labelMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        AppSizes.w(8),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isAdded ? AppColors.golden : context.chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAdded ? AppStrings.addedSuccessfully.tr(context) : AppStrings.addLawyer.tr(context),
              style: TextStyle(
                color: isAdded ? AppColors.cream : context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

}

class ProviderCoreFixedBookingFlowButton extends StatelessWidget{
  final VoidCallback? onAdd;
  final provider ; // Mocking provider since not passed in constructor
  final double mockPrice;
  const ProviderCoreFixedBookingFlowButton({super.key, this.onAdd,this.provider, this.mockPrice = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(

          children: [
            Text(
              AppStrings.consultation,
              style: context.text.labelMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  mockPrice.toString(),
                  style: context.text.labelMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.currencyRial,
                  style: context.text.labelMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Add button or logic
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:  context.chipBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
             AppStrings.addLawyer.tr(context),
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
class ProviderCoreBookingFlowButton extends StatelessWidget{
    final provider ; // Mocking provider since not passed in constructor
    final VoidCallback? onAdd;
    final double mockPrice;
    final String mockTime;
  const ProviderCoreBookingFlowButton({super.key, this.onAdd,this.provider, this.mockPrice = 0, this.mockTime = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(

          children: [
            Text(
              AppStrings.startFrom,
              style: context.text.labelMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  mockPrice.toString(),
                  style: context.text.labelMedium,
                ),
                Text(
                  AppStrings.currencyRial,
                  style: context.text.labelMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('/$mockTime',style: context.text.labelMedium)
              ],
            ),
          ],
        ),

        // Add button or logic
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:  context.chipBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${AppStrings.bookAnAppointment.tr(context)}',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
