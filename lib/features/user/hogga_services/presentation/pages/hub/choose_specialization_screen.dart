import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/user/home/data/models/categories_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';

class ChooseSpecializationScreen extends StatefulWidget {
  final Category category;
  final SubCategory subCategory;

  const ChooseSpecializationScreen({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  State<ChooseSpecializationScreen> createState() => _ChooseSpecializationScreenState();
}

class _ChooseSpecializationScreenState extends State<ChooseSpecializationScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.subCategory.id != null) {
      context.read<HomeCubit>().loadChildCategories(widget.subCategory.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          widget.category.name,
          style: context.theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subCategory.name,
                  style: context.text.titleSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                AppSizes.h(4),
                Text(
                  AppStrings.chooseSpecialization.tr(context),
                  style: context.text.bodySmall?.copyWith(color: context.textSecondary, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.isLoadingChildCategories) {
                  return _buildShimmerList(context);
                }

                final children = state.childCategories;

                if (children.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.comingSoon.tr(context),
                      style: TextStyle(color: context.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: children.length,
                  separatorBuilder: (_, __) => AppSizes.h(12),
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return _buildChildCard(context, child);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildChildCard(BuildContext context, SubCategory child) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.serviceSubtypes,
          arguments: {
            'childCategoryId': child.id,
            'sectionName': widget.category.name,
            'subCategoryName': widget.subCategory.name,
            'childCategoryName': child.name,
            'subCategoryPrice': double.tryParse(widget.subCategory.price ?? '0') ?? 0.0,
          },
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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            AppSizes.w(16),
            Expanded(
              child: Text(
                child.name,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
