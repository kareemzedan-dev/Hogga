import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/config/routes/app_routes.dart';

class LawyerSearchScreen extends StatefulWidget {
  const LawyerSearchScreen({super.key});

  @override
  State<LawyerSearchScreen> createState() => _LawyerSearchScreenState();
}

class _LawyerSearchScreenState extends State<LawyerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCity;
  String? _selectedGender;
  String? _sortBy;
  Timer? _debounce;

  final List<String> _cities = ['Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur', 'Ibri', 'Ibra', 'Rustaq', 'Buraimi', 'Cairo', 'Alex'];
  final List<String> _genders = ['male', 'female'];
  final List<Map<String, String>> _sortOptions = [
    {'label': 'Experience', 'value': 'experience'},
    {'label': 'Rating', 'value': 'rating'},
    {'label': 'Price', 'value': 'price'},
  ];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final Map<String, dynamic> filters = {};
    if (_searchController.text.isNotEmpty) filters['q'] = _searchController.text;
    if (_selectedCity != null) filters['city'] = _selectedCity;
    if (_selectedGender != null) filters['gender'] = _selectedGender;
    if (_sortBy != null) filters['sort_by'] = _sortBy;

    context.read<HomeCubit>().searchProviders(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.searchLawyer.tr(context),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.isLoadingFilteredProviders) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredProviders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: context.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(AppStrings.noResults.tr(context), style: context.text.titleMedium),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.filteredProviders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final provider = state.filteredProviders[index];
                    return _buildProviderCard(context, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: context.pageBg,
        border: Border(bottom: BorderSide(color: context.divColor)),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _searchController,
            hintText: AppStrings.searchByName.tr(context),
            prefixIcon: const Icon(Icons.search),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  _selectedCity ?? AppStrings.city.tr(context),
                  Icons.location_on_outlined,
                  () => _showFilterDialog('City', _cities, _selectedCity, (v) => setState(() => _selectedCity = v)),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  _selectedGender ?? AppStrings.gender.tr(context),
                  Icons.person_outline,
                  () => _showFilterDialog('Gender', _genders, _selectedGender, (v) => setState(() => _selectedGender = v)),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  _sortBy ?? AppStrings.sortBy.tr(context),
                  Icons.sort_rounded,
                  () => _showFilterDialog('Sort By', _sortOptions.map((e) => e['value']!).toList(), _sortBy, (v) => setState(() => _sortBy = v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.divColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(label, style: context.text.bodySmall),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, dynamic provider) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerProfile, arguments: provider.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: provider.photo != null && provider.photo!.isNotEmpty
                  ? CachedNetworkImageProvider(provider.photo!) as ImageProvider
                  : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
              child: provider.photo == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.name, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(provider.title ?? '', style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.golden, size: 14),
                      const SizedBox(width: 4),
                      Text(provider.rating.toString(), style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Icon(Icons.work_outline, color: Theme.of(context).primaryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(provider.experience, style: context.text.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(String title, List<String> options, String? selectedValue, Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text(AppStrings.all.tr(context)),
                  selected: selectedValue == null,
                  onSelected: (selected) {
                    onSelected(null);
                    Navigator.pop(context);
                    _performSearch();
                  },
                ),
                ...options.map((option) => FilterChip(
                  label: Text(option),
                  selected: selectedValue == option,
                  onSelected: (selected) {
                    onSelected(selected ? option : null);
                    Navigator.pop(context);
                    _performSearch();
                  },
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
