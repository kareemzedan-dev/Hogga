import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:flutter/material.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// A single service card shown in the home screen "How can we help you?" section.
class HomeServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> subServices;
  final Color accentColor;
  final VoidCallback? onTap;

  const HomeServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.subServices,
    this.accentColor = AppColors.golden,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveAccentColor = context.isDark 
        ? (accentColor == AppColors.primary || accentColor == const Color(0xFF2E7D5E) || accentColor == AppColors.deepOrange 
            ? AppColors.golden 
            : accentColor)
        : accentColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: HoggaCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: effectiveAccentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: context.theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.start,
                        style: context.text.titleSmall?.copyWith(color: context.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    description,
                    textAlign: TextAlign.start,
                    style: context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              if (subServices.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subServices.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: effectiveAccentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: effectiveAccentColor.withValues(alpha: 0.8),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          service,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: effectiveAccentColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
      ),
    );
  }
}

/// The full "كيف يمكننا مساعدتك؟" services section
class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({super.key});

  IconData _getIconForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('personal')) return Icons.balance_rounded;
    if (name.contains('criminal')) return Icons.gavel_rounded;
    if (name.contains('commercial')) return Icons.business_center_rounded;
    if (name.contains('real estate')) return Icons.home_work_rounded;
    if (name.contains('labor')) return Icons.work_rounded;
    if (name.contains('administrative')) return Icons.account_balance_rounded;
    return Icons.miscellaneous_services_rounded;
  }

  Color _getColorForCategory(int index) {
    return index % 2 == 0 ? AppColors.golden : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => 
          previous.categories != current.categories || 
          previous.isLoadingCategories != current.isLoadingCategories,
      builder: (context, state) {
        final categories = state.categories;
        
        if (categories.isEmpty && !state.isLoadingCategories) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  AppStrings.howCanWeHelp.tr(context),
                  textAlign: TextAlign.start,
                  style: context.text.headlineSmall?.copyWith(color: context.textPrimary),
                ),
              ),
            ),
            if (state.isLoadingCategories && categories.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return HomeServiceCard(
                    icon: _getIconForCategory(category.name),
                    title: category.name,
                    description: category.description ?? '',
                    subServices: category.subCategories?.map((e) => e.name).toList() ?? [],
                    accentColor: _getColorForCategory(index),
                    onTap: () => Navigator.pushNamed(
                      context, 
                      AppRoutes.servicesHub, 
                      arguments: index,
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

