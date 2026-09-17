import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/user/hogga_services/presentation/manager/item_categories_cubit.dart';
import 'package:hogga/injection_container.dart' as di;

import 'package:hogga/features/user/hogga_services/domain/models/booking_flow_args.dart';
import 'package:hogga/features/user/hogga_services/domain/models/service_required_input.dart';
import 'package:hogga/features/user/hogga_services/data/models/item_category_model.dart';
import 'package:shimmer/shimmer.dart';

class ServiceSubtypesScreen extends StatelessWidget {
  final int childCategoryId;
  final int? subCategoryId;
  final String sectionName;
  final String subCategoryName;
  final String childCategoryName;
  final String? parentServiceType;
  final String? parentConsultationType;
  final bool parentIsConsultation;
  final double subCategoryPrice;
  final List<ServiceRequiredInput> parentRequiredInputs;

  const ServiceSubtypesScreen({
    super.key,
    required this.childCategoryId,
    this.subCategoryId,
    required this.sectionName,
    required this.subCategoryName,
    required this.childCategoryName,
    this.parentServiceType,
    this.parentConsultationType,
    this.parentIsConsultation = false,
    required this.subCategoryPrice,
    this.parentRequiredInputs = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ItemCategoriesCubit>()
        ..getItemCategories(
          childCategoryId: childCategoryId,
          subCategoryId: subCategoryId,
        ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: sectionName,
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
                      fontSize: 11.sp,
                    ),
                  ),
                  AppSizes.h(4),
                  Text(
                    childCategoryName,
                    style: context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                      fontSize: 10.5.sp,
                    ),
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
                          Text(state.message),
                          TextButton(
                            onPressed: () => context
                                .read<ItemCategoriesCubit>()
                                .getItemCategories(
                                  childCategoryId: childCategoryId,
                                  subCategoryId: subCategoryId,
                                ),
                            child: Text(AppStrings.retry.tr(context)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ItemCategoriesSuccess) {
                    final items = state.items;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(AppStrings.noDataFound.tr(context)),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
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
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[100]!,
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
    final effectiveServiceType =
        item.serviceType ?? parentServiceType ?? item.consultationType;
    final effectiveConsultationType =
        item.consultationType ?? parentConsultationType;
    final serviceKind = effectiveServiceType?.toLowerCase().trim();
    final parsedItemPrice =
        item.price != null ? double.tryParse(item.price!) : null;
    final itemPrice =
        (parsedItemPrice != null && parsedItemPrice > 0)
            ? parsedItemPrice
            : null;
    final publishingFee = (item.publishingFee != null && item.publishingFee! > 0)
        ? item.publishingFee!
        : (itemPrice ?? subCategoryPrice);
    final requiredInputs = _mergeRequiredInputs([
      ...parentRequiredInputs,
      ...item.requiredInputs,
    ]);
    final isCall = _isCallService(effectiveServiceType);
    final isConsultation =
        parentIsConsultation ||
        item.isConsultation ||
        _isConsultationService(effectiveConsultationType) ||
        _isConsultationService(effectiveServiceType) ||
        _isConsultationName([
          sectionName,
          subCategoryName,
          childCategoryName,
          item.name,
        ]);
    final isCallService =
        serviceKind?.contains('video') == true ||
        serviceKind?.contains('audio') == true ||
        serviceKind?.contains('call') == true ||
        serviceKind?.contains('phone') == true;
    final serviceColor = isCallService
        ? AppColors.golden
        : Theme.of(context).primaryColor;
    final serviceIcon = isCallService
        ? Icons.phone_in_talk_rounded
        : Icons.description_outlined;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          isConsultation
              ? AppRoutes.consultationBooking
              : AppRoutes.bookingFlow,
          arguments: BookingFlowArgs(
            itemCategoryId: item.id,
            childCategoryId: item.childCategoryId != 0
                ? item.childCategoryId
                : childCategoryId,
            subCategoryId: subCategoryId ?? item.subCategoryId,
            price: publishingFee,
            sectionName: sectionName,
            subCategoryName: subCategoryName,
            childCategoryName: childCategoryName,
            itemName: item.name,
            serviceType: effectiveServiceType,
            parentServiceType: parentServiceType,
            consultationType: effectiveConsultationType,
            isConsultation: isConsultation,
            publishingFee: publishingFee,
            duration: item.duration,
            isCallType: isCall,
            requiredInputs: requiredInputs,
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
                color: isCallService
                    ? AppColors.golden
                    : serviceColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                serviceIcon,
                color: isCallService ? AppColors.cream : serviceColor,
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
                      fontSize: 11.5.sp,
                    ),
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    AppSizes.h(4),
                    Text(
                      item.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                  if (publishingFee > 0 && !isConsultation) ...[
                    AppSizes.h(6),
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 12,
                          color: AppColors.golden,
                        ),
                        AppSizes.w(4),
                        Text(
                          '${AppStrings.stepPlatformFees.tr(context)}: ${publishingFee.toStringAsFixed(2)} ${AppStrings.currencySymbol.tr(context)}',
                          style: context.text.labelSmall?.copyWith(
                            color: AppColors.golden,
                            fontWeight: FontWeight.w700,
                            fontSize: 9.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isCall && item.duration != null) ...[
                    AppSizes.h(6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: serviceColor,
                        ),
                        AppSizes.w(4),
                        Text(
                          '${item.duration} ${AppStrings.minutesLabel.tr(context)}',
                          style: context.text.labelSmall?.copyWith(
                            color: serviceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: context.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isCallService(String? type) {
    final normalized = type?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized.contains('audio') ||
        normalized.contains('video') ||
        normalized.contains('phone') ||
        normalized.contains('call');
  }

  bool _isConsultationService(String? type) {
    final normalized = type?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized.contains('consult') ||
        normalized.contains('immediate') ||
        normalized.contains('scheduled') ||
        normalized.contains('written') ||
        normalized.contains('audio') ||
        normalized.contains('video') ||
        normalized == 'text' ||
        normalized == 'chat' ||
        normalized == 'article';
  }

  bool _isConsultationName(List<String?> values) {
    final text = values.whereType<String>().join(' ').toLowerCase();
    return text.contains('consult') ||
        text.contains('\u0627\u0633\u062a\u0634\u0627\u0631');
  }

  List<ServiceRequiredInput> _mergeRequiredInputs(
    List<ServiceRequiredInput> inputs,
  ) {
    final result = <ServiceRequiredInput>[];
    final seenSlugs = <String>{};

    for (final input in inputs) {
      final slug = input.slug.trim();
      if (slug.isEmpty || seenSlugs.contains(slug)) continue;
      seenSlugs.add(slug);
      result.add(input);
    }

    return result;
  }
}
