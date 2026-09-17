import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case.dart';
import 'package:hogga/features/lawyer/cases/presentation/cubit/lawyer_cases_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';

import 'package:hogga/features/lawyer/cases/presentation/widgets/case_card.dart';

class LawyerCasesScreen extends StatefulWidget {
  final bool isBottomNav;
  const LawyerCasesScreen({super.key, this.isBottomNav = false});

  @override
  State<LawyerCasesScreen> createState() => _LawyerCasesScreenState();
}

class _LawyerCasesScreenState extends State<LawyerCasesScreen> {
  String _searchQuery = '';
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.myCases.tr(context),
        backBtn: !widget.isBottomNav,
      ),
      body: BlocBuilder<LawyerCasesCubit, LawyerCasesState>(
        builder: (context, state) {
          if (state is LawyerCasesLoading) {
            return const LawyerShimmerLoading();
          } else if (state is LawyerCasesError) {
            return CustomErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<LawyerCasesCubit>().getCases(type: 'all'),
            );
          } else if (state is LawyerCasesLoaded) {
            final filteredCases = state.cases.where((lawyerCase) {
              final query = _searchQuery.trim().toLowerCase();
              final matchesSearch =
                  query.isEmpty ||
                  lawyerCase.title.toLowerCase().contains(query) ||
                  lawyerCase.id.toString().contains(query) ||
                  lawyerCase.realCaseNumber.toLowerCase().contains(query) ||
                  lawyerCase.clientName.toLowerCase().contains(query);
              final matchesStatus = _matchesStatusFilter(lawyerCase);
              return matchesSearch && matchesStatus;
            }).toList();

            return RefreshIndicator(
              onRefresh: () => context.read<LawyerCasesCubit>().getCases(
                type: state.currentType,
              ),
              color: context.accentGolden,
              child: Column(
                children: [
                  _buildSearchAndFilter(context),
                  Expanded(
                    child: SafeArea(
                      child: filteredCases.isEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) =>
                                  SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 36.h,
                                        bottom: 48.h,
                                      ),
                                      child: CustomEmptyState(
                                        title: _searchQuery.isEmpty
                                            ? AppStrings.noCases.tr(context)
                                            : AppStrings.noResults.tr(context),
                                        subtitle: _searchQuery.isEmpty
                                            ? AppStrings.noCasesSubtitle.tr(
                                                context,
                                              )
                                            : AppStrings
                                                .noSearchResultsSubtitle
                                                .tr(context),
                                        icon: _searchQuery.isEmpty
                                            ? Icons.gavel_outlined
                                            : Icons.search_off_rounded,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(12.w),
                              itemCount: filteredCases.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 0.h),
                              itemBuilder: (context, index) =>
                                  CaseCard(lawyerCase: filteredCases[index]),
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

  Widget _buildSearchAndFilter(BuildContext context) {
    final filters = [
      _CaseStatusFilter('all', AppStrings.all.tr(context)),
      _CaseStatusFilter('ongoing', AppStrings.inProgress.tr(context)),
      _CaseStatusFilter('completed', AppStrings.completed.tr(context)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: AppStrings.searchByCaseIdOrTitle.tr(context),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.textSecondary,
              ),
              filled: true,
              fillColor: context.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: 8.w,
              children: filters.map((filter) {
                final isSelected = _selectedType == filter.type;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: isSelected,
                  onSelected: (v) {
                    if (v) {
                      setState(() => _selectedType = filter.type);
                      context.read<LawyerCasesCubit>().getCases(
                        type: filter.type,
                      );
                    }
                  },
                  selectedColor: context.accentGolden,
                  labelStyle: context.text.labelSmall?.copyWith(
                    color: isSelected
                        ? context.colors.onPrimary
                        : context.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: context.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: isSelected
                          ? context.accentGolden
                          : context.divColor,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  bool _matchesStatusFilter(LawyerCase lawyerCase) {
    if (_selectedType == 'all') return true;

    final key = lawyerCase.statusKey.toString().trim().toLowerCase();
    final text = lawyerCase.statusText.toString().trim().toLowerCase();

    if (_selectedType == 'ongoing') {
      return {
            'accepted',
            'active',
            'ongoing',
            'in_progress',
            'in-progress',
            'processing',
          }.contains(key) ||
          text.contains('جاري') ||
          text.contains('جارية') ||
          text.contains('قيد') ||
          text.contains('ongoing') ||
          text.contains('progress') ||
          text.contains('accepted');
    }

    if (_selectedType == 'completed') {
      return {
            'completed',
            'complete',
            'finished',
            'closed',
            'done',
          }.contains(key) ||
          text.contains('مكتمل') ||
          text.contains('مكتملة') ||
          text.contains('منتهي') ||
          text.contains('منتهية') ||
          text.contains('completed') ||
          text.contains('finished');
    }

    return true;
  }
}

class _CaseStatusFilter {
  final String type;
  final String label;

  const _CaseStatusFilter(this.type, this.label);
}
