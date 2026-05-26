import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_state.dart';

import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';

import '../../../../../../core/utils/app_assets.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_strings.dart';

class LawyerProfileScreen extends StatefulWidget {
  final int providerId;
  const LawyerProfileScreen({super.key, required this.providerId});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadProviderDetails(widget.providerId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => 
          previous.isLoadingProviderDetails != current.isLoadingProviderDetails || 
          previous.selectedProviderDetails != current.selectedProviderDetails,
      builder: (context, state) {
        if (state.isLoadingProviderDetails) {
          return Scaffold(
            backgroundColor: context.pageBg,
            body: _buildShimmerLoading(context),
          );
        }

        final lawyer = state.selectedProviderDetails;
        if (lawyer == null) {
          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(child: Text(AppStrings.noDataFound.tr(context))),
          );
        }

        return Scaffold(
          backgroundColor: context.pageBg,
          appBar: AppBar(
            backgroundColor: context.colors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.cream, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildStaticHeader(context, lawyer),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(context, lawyer),
                      const SizedBox(height: 24),
                      _buildAboutSection(context, lawyer),
                      const SizedBox(height: 24),
                      _buildServicesSectionHeader(context, lawyer),
                      const SizedBox(height: 12),
                      _buildServicesList(context, lawyer),
                      const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticHeader(BuildContext context, dynamic lawyer) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: context.pageBg,
              backgroundImage: lawyer.photo != null && lawyer.photo!.isNotEmpty
                  ? CachedNetworkImageProvider(lawyer.photo!) as ImageProvider
                  : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
              child: lawyer.photo == null || lawyer.photo!.isEmpty
                  ? Icon(
                      lawyer.gender == 'female' ? Icons.woman_rounded : Icons.man_rounded,
                      size: 50,
                      color: context.colors.primary,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lawyer.name,
            style: context.text.titleLarge?.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.golden.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lawyer.level ?? AppStrings.licensedLawyer.tr(context),
              style: context.text.labelMedium?.copyWith(
                color: AppColors.golden,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, dynamic lawyer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(context, lawyer.rating.toString(), AppStrings.ratingLabel.tr(context), Icons.star_rounded, AppColors.golden),
        _buildStatItem(context, lawyer.experience, AppStrings.yearsExperience.tr(context), Icons.work_outline, Colors.blue),
        _buildStatItem(context, lawyer.orders.toString(), AppStrings.requestsCount.tr(context), Icons.assignment_turned_in_outlined, Colors.green),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(label, style: context.text.labelSmall?.copyWith(color: context.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, dynamic lawyer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.aboutLawyer.tr(context), style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          lawyer.bio,
          style: context.text.bodyMedium?.copyWith(height: 1.6, color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildServicesSectionHeader(BuildContext context, dynamic lawyer) {
    return Text(AppStrings.servicesAndPrices.tr(context), style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildServicesList(BuildContext context, dynamic lawyer) {
    final services = lawyer.services as List;
    if (services.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: services.map<Widget>((service) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.divColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(service.name, style: context.text.bodyMedium),
              ),
              const SizedBox(width: 12),
              Text(
                '${service.price} ${service.currency}',
                style: context.text.titleSmall?.copyWith(color: AppColors.golden, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.clientReviews.tr(context), style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            AppStrings.noDataFound.tr(context),
            style: context.text.labelSmall?.copyWith(color: context.textSecondary),
          ),
        ),
      ],
    );
  }


  Widget _buildShimmerLoading(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmer.rectangular(height: 300),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) => CustomShimmer.rectangular(
                    width: 100, 
                    height: 80, 
                    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  )),
                ),
                const SizedBox(height: 30),
                CustomShimmer.rectangular(height: 20, width: 150),
                const SizedBox(height: 15),
                CustomShimmer.rectangular(height: 100, width: double.infinity),
                const SizedBox(height: 20),
                CustomShimmer.rectangular(height: 20, width: 200),
                const SizedBox(height: 15),
                CustomShimmer.rectangular(height: 50, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
