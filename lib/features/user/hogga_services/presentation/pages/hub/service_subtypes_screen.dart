import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/user/hogga_services/presentation/manager/item_categories_cubit.dart';
import 'package:hogga/injection_container.dart' as di;

import 'package:hogga/features/user/hogga_services/domain/models/booking_flow_args.dart';
import 'package:hogga/features/user/hogga_services/data/models/item_category_model.dart';
import 'package:shimmer/shimmer.dart';
import '../booking/booking_flow_screen.dart';

class ServiceSubtypesScreen extends StatelessWidget {
  final int childCategoryId;
  final String sectionName;
  final String subCategoryName;
  final String childCategoryName;
  final double subCategoryPrice;

  const ServiceSubtypesScreen({
    super.key,
    required this.childCategoryId,
    required this.sectionName,
    required this.subCategoryName,
    required this.childCategoryName,
    required this.subCategoryPrice,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ItemCategoriesCubit>()..getItemCategories(childCategoryId),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            sectionName,
            style: context.theme.appBarTheme.titleTextStyle,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategoryName,
                    style: context.text.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  AppSizes.h(4),
                  Text(
                    childCategoryName,
                    style: context.text.bodySmall?.copyWith(color: context.textSecondary, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ItemCategoriesCubit, ItemCategoriesState>(
                builder: (context, state) {
                  if (state is ItemCategoriesLoading) {
                    return _buildShimmerList(context);
                  }

                  if (state is ItemCategoriesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message ),
                          TextButton(
                            onPressed: () => context.read<ItemCategoriesCubit>().getItemCategories(childCategoryId),
                            child: Text(AppStrings.retry.tr(context)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ItemCategoriesSuccess) {
                    final items = state.items;
                    if (items.isEmpty) {
                      return Center(child: Text(AppStrings.noDataFound.tr(context)));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => AppSizes.h(12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildItemCard(context, item);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 6,
      separatorBuilder: (_, __) => AppSizes.h(12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, ItemCategoryData item) {
    final isCall = item.isCallType;
    final serviceColor = item.serviceType == 'video'
        ? const Color(0xFF2196F3)
        : item.serviceType == 'audio'
            ? const Color(0xFF4CAF50)
            : Theme.of(context).primaryColor;
    final serviceIcon = item.serviceType == 'video'
        ? Icons.videocam_rounded
        : item.serviceType == 'audio'
            ? Icons.phone_in_talk_rounded
            : Icons.description_outlined;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.bookingFlow,
          arguments: BookingFlowArgs(
            itemCategoryId: item.id,
            childCategoryId: item.childCategoryId,
            price: subCategoryPrice,
            sectionName: sectionName,
            subCategoryName: subCategoryName,
            childCategoryName: childCategoryName,
            itemName: item.name,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: serviceColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                serviceIcon,
                color: serviceColor,
                size: 20,
              ),
            ),
            AppSizes.w(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      fontSize: 13.sp,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    AppSizes.h(4),
                    Text(
                      item.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontSize: 11.sp),
                    ),
                  ],
                  if (isCall && item.duration != null) ...[
                    AppSizes.h(6),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 12, color: serviceColor),
                        AppSizes.w(4),
                        Text(
                          '${item.duration} ${AppStrings.minutesLabel.tr(context)}',
                          style: context.text.labelSmall?.copyWith(
                            color: serviceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.arrow_forward_ios, size: 14, color: context.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
