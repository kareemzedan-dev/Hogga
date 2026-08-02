import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/library/data/models/lawyer_library_model.dart';
import 'package:hogga/features/lawyer/library/presentation/cubit/lawyer_library_cubit.dart';
import 'package:hogga/injection_container.dart';

class LawyerLegalLibraryScreen extends StatefulWidget {
  const LawyerLegalLibraryScreen({super.key});

  @override
  State<LawyerLegalLibraryScreen> createState() =>
      _LawyerLegalLibraryScreenState();
}

class _LawyerLegalLibraryScreenState extends State<LawyerLegalLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LawyerLibraryCubit>()..searchLibrary(''),
      child: BlocBuilder<LawyerLibraryCubit, LawyerLibraryState>(
        builder: (context, state) {
          final isNested =
              state is LawyerLibraryLoaded &&
              (state.articles != null || state.articleDetails != null);

          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: MainAppbar(
              title: AppStrings.legalLibrary.tr(context),
              onBack: () => _handleBack(context, state),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isNested) _buildSearchBar(context),
                  if (!isNested) SizedBox(height: 24.h),
                  if (state is LawyerLibraryLoading)
                    const LawyerShimmerLoading()
                  else if (state is LawyerLibraryError)
                    Center(child: Text(state.message.tr(context)))
                  else if (state is LawyerLibraryLoaded)
                    _buildLoadedContent(context, state)
                  else
                    _buildCategoriesGrid(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, LawyerLibraryLoaded state) {
    if (state.articleDetails != null) {
      return _buildArticleDetails(context, state.articleDetails!);
    }

    if (state.articles != null) {
      return _buildArticlesList(context, state.articles!);
    }

    if (_searchController.text.trim().isEmpty) {
      return _buildLibraryHome(context, state.items);
    }

    return _buildSearchResults(context, state.items);
  }

  void _handleBack(BuildContext context, LawyerLibraryState state) {
    final cubit = context.read<LawyerLibraryCubit>();

    if (state is LawyerLibraryLoaded &&
        (state.articleDetails != null || state.articles != null)) {
      cubit.goBack();
      return;
    }

    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      cubit.searchLibrary('');
      setState(() {});
      return;
    }

    Navigator.pop(context);
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.textSecondary),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchByLawOrLegislation.tr(context),
                hintStyle: context.text.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (value) {
                context.read<LawyerLibraryCubit>().searchLibrary(value);
                setState(() {});
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: context.textSecondary,
                size: 20.sp,
              ),
              onPressed: () {
                _searchController.clear();
                context.read<LawyerLibraryCubit>().searchLibrary('');
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLibraryHome(
    BuildContext context,
    List<LawyerLibraryItemModel> items,
  ) {
    if (items.isEmpty) {
      return _buildCategoriesGrid(context);
    }

    return _buildSearchResults(context, items);
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<LawyerLibraryItemModel> items,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            AppStrings.noDataFound.tr(context),
            style: context.text.labelSmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      );
    }

    final categories = items
        .where((item) => item.type.toLowerCase() == 'category')
        .toList();
    final articles = items
        .where((item) => item.type.toLowerCase() == 'article')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (categories.isNotEmpty) ...[
          Text(
            AppStrings.legalCategories.tr(context),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _buildResultItem(context, categories[index]),
          ),
          SizedBox(height: 24.h),
        ],
        if (articles.isNotEmpty) ...[
          Text(
            AppStrings.legalArticles.tr(context),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _buildResultItem(context, articles[index]),
          ),
        ],
      ],
    );
  }

  Widget _buildArticleDetails(
    BuildContext context,
    LawyerLibraryArticleDetailsModel details,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.title,
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: context.accentGolden.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                details.category.name,
                style: context.text.labelSmall?.copyWith(
                  color: context.accentGolden,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.visibility_outlined,
              size: 14.sp,
              color: context.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              '${details.views} ${AppStrings.views.tr(context)}',
              style: context.text.labelSmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        LawyerCard(
          padding: EdgeInsets.all(16.w),
          child: Text(
            details.content,
            style: context.text.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          '${AppStrings.createdAt.tr(context)}: ${details.createdAt.split('T').first}',
          style: context.text.labelSmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesList(
    BuildContext context,
    List<LawyerLibraryArticleModel> articles,
  ) {
    if (articles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            AppStrings.noDataFound.tr(context),
            style: context.text.labelSmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final article = articles[index];
        return LawyerCard(
          onTap: () {
            context.read<LawyerLibraryCubit>().fetchArticleDetails(article.id);
          },
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 14.sp,
                    color: context.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${article.views} ${AppStrings.views.tr(context)}',
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    article.createdAt.split('T').first,
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultItem(BuildContext context, LawyerLibraryItemModel item) {
    final type = item.type.toLowerCase();
    final isCategory = type == 'category';

    return LawyerCard(
      onTap: () {
        if (isCategory) {
          context.read<LawyerLibraryCubit>().fetchCategoryArticles(item.id);
        } else {
          context.read<LawyerLibraryCubit>().fetchArticleDetails(item.id);
        }
      },
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(
            isCategory ? Icons.folder_rounded : Icons.article_rounded,
            color: isCategory ? context.accentGolden : Colors.blue,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              item.name,
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.legalCategories.tr(context),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.2,
          children: [
            _buildCategoryItem(
              context,
              AppStrings.criminalLaw.tr(context),
              Icons.gavel_rounded,
              Colors.red,
            ),
            _buildCategoryItem(
              context,
              AppStrings.commercialLaw.tr(context),
              Icons.business_center_rounded,
              Colors.blue,
            ),
            _buildCategoryItem(
              context,
              AppStrings.personalStatus.tr(context),
              Icons.family_restroom_rounded,
              Colors.pink,
            ),
            _buildCategoryItem(
              context,
              AppStrings.laborLaw.tr(context),
              Icons.engineering_rounded,
              Colors.orange,
            ),
            _buildCategoryItem(
              context,
              AppStrings.civilLaw.tr(context),
              Icons.account_balance_rounded,
              Colors.teal,
            ),
            _buildCategoryItem(
              context,
              AppStrings.omanLaws.tr(context),
              Icons.history_edu_rounded,
              context.accentGolden,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return LawyerCard(
      onTap: () {
        _searchController.text = title;
        context.read<LawyerLibraryCubit>().searchLibrary(title);
        setState(() {});
      },
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            style: context.text.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
