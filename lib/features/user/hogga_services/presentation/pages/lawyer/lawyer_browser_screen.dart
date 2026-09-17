import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../widgets/city_picker_sheet.dart';

import '../../widgets/lawyer_card.dart';

class LawyerBrowserScreen extends StatefulWidget {
  final int? categoriesItemId;
  final int? typeOfBookingFlow;
  final String? initialCoupon;
  const LawyerBrowserScreen({
    super.key,
    this.categoriesItemId,
    this.typeOfBookingFlow = 0,
    this.initialCoupon,
  });

  @override
  State<LawyerBrowserScreen> createState() => _LawyerBrowserScreenState();
}

class _LawyerBrowserScreenState extends State<LawyerBrowserScreen> {
  String _searchQuery = '';
  String? _selectedCity;
  String? _selectedGender;
  String? _sortOption;
  late final TextEditingController _couponController;
  String? _activeCouponCode;
  final Set<int> _selectedLawyerIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController(text: widget.initialCoupon ?? '');
    final initialCoupon = widget.initialCoupon?.trim();
    _activeCouponCode = initialCoupon == null || initialCoupon.isEmpty
        ? null
        : initialCoupon;
    _loadProviders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _couponController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Pagination logic could be added here if needed
    }
  }

  void _loadProviders() {
    final filters = <String, dynamic>{};
    if (widget.categoriesItemId != null) {
      filters['categories_item_id'] = widget.categoriesItemId;
    }
    if (_searchQuery.trim().isNotEmpty) {
      filters['q'] = _searchQuery.trim();
    }
    if (_activeCouponCode != null && _activeCouponCode!.isNotEmpty) {
      filters['coupon'] = _activeCouponCode;
    }
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filters['city'] = _selectedCity;
    }
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      filters['gender'] = _selectedGender;
    }
    if (_sortOption != null && _sortOption!.isNotEmpty) {
      filters['sort_by'] = _sortOption;
    }
    context.read<HomeCubit>().searchProviders(
      filters: filters.isEmpty ? null : filters,
    );
  }

  Map<String, dynamic> _resultPayload() {
    return {
      'lawyerIds': _selectedLawyerIds.map((id) => id.toString()).toSet(),
      'coupon':
          (_activeCouponCode != null && _activeCouponCode!.trim().isNotEmpty)
          ? _activeCouponCode!.trim()
          : null,
    };
  }

  void _applyCouponFilter() {
    FocusScope.of(context).unfocus();
    final code = _couponController.text.trim();
    setState(() => _activeCouponCode = code.isEmpty ? null : code);
    _loadProviders();
  }

  void _clearCouponFilter() {
    FocusScope.of(context).unfocus();
    _couponController.clear();
    setState(() => _activeCouponCode = null);
    _loadProviders();
  }

  Future<void> _showCityPicker() async {
    final city = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CityPickerSheet(),
    );
    if (city != null) {
      setState(() => _selectedCity = city);
      _loadProviders();
    }
  }

  String _genderLabel(BuildContext context) {
    if (_selectedGender == 'male') return AppStrings.male.tr(context);
    if (_selectedGender == 'female') return AppStrings.female.tr(context);
    return AppStrings.gender.tr(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _resultPayload());
      },
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.availableLawyers.tr(context),
          actions: [
            if (_selectedLawyerIds.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pop(context, _resultPayload()),
                child: Text(
                  '${AppStrings.addAction.tr(context)} (${_selectedLawyerIds.length})',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: CustomTextField(
                hintText: AppStrings.searchLawyer.tr(context),
                prefixIcon: Icon(Icons.search, color: context.textSecondary),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                onChanged: (v) {
                  setState(() => _searchQuery = v);
                  _loadProviders();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: [
                    _FilterChip(
                      label: _sortOption != null
                          ? (_sortOption == 'experience'
                                ? AppStrings.byExperience.tr(context)
                                : AppStrings.byRating.tr(context))
                          : AppStrings.sortBy.tr(context),
                      icon: Icons.sort,
                      isActive: _sortOption != null,
                      onTap: _showSortSheet,
                    ),
                    AppSizes.w(8),
                    _FilterChip(
                      label: _genderLabel(context),
                      isActive: _selectedGender != null,
                      onTap: _showGenderSheet,
                    ),
                    AppSizes.w(8),
                    _FilterChip(
                      label: _selectedCity != null
                          ? _selectedCity!.tr(context)
                          : AppStrings.city.tr(context),
                      onTap: _showCityPicker,
                      isActive: _selectedCity != null,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _CouponFilterBar(
                controller: _couponController,
                activeCouponCode: _activeCouponCode,
                onChanged: (_) => setState(() {}),
                onApply: _applyCouponFilter,
                onClear: _clearCouponFilter,
              ),
            ),

            AppSizes.h(10),

            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isLoadingFilteredProviders) {
                    return _buildShimmerLoading(context);
                  }

                  final providers = state.filteredProviders;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '(${providers.length}) ',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppStrings.availableLawyers.tr(
                                      context,
                                    ),
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSizes.h(6),

                      Expanded(
                        child: providers.isEmpty
                            ? Center(
                                child: Text(AppStrings.noDataFound.tr(context)),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  20,
                                ),
                                itemCount: providers.length,
                                separatorBuilder: (_, __) => AppSizes.h(16),
                                itemBuilder: (context, index) {
                                  final provider = providers[index];
                                  final lawyerId = provider.id;
                                  return LawyerCard(
                                    provider: provider,
                                    isAdded: _selectedLawyerIds.contains(
                                      lawyerId,
                                    ),
                                    typeOfBookingFlow: widget.typeOfBookingFlow,
                                    onAdd: () {
                                      setState(() {
                                        if (_selectedLawyerIds.contains(
                                          lawyerId,
                                        )) {
                                          _selectedLawyerIds.remove(lawyerId);
                                        } else {
                                          _selectedLawyerIds.add(lawyerId);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppStrings.all.tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedGender = null);
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(
                AppStrings.male.tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedGender = 'male');
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(
                AppStrings.female.tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedGender = 'female');
                _loadProviders();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppStrings.all.tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOption = null);
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(
                AppStrings.byExperience.tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOption = 'experience');
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(
                AppStrings.byRating.tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOption = 'rating');
                _loadProviders();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: context.mc.shimmerBase,
        highlightColor: context.mc.shimmerHighlight,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _CouponFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final String? activeCouponCode;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _CouponFilterBar({
    required this.controller,
    required this.activeCouponCode,
    required this.onChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final hasText = controller.text.trim().isNotEmpty;
    final typedCode = controller.text.trim();
    final isApplied =
        activeCouponCode != null &&
        activeCouponCode!.isNotEmpty &&
        activeCouponCode == typedCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller,
                hintText: AppStrings.enterPromoCode.tr(context),
                onChanged: onChanged,
                prefixIcon: Icon(
                  Icons.local_offer_outlined,
                  size: 18,
                  color: isApplied
                      ? const Color(0xFF27AE60)
                      : context.textSecondary,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        onPressed: onClear,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: context.textSecondary,
                        ),
                        splashRadius: 16,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
              ),
            ),
            AppSizes.w(8),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: hasText ? (isApplied ? onClear : onApply) : null,
                icon: Icon(
                  isApplied
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  size: 15.sp,
                  color: isApplied
                      ? const Color(0xFF27AE60)
                      : (hasText ? Colors.white : context.textSecondary),
                ),
                label: Text(
                  isApplied
                      ? (isRtl ? 'مُطبّق' : 'Applied')
                      : AppStrings.apply.tr(context),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isApplied
                        ? const Color(0xFF27AE60)
                        : (hasText ? Colors.white : context.textSecondary),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied
                      ? const Color(0xFF27AE60).withValues(alpha: 0.12)
                      : (hasText ? AppColors.golden : context.chipBg),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: context.chipBg,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide(
                      color: isApplied
                          ? const Color(0xFF27AE60).withValues(alpha: 0.3)
                          : (hasText
                                ? AppColors.golden
                                : context.divColor.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (activeCouponCode != null && activeCouponCode!.isNotEmpty) ...[
          AppSizes.h(6),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 13.sp,
                color: const Color(0xFF27AE60),
              ),
              AppSizes.w(4),
              Text(
                AppStrings.couponApplied.tr(
                  context,
                  namedArgs: {'code': activeCouponCode!},
                ),
                style: context.text.labelSmall?.copyWith(
                  color: const Color(0xFF27AE60),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;

  const _FilterChip({
    required this.label,
    this.icon,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
              : context.cardBg,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: isActive ? Theme.of(context).primaryColor : context.divColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14.sp, color: context.textPrimary),
              AppSizes.w(6),
            ],
            Text(
              label,
              style: TextStyle(color: context.textPrimary, fontSize: 11.sp),
            ),
            AppSizes.w(4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14.sp,
              color: context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
