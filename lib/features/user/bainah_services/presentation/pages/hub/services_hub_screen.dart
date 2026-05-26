import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';
import 'package:hogga/features/user/home/data/models/categories_model.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class ServicesHubScreen extends StatefulWidget {
  final int initialIndex;

  const ServicesHubScreen({super.key, this.initialIndex = 0});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final categories = context.read<HomeCubit>().state.categories;
    _tabController = TabController(
      length: categories.isNotEmpty ? categories.length : 1, // Will be updated when data arrives
      initialIndex: widget.initialIndex < (categories.isNotEmpty ? categories.length : 1) ? widget.initialIndex : 0,
      vsync: this,
    );
    
    // Load subcategories for initial category if state is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeCubit>().state;
      if (state.categories.isNotEmpty) {
        final index = widget.initialIndex < state.categories.length ? widget.initialIndex : 0;
        context.read<HomeCubit>().loadSubCategories(state.categories[index].id);
      }
    });

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final state = context.read<HomeCubit>().state;
      if (state.categories.isNotEmpty && _tabController.index < state.categories.length) {
        context.read<HomeCubit>().loadSubCategories(state.categories[_tabController.index].id);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final categories = state.categories;
        if (categories.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Update tab controller if length changed
        if (_tabController.length != categories.length) {
           final oldIndex = _tabController.index;
           _tabController.removeListener(_onTabChanged);
           _tabController.dispose();
           _tabController = TabController(
             length: categories.length,
             initialIndex: oldIndex < categories.length ? oldIndex : 0,
             vsync: this,
           );
           _tabController.addListener(_onTabChanged);
        }

        return Scaffold(
          backgroundColor: context.pageBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: context.textPrimary),
            title: Text(
              AppStrings.bainahServicesHub.tr(context),
              style: context.theme.appBarTheme.titleTextStyle,
            ),
          ),
          body: Column(
            children: [
              // TabBar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.divColor,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: context.colors.primary,
                  unselectedLabelColor: context.textSecondary,
                  indicatorColor: context.colors.primary,
                  indicatorWeight: 3,
                  labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
                  tabs: categories.map((category) {
                    return Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(category.name, style: context.text.titleSmall),
                            AppSizes.w(8),
                            Icon(_getIconForCategory(category.name), size: 16),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: categories.map((category) {
                    return BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        // If this is the active tab, use the loaded subcategories
                        // Otherwise, use the nested ones (fallback)
                        final isActive = categories.indexOf(category) == _tabController.index;
                        final subCategories = (isActive && state.subCategories.isNotEmpty) 
                            ? state.subCategories 
                            : (category.subCategories ?? []);

                        if (state.isLoadingSubCategories && isActive) {
                          return _buildShimmerList(context);
                        }

                        if (subCategories.isEmpty) {
                          return Center(
                            child: Text(
                              AppStrings.comingSoon.tr(context),
                              style: TextStyle(color: context.textSecondary),
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: subCategories.length,
                          separatorBuilder: (context, index) => AppSizes.h(12),
                          itemBuilder: (context, index) {
                            final subCategory = subCategories[index];
                            return _buildServiceCard(context, category, subCategory);
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      separatorBuilder: (context, index) => AppSizes.h(12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('personal')) return Icons.balance_outlined;
    if (name.contains('criminal')) return Icons.gavel_outlined;
    if (name.contains('commercial')) return Icons.business_center_outlined;
    if (name.contains('real estate')) return Icons.home_work_outlined;
    if (name.contains('labor')) return Icons.work_outlined;
    if (name.contains('administrative')) return Icons.account_balance_outlined;
    return Icons.miscellaneous_services_rounded;
  }

  IconData _getIconForServiceType(String? type, String categoryName) {
    if (type == 'article' || type == 'chat') return Icons.chat_outlined;
    if (type == 'video') return Icons.videocam_outlined;
    if (type == 'audio' || type == 'phone') return Icons.phone_outlined;
    return Icons.article_outlined;
  }

  Widget _buildServiceCard(BuildContext context, Category category, SubCategory subCategory) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.chooseSpecialization, 
          arguments: {
            'category': category,
            'subCategory': subCategory,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.chipBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForServiceType(subCategory.serviceType, category.name),
                color: context.colors.primary,
                size: 24,
              ),
            ),
            AppSizes.w(16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(
                         child: Text(
                            subCategory.name,
                             style: Theme.of(context).textTheme.titleSmall?.copyWith(
                               color: context.textPrimary,
                               fontWeight: FontWeight.bold,
                               fontSize: 12.5.sp,
                             ),
                          ),
                       ),
                     ],
                   ),
                  if (subCategory.description != null && subCategory.description!.isNotEmpty) ...[
                    AppSizes.h(8),
                    Text(
                      subCategory.description!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
