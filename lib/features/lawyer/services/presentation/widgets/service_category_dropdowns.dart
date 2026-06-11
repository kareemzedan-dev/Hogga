import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';
import 'package:hogga/features/user/hogga_services/presentation/manager/item_categories_cubit.dart';

class ServiceCategoryDropdowns extends StatelessWidget {
  final int? selectedMainCategoryId;
  final int? selectedSubCategoryId;
  final Function(int?) onMainCategoryChanged;
  final Function(int?) onSubCategoryChanged;

  const ServiceCategoryDropdowns({
    super.key,
    required this.selectedMainCategoryId,
    required this.selectedSubCategoryId,
    required this.onMainCategoryChanged,
    required this.onSubCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainCategoryDropdown(context),
        SizedBox(height: 16.h),
        _buildSubCategoryDropdown(context),
      ],
    );
  }

  Widget _buildMainCategoryDropdown(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final categories = state.categories;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.divColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              hint: Text(AppStrings.chooseSpecialization.tr(context)),
              value: selectedMainCategoryId,
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) {
                onMainCategoryChanged(val);
                if (val != null) {
                  context.read<ItemCategoriesCubit>().getItemCategories(val);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryDropdown(BuildContext context) {
    return BlocBuilder<ItemCategoriesCubit, ItemCategoriesState>(
      builder: (context, state) {
        List<dynamic> items = [];
        if (state is ItemCategoriesSuccess) {
          items = state.items;
        }
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.divColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              hint: Text(AppStrings.chooseServiceType.tr(context)),
              value: selectedSubCategoryId,
              items: items.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name))).toList(),
              onChanged: onSubCategoryChanged,
            ),
          ),
        );
      },
    );
  }
}
