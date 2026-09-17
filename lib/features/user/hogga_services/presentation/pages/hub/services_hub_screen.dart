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
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/injection_container.dart' as di;
import 'package:hogga/features/user/home/data/repositories/home_repository.dart';
import 'package:shimmer/shimmer.dart';

class ServicesHubScreen extends StatefulWidget {
  final int initialIndex;

  const ServicesHubScreen({super.key, this.initialIndex = 0});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final categories = context.read<HomeCubit>().state.categories;
    _tabController = TabController(
      length: categories.isNotEmpty
          ? categories.length
          : 1, // Will be updated when data arrives
      initialIndex:
          widget.initialIndex < (categories.isNotEmpty ? categories.length : 1)
          ? widget.initialIndex
          : 0,
      vsync: this,
    );

    // Load subcategories for initial category if state is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeCubit>().state;
      if (state.categories.isNotEmpty) {
        final index = widget.initialIndex < state.categories.length
            ? widget.initialIndex
            : 0;
        context.read<HomeCubit>().loadSubCategories(state.categories[index].id);
      }
    });

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final state = context.read<HomeCubit>().state;
      if (state.categories.isNotEmpty &&
          _tabController.index < state.categories.length) {
        context.read<HomeCubit>().loadSubCategories(
          state.categories[_tabController.index].id,
        );
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
          appBar: MainAppbar(
            title: AppStrings.hoggaServicesHub.tr(context),
          ),
          body: Column(
            children: [
              // TabBar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: context.divColor, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: context.colors.primary,
                  unselectedLabelColor: context.textSecondary,
                  indicatorColor: context.colors.primary,
                  indicatorWeight: 3,
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    return _CategoryTabContent(category: category);
                  }).toList(),
                ),
              ),
            ],
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
}

class _CategoryTabContent extends StatefulWidget {
  final Category category;

  const _CategoryTabContent({required this.category});

  @override
  State<_CategoryTabContent> createState() => _CategoryTabContentState();
}

class _CategoryTabContentState extends State<_CategoryTabContent>
    with AutomaticKeepAliveClientMixin {
  List<SubCategory>? _subCategories;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await di.sl<HomeRepository>().getSubCategories(widget.category.id);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _subCategories = const [];
        });
      },
      (list) {
        setState(() {
          _isLoading = false;
          _subCategories = list;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return _buildShimmerList(context);
    }

    final subCategories = _subCategories ?? const [];
    if (subCategories.isEmpty) {
      return Center(
        child: Text(
          AppStrings.comingSoon.tr(context),
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: context.accentGolden,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: subCategories.length,
        separatorBuilder: (context, index) => AppSizes.h(12),
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          return _buildServiceCard(
            context,
            widget.category,
            subCategory,
          );
        },
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      separatorBuilder: (context, index) => AppSizes.h(12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[100]!,
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

  IconData _getIconForServiceType(String? type, String categoryName) {
    if (type == 'article' || type == 'chat') return Icons.chat_outlined;
    if (type == 'video' ||
        type == 'audio_video' ||
        type == 'audio' ||
        type == 'phone' ||
        type == 'call') {
      return Icons.phone_in_talk_rounded;
    }
    return Icons.article_outlined;
  }

  Widget _buildServiceCard(
    BuildContext context,
    Category category,
    SubCategory subCategory,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chooseSpecialization,
          arguments: {'category': category, 'subCategory': subCategory},
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5.sp,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (subCategory.description != null &&
                      subCategory.description!.isNotEmpty) ...[
                    AppSizes.h(8),
                    Text(
                      subCategory.description!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                  if (subCategory.publishingFee != null &&
                      subCategory.publishingFee! > 0) ...[
                    AppSizes.h(6),
                    Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 13,
                          color: AppColors.golden,
                        ),
                        AppSizes.w(4),
                        Text(
                          '${AppStrings.stepPlatformFees.tr(context)}: ${subCategory.publishingFee!.toStringAsFixed(2)} ${AppStrings.currencySymbol.tr(context)}',
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: AppColors.golden,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (subCategory.isCallType &&
                      subCategory.duration != null) ...[
                    AppSizes.h(4),
                    Row(
                      children: [
                        Text(
                          "${AppStrings.callDurationLabel.tr(context)}:",
                          style: context.text.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Color(0xFF27AE60),
                        ),
                        AppSizes.w(4),
                        Text(
                          '${subCategory.duration} ${AppStrings.minutesLabel.tr(context)}',
                          style: context.text.labelSmall?.copyWith(
                            color: const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                            fontSize: 9.5.sp,
                          ),
                        ),
                      ],
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
