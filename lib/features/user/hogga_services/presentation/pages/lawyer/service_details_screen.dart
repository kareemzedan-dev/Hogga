import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';

import '../../../../../../config/routes/app_routes.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadServiceDetails(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoadingServiceDetails) {
            return _buildShimmerLoading(context);
          }

          final details = state.selectedServiceDetails;
          if (details == null) {
            return Center(child: Text(AppStrings.noDataFound.tr(context)));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, details),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(context, details),
                      const SizedBox(height: 24),
                      _buildAboutSection(context, details),
                      const SizedBox(height: 24),
                      _buildCategoryHierarchy(context, details),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.selectedServiceDetails == null) return const SizedBox.shrink();
          return _buildBottomAction(context, state.selectedServiceDetails!);
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic details) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (details.providerImage != null && details.providerImage!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: details.providerImage!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  child: Icon(Icons.business_center, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                ),
              )
            else
              Container(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                child: Icon(Icons.business_center, size: 80, color: Colors.white.withValues(alpha: 0.5)),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, dynamic details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                details.name,
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppStrings.priceWithCurrency.tr(context, namedArgs: {'price': details.price}),
                style: context.text.titleMedium?.copyWith(
                  color: AppColors.golden,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person_outline, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                if (details.providerId != null) {
                  Navigator.pushNamed(context, AppRoutes.lawyerProfile, arguments: details.providerId);
                }
              },
              child: Text(
                details.providerName ?? '',
                style: context.text.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.star_rounded, color: AppColors.golden, size: 18),
            const SizedBox(width: 4),
            Text(
              details.avgRating.toString(),
              style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, dynamic details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.aboutService.tr(context),
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          details.description.isEmpty ? AppStrings.noDescriptionAvailable.tr(context) : details.description,
          style: context.text.bodyMedium?.copyWith(height: 1.6, color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCategoryHierarchy(BuildContext context, dynamic details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryItem(context, AppStrings.category.tr(context), details.categoryName),
          const Divider(height: 24),
          _buildCategoryItem(context, AppStrings.subCategory.tr(context), details.subCategoryName),
          const Divider(height: 24),
          _buildCategoryItem(context, AppStrings.childCategory.tr(context), details.childCategoryName),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.text.bodySmall?.copyWith(color: context.textSecondary)),
        Text(value ?? '-', style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, dynamic details) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.pageBg,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Booking logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                AppStrings.requestConsultationNow.tr(context),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.golden.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.golden),
              onPressed: () {
                // Chat logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(height: 250, color: context.divColor.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 30, width: 200, color: context.divColor.withValues(alpha: 0.3)),
                    Container(height: 40, width: 80, color: context.divColor.withValues(alpha: 0.3)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 20, width: 150, color: context.divColor.withValues(alpha: 0.3)),
                const SizedBox(height: 30),
                Container(height: 20, width: 100, color: context.divColor.withValues(alpha: 0.3)),
                const SizedBox(height: 15),
                Container(height: 150, width: double.infinity, color: context.divColor.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
