import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/specializations/data/models/lawyer_specialization_model.dart';
import 'package:hogga/features/lawyer/specializations/presentation/cubit/lawyer_specializations_cubit.dart';
import 'package:hogga/injection_container.dart';

class LawyerSpecializationsScreen extends StatelessWidget {
  const LawyerSpecializationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LawyerSpecializationsCubit>()..getSpecializations(),
      child: const _LawyerSpecializationsView(),
    );
  }
}

class _LawyerSpecializationsView extends StatefulWidget {
  const _LawyerSpecializationsView();

  @override
  State<_LawyerSpecializationsView> createState() =>
      _LawyerSpecializationsViewState();
}

class _LawyerSpecializationsViewState
    extends State<_LawyerSpecializationsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocConsumer<LawyerSpecializationsCubit, LawyerSpecializationsState>(
      listener: (context, state) {
        if (state is LawyerSpecializationsSuccess) {
          AppSnackbar.showSuccess(context, message: state.message);
        } else if (state is LawyerSpecializationsUpdateError) {
          AppSnackbar.showError(context, message: state.message);
        } else if (state is LawyerSpecializationsError) {
          AppSnackbar.showError(context, message: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.pageBg,
          appBar: MainAppbar(
            title: AppStrings.mySpecializations.tr(context),
          ),
          body: _buildBody(context, state, isArabic),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    LawyerSpecializationsState state,
    bool isArabic,
  ) {
    if (state is LawyerSpecializationsLoading ||
        state is LawyerSpecializationsInitial) {
      return const LawyerShimmerLoading();
    }

    if (state is LawyerSpecializationsError) {
      return CustomErrorState(
        message: state.message,
        onRetry: () =>
            context.read<LawyerSpecializationsCubit>().getSpecializations(),
      );
    }

    List<LawyerSpecializationCategoryModel> categories = [];
    Set<int> selectedIds = {};

    if (state is LawyerSpecializationsLoaded) {
      categories = state.categories;
      selectedIds = state.selectedItemIds;
    } else if (state is LawyerSpecializationsUpdating) {
      categories = state.categories;
      selectedIds = state.selectedItemIds;
    } else if (state is LawyerSpecializationsSuccess) {
      categories = state.categories;
      selectedIds = state.selectedItemIds;
    } else if (state is LawyerSpecializationsUpdateError) {
      categories = state.categories;
      selectedIds = state.selectedItemIds;
    }

    final query = _searchQuery.trim().toLowerCase();
    final filteredCategories = categories.where((cat) {
      if (query.isEmpty) return true;
      final catMatch =
          cat.nameAr.toLowerCase().contains(query) ||
          cat.nameEn.toLowerCase().contains(query);
      final itemMatch = cat.items.any(
        (item) =>
            item.nameAr.toLowerCase().contains(query) ||
            item.nameEn.toLowerCase().contains(query),
      );
      return catMatch || itemMatch;
    }).toList();

    return RefreshIndicator(
      onRefresh: () =>
          context.read<LawyerSpecializationsCubit>().getSpecializations(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        children: [
          // Sleek compact info banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.colors.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'حدد المجالات والتخصصات القانونية التي تقدم فيها خدماتك واستشاراتك للعملاء.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.5.sp,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Search Box with clear button
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: context.text.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن تخصص أو خدمة قانونية...',
              hintStyle: context.text.bodySmall?.copyWith(
                color: context.textSecondary,
                fontSize: 11.5.sp,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.textSecondary,
                size: 18.sp,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.textSecondary,
                        size: 16.sp,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: context.cardBg,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 9.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.divColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.divColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.accentGolden),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Selection summary indicator
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: selectedIds.isNotEmpty
                      ? context.accentGolden.withValues(alpha: 0.12)
                      : context.divColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13.sp,
                      color: selectedIds.isNotEmpty
                          ? context.accentGolden
                          : context.textSecondary,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      selectedIds.isNotEmpty
                          ? 'تم تحديد ${selectedIds.length} تخصص'
                          : 'لم يتم تحديد أي تخصص بعد',
                      style: context.text.labelSmall?.copyWith(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: selectedIds.isNotEmpty
                            ? context.accentGolden
                            : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (selectedIds.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      context.read<LawyerSpecializationsCubit>().clearAll(),
                  child: Text(
                    'مسح الكل',
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.redAccent,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          if (filteredCategories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 40.sp,
                      color: context.textSecondary.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.noDataFound.tr(context),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredCategories.map((cat) {
              return _buildCategoryCard(
                context,
                cat,
                selectedIds,
                isArabic,
                query,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    LawyerSpecializationCategoryModel category,
    Set<int> selectedIds,
    bool isArabic,
    String query,
  ) {
    final selectedInCat = category.items
        .where((it) => selectedIds.contains(it.id))
        .length;
    final allSelectedInCat =
        category.items.isNotEmpty &&
        category.items.every((it) => selectedIds.contains(it.id));

    final bool categoryMatched =
        query.isEmpty ||
        category.nameAr.toLowerCase().contains(query) ||
        category.nameEn.toLowerCase().contains(query);

    final visibleItems = categoryMatched
        ? category.items
        : category.items
              .where(
                (it) =>
                    it.nameAr.toLowerCase().contains(query) ||
                    it.nameEn.toLowerCase().contains(query),
              )
              .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: LawyerCard(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: context.accentGolden.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: context.accentGolden,
                    size: 15.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    category.getLocalizedName(isArabic),
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.isDark ? AppColors.cream : AppColors.primary,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ),
                if (selectedInCat > 0)
                  Container(
                    margin: EdgeInsetsDirectional.only(end: 6.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '$selectedInCat/${category.items.length}',
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ),
                // Quick toggle all in this category
                GestureDetector(
                  onTap: () {
                    context.read<LawyerSpecializationsCubit>().toggleCategory(
                      category.id,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      allSelectedInCat ? 'إلغاء' : 'تحديد الكل',
                      style: context.text.labelSmall?.copyWith(
                        color: allSelectedInCat
                            ? context.textSecondary
                            : context.accentGolden,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: visibleItems.map((item) {
                final isSelected = selectedIds.contains(item.id);
                return FilterChip(
                  label: Text(item.getLocalizedName(isArabic)),
                  selected: isSelected,
                  showCheckmark: true,
                  checkmarkColor: isSelected
                      ? (context.isDark ? AppColors.primary : AppColors.cream)
                      : null,
                  selectedColor: AppColors.primary,
                  backgroundColor: context.isDark
                      ? const Color(0xFF3D1F0D)
                      : const Color(0xFFFDE5A5),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : context.divColor,
                    ),
                  ),
                  labelStyle: context.text.labelSmall?.copyWith(
                    color: isSelected
                        ? (context.isDark ? AppColors.primary : AppColors.cream)
                        : (context.isDark ? AppColors.cream : AppColors.primary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 10.5.sp,
                  ),
                  onSelected: (_) {
                    context.read<LawyerSpecializationsCubit>().toggleItem(
                      item.id,
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar(
    BuildContext context,
    LawyerSpecializationsState state,
  ) {
    if (state is! LawyerSpecializationsLoaded &&
        state is! LawyerSpecializationsUpdating &&
        state is! LawyerSpecializationsSuccess &&
        state is! LawyerSpecializationsUpdateError) {
      return null;
    }

    final isUpdating = state is LawyerSpecializationsUpdating;
    Set<int> selectedIds = {};
    if (state is LawyerSpecializationsLoaded) {
      selectedIds = state.selectedItemIds;
    } else if (state is LawyerSpecializationsUpdating) {
      selectedIds = state.selectedItemIds;
    } else if (state is LawyerSpecializationsSuccess) {
      selectedIds = state.selectedItemIds;
    } else if (state is LawyerSpecializationsUpdateError) {
      selectedIds = state.selectedItemIds;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: context.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 46.h,
          child: ElevatedButton.icon(
            onPressed: isUpdating
                ? null
                : () {
                    context
                        .read<LawyerSpecializationsCubit>()
                        .updateSpecializations();
                  },
            icon: isUpdating
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.cream,
                    ),
                  )
                : Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18.sp,
                    color: AppColors.cream,
                  ),
            label: Text(
              selectedIds.isEmpty
                  ? 'حفظ التخصصات'
                  : 'حفظ التخصصات (${selectedIds.length})',
              style: TextStyle(
                color: AppColors.cream,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
