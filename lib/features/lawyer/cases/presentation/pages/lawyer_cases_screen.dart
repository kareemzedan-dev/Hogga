import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/cases/presentation/cubit/lawyer_cases_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_status_badge.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_info_row.dart';

import 'package:hogga/features/lawyer/cases/presentation/widgets/case_card.dart';

class LawyerCasesScreen extends StatefulWidget {
  final bool isBottomNav;
  const LawyerCasesScreen({super.key, this.isBottomNav = false});

  @override
  State<LawyerCasesScreen> createState() => _LawyerCasesScreenState();
}

class _LawyerCasesScreenState extends State<LawyerCasesScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  late final List<String> _statusesLabels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: widget.isBottomNav
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
          backgroundColor: context.pageBg,
          elevation: 0,
          shape: Border(
            bottom: BorderSide(
              color: context.divColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          title: Text(
            AppStrings.myCases.tr(context),
            style: context.theme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<LawyerCasesCubit, LawyerCasesState>(
          builder: (context, state) {
            if (state is LawyerCasesLoading) {
              return const LawyerShimmerLoading();
            } else if (state is LawyerCasesError) {
              return CustomErrorState(
                message: state.message,
                onRetry: () => context.read<LawyerCasesCubit>().getCases(type: 'all'),
              );
            } else if (state is LawyerCasesLoaded) {
              final filteredCases = state.cases.where((c) {
                final matchesSearch = c.title.contains(_searchQuery) || c.id.toString().contains(_searchQuery);
                final matchesStatus = _selectedStatus == AppStrings.all.tr(context) || c.statusText == _selectedStatus;
                return matchesSearch && matchesStatus;
              }).toList();

              return RefreshIndicator(
                onRefresh: () => context.read<LawyerCasesCubit>().getCases(type: state.currentType),
                color: context.accentGolden,
                child: Column(
                  children: [
                    _buildSearchAndFilter(context),
                    Expanded(
                      child: SafeArea(
                        child: filteredCases.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  CustomEmptyState(
                                    title: _searchQuery.isEmpty ? AppStrings.noCases.tr(context) : AppStrings.noResults.tr(context),
                                    subtitle: _searchQuery.isEmpty ? AppStrings.noCasesSubtitle.tr(context) : AppStrings.noSearchResultsSubtitle.tr(context),
                                    icon: _searchQuery.isEmpty ? Icons.gavel_outlined : Icons.search_off_rounded,
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.all(20.w),
                                itemCount: filteredCases.length,
                                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                                itemBuilder: (context, index) => CaseCard(lawyerCase: filteredCases[index]),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusesLabels = [
      AppStrings.all.tr(context),
      AppStrings.inProgress.tr(context),
      AppStrings.completed.tr(context)
    ];
    _selectedStatus ??= _statusesLabels[0];
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: AppStrings.searchByCaseIdOrTitle.tr(context),
              prefixIcon: Icon(Icons.search_rounded, color: context.textSecondary),
              filled: true,
              fillColor: context.pageBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusesLabels.asMap().entries.map((entry) {
                final index = entry.key;
                final status = entry.value;
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedStatus = status);
                        final type = index == 0 ? 'all' : (index == 1 ? 'ongoing' : 'completed');
                        context.read<LawyerCasesCubit>().getCases(type: type);
                      }
                    },
                    selectedColor: context.accentGolden,
                    labelStyle: context.text.labelSmall?.copyWith(
                      color: isSelected ? context.colors.onPrimary : context.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: context.pageBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: isSelected ? context.accentGolden : context.divColor)),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
