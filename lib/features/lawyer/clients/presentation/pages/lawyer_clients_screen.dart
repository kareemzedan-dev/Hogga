import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/features/lawyer/clients/presentation/cubit/lawyer_clients_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/lawyer/clients/domain/entities/lawyer_client.dart';
import 'package:hogga/injection_container.dart';

class LawyerClientsScreen extends StatefulWidget {
  const LawyerClientsScreen({super.key});

  @override
  State<LawyerClientsScreen> createState() => _LawyerClientsScreenState();
}

class _LawyerClientsScreenState extends State<LawyerClientsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.pageBg,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: context.divColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        title: Text(
          AppStrings.clients.tr(context),
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => sl<LawyerClientsCubit>()..getClients(),
        child: SafeArea(
          child: BlocBuilder<LawyerClientsCubit, LawyerClientsState>(
            builder: (context, state) {
            if (state is LawyerClientsLoading) {
              return const LawyerShimmerLoading();
            } else if (state is LawyerClientsError) {
              return CustomErrorState(
                message: state.message,
                onRetry: () => context.read<LawyerClientsCubit>().getClients(),
              );
            } else if (state is LawyerClientsLoaded) {
              final filteredClients = state.clients.where((c) => c.name.contains(_searchQuery)).toList();
  
              if (state.clients.isEmpty) {
                return CustomEmptyState(
                  title: AppStrings.noClients.tr(context),
                  subtitle: AppStrings.noClientsSubtitle.tr(context),
                  icon: Icons.people_outline,
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<LawyerClientsCubit>().getClients(),
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    Expanded(
                      child: filteredClients.isEmpty
                      ? CustomEmptyState(
                              title: AppStrings.noResults.tr(context),
                              subtitle: AppStrings.noResultsSubtitle.tr(context),
                              icon: Icons.search_off_rounded,
                            )
                          : ListView.separated(
                              padding: EdgeInsets.all(20.w),
                              itemCount: filteredClients.length,
                              separatorBuilder: (_, __) => SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                return _buildClientCard(context, filteredClients[index]);
                              },
                            ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

  Widget _buildSearchBar(BuildContext context) {
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
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: AppStrings.searchByClientName.tr(context),
          prefixIcon: Icon(Icons.search_rounded, color: context.textSecondary),
          filled: true,
          fillColor: context.pageBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, LawyerClient client) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.divColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.accentGolden.withValues(alpha: 0.1),
            backgroundImage: client.photo != null && client.photo!.isNotEmpty
                ? CachedNetworkImageProvider(client.photo!) as ImageProvider
                : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
            child: client.photo == null ? Icon(Icons.person, color: context.accentGolden) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  client.activeCasesText ?? '',
                  style: context.text.bodySmall?.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AppSnackbar.showSuccess(context, messageKey: AppStrings.callUnderDevelopment);
            },
            icon: const Icon(Icons.call_outlined, color: Colors.green),
          ),
          IconButton(
            onPressed: () {
              AppSnackbar.showSuccess(context, messageKey: AppStrings.chatUnderDevelopment);
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2D9CDB)),
          ),
        ],
      ),
    );
  }
}
