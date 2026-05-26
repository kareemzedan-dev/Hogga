import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case_details.dart';
import 'package:hogga/features/lawyer/cases/presentation/cubit/lawyer_cases_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/core/widgets/custom_button.dart';

import '../widgets/add_session_sheet.dart';
import '../widgets/upload_document_sheet.dart';

class LawyerCaseDetailsScreen extends StatefulWidget {
  const LawyerCaseDetailsScreen({super.key});

  @override
  State<LawyerCaseDetailsScreen> createState() => _LawyerCaseDetailsScreenState();
}

class _LawyerCaseDetailsScreenState extends State<LawyerCaseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return BlocProvider(
      create: (context) {
        final cubit = sl<LawyerCasesCubit>();
        if (args != null && args['id'] != null) {
          cubit.getCaseDetails(args['id'] as int);
        }
        return cubit;
      },
      child: BlocConsumer<LawyerCasesCubit, LawyerCasesState>(
        listener: (context, state) {
          if (state is LawyerCaseActionSuccess) {
            AppSnackbar.showSuccess(context, message: state.message);
          } else if (state is LawyerCasesError) {
            AppSnackbar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LawyerCasesCubit>();
          final detailsData = state is LawyerCaseDetailsLoaded
              ? state.caseDetails
              : cubit.currentCaseDetails;

          if (state is LawyerCaseDetailsLoading || state is LawyerCasesInitial) {
            return Scaffold(
              backgroundColor: context.pageBg,
              body: const LawyerShimmerLoading(),
            );
          }

          if (detailsData == null) {
            if (state is LawyerCasesError) {
              return Scaffold(
                backgroundColor: context.pageBg,
                body: Center(child: Text(state.message.tr(context))),
              );
            }
            return Scaffold(
              backgroundColor: context.pageBg,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: AppBar(
              title: Text(
                detailsData.title,
                style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(context, detailsData),
                    const SizedBox(height: 24),
                    _buildCaseInfo(context, detailsData),
                    const SizedBox(height: 24),
                    _buildTimeline(context, detailsData),
                    const SizedBox(height: 24),
                    _buildAttachments(context, detailsData),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CustomButton(
                  text: AppStrings.addCaseUpdate.tr(context),
                  isLoading: state is LawyerCaseActionLoading,
                  onPressed: () => _showAddSessionSheet(context, detailsData.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context, int caseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSessionSheet(
        caseId: caseId,
        onConfirm: (title, date, details) {
          context.read<LawyerCasesCubit>().addCaseSession(
                caseId: caseId,
                title: title,
                date: date,
                details: details,
              );
        },
      ),
    );
  }

  void _showUploadDocumentSheet(BuildContext context, int caseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UploadDocumentSheet(
        caseId: caseId,
        onConfirm: (title, document) {
          context.read<LawyerCasesCubit>().uploadCaseDocument(
                caseId: caseId,
                title: title,
                document: document,
              );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, LawyerCaseDetails details) {
    return LawyerCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.caseNumber.tr(context, namedArgs: {'id': ''})} ${details.caseNumber}',
                style: context.text.labelMedium?.copyWith(color: context.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                details.statusText,
                style: context.text.titleMedium?.copyWith(
                  color: AppColors.golden,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.golden.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gavel_rounded, color: AppColors.golden),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseInfo(BuildContext context, LawyerCaseDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LawyerSectionHeader(title: AppStrings.clientDetails.tr(context)),
        LawyerCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                backgroundImage: details.client.photo != null && details.client.photo!.isNotEmpty
                    ? CachedNetworkImageProvider(details.client.photo!) as ImageProvider
                    : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
                child: details.client.photo == null ? const Icon(Icons.person, color: AppColors.cream) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details.client.name, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (details.client.phone != null)
                    Text(details.client.phone!, style: context.text.bodySmall?.copyWith(color: context.textSecondary)),
                ],
              ),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.call, color: Colors.green)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, LawyerCaseDetails details) {
    final allSessions = [...details.sessions.upcoming, ...details.sessions.previous];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LawyerSectionHeader(title: AppStrings.sessionsHistory.tr(context)),
        if (allSessions.isEmpty)
          LawyerCard(
            child: Center(
              child: Text(
                AppStrings.noDataFound.tr(context),
                style: context.text.labelSmall?.copyWith(color: context.textSecondary),
              ),
            ),
          )
        else
          ...allSessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTimelineItem(
                context,
                session.title,
                session.date,
                session.details,
                session.isUpcoming,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String title, String date, String desc, bool isNext) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isNext ? AppColors.golden : context.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNext ? AppColors.golden : context.textPrimary,
                ),
              ),
              Text(date, style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
              const SizedBox(height: 4),
              Text(desc, style: context.text.bodySmall?.copyWith(color: context.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachments(BuildContext context, LawyerCaseDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LawyerSectionHeader(
          title: AppStrings.attachedDocuments.tr(context),
          actionLabel: AppStrings.addAction.tr(context),
          onActionPressed: () => _showUploadDocumentSheet(context, details.id),
        ),
        if (details.documents.isEmpty)
          Center(
            child: Text(
              AppStrings.noDataFound.tr(context),
              style: context.text.labelSmall?.copyWith(color: context.textSecondary),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: details.documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = details.documents[index];
              return LawyerCard(
                child: Row(
                  children: [
                    Icon(
                      doc.type.contains('pdf') ? Icons.picture_as_pdf : Icons.image,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            doc.addedBy == 'user' ? AppStrings.byClient.tr(context) : AppStrings.byLawyer.tr(context),
                            style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, color: AppColors.golden),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
