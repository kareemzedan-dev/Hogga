import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/features/user/home/data/models/lawyer_service_model.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../widgets/city_picker_sheet.dart';

import '../../widgets/lawyer_card.dart';

class LawyerBrowserScreen extends StatefulWidget {
  final int? categoriesItemId;
  final int? typeOfBookingFlow;
  const LawyerBrowserScreen({super.key, this.categoriesItemId, this.typeOfBookingFlow = 0});

  @override
  State<LawyerBrowserScreen> createState() => _LawyerBrowserScreenState();
}

class _LawyerBrowserScreenState extends State<LawyerBrowserScreen> {
  String _searchQuery = '';
  String? _selectedCity;
  String? _selectedGender;
  String? _sortOption;
  final Set<int> _selectedLawyerIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
       // Pagination logic could be added here if needed
    }
  }

  void _loadProviders() {
    final filters = <String, dynamic>{};
    if (widget.categoriesItemId != null) {
      filters['categories_item_id'] = widget.categoriesItemId;
    }
    if (_searchQuery.trim().isNotEmpty) filters['q'] = _searchQuery.trim();
    if (_selectedCity != null && _selectedCity!.isNotEmpty) filters['city'] = _selectedCity;
    if (_selectedGender != null && _selectedGender!.isNotEmpty) filters['gender'] = _selectedGender;
    if (_sortOption != null && _sortOption!.isNotEmpty) filters['sort_by'] = _sortOption;
    context.read<HomeCubit>().searchProviders(filters: filters.isEmpty ? null : filters);
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
        Navigator.pop(context, _selectedLawyerIds.map((id) => id.toString()).toSet());
      },
      child: Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.textPrimary),
        title: Text(
          AppStrings.availableLawyers.tr(context),
          style: context.theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          if (_selectedLawyerIds.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                _selectedLawyerIds.map((id) => id.toString()).toSet(),
              ),
              child: Text(
                '${AppStrings.addAction.tr(context)} (${_selectedLawyerIds.length})',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: CustomTextField(
              hintText: AppStrings.searchLawyer.tr(context),
              prefixIcon: Icon(Icons.search, color: context.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _loadProviders();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  _FilterChip(
                    label: _sortOption != null 
                        ? (_sortOption == 'experience' ? AppStrings.byExperience.tr(context) : AppStrings.byRating.tr(context))
                        : AppStrings.sortBy.tr(context),
                    icon: Icons.sort,
                    isActive: _sortOption != null,
                    onTap: _showSortSheet,
                  ),
                  AppSizes.w(10),
                  _FilterChip(
                    label: _genderLabel(context),
                    isActive: _selectedGender != null,
                    onTap: _showGenderSheet,
                  ),
                  AppSizes.w(10),
                  _FilterChip(
                    label: _selectedCity != null ? _selectedCity!.tr(context) : AppStrings.city.tr(context),
                    onTap: _showCityPicker,
                    isActive: _selectedCity != null,
                  ),
                ],
              ),
            ),
          ),

          AppSizes.h(16),

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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: AppStrings.availableLawyers.tr(context),
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSizes.h(12),

                    Expanded(
                      child: providers.isEmpty
                          ? Center(child: Text(AppStrings.noDataFound.tr(context)))
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                              itemCount: providers.length,
                              separatorBuilder: (_, __) => AppSizes.h(16),
                              itemBuilder: (context, index) {
                                final provider = providers[index];
                                final lawyerId = provider.id;
                                return LawyerCard(
                                  provider: provider,
                                  isAdded: _selectedLawyerIds.contains(lawyerId),
                                  typeOfBookingFlow: widget.typeOfBookingFlow,
                                  onAdd: () {
                                    setState(() {
                                      if (_selectedLawyerIds.contains(lawyerId)) {
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
    ));
  }

  void _showGenderSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppStrings.all.tr(context), style: const TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedGender = null);
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(AppStrings.male.tr(context), style: const TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedGender = 'male');
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(AppStrings.female.tr(context), style: const TextStyle(fontSize: 14)),
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
              title: Text(AppStrings.all.tr(context), style: const TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOption = null);
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(AppStrings.byExperience.tr(context), style: const TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOption = 'experience');
                _loadProviders();
              },
            ),
            ListTile(
              title: Text(AppStrings.byRating.tr(context), style: const TextStyle(fontSize: 14)),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
              : context.cardBg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? Theme.of(context).primaryColor : context.divColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: context.textPrimary),
              AppSizes.w(6),
            ],
            Text(label, style: TextStyle(color: context.textPrimary, fontSize: 13)),
            AppSizes.w(4),
            Icon(Icons.keyboard_arrow_down, size: 14, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
