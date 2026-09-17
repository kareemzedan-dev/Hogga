import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case_details.dart';
import 'package:hogga/features/lawyer/cases/presentation/cubit/lawyer_cases_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/add_session_sheet.dart';
import '../widgets/upload_document_sheet.dart';
import '../../../chat/presentation/cubit/lawyer_chat_messages_cubit.dart';
import '../../../chat/presentation/cubit/lawyer_call_cubit.dart';
import '../../../chat/presentation/pages/lawyer_chat_screen.dart';
import '../../../chat/presentation/pages/lawyer_agora_call_screen.dart';

class LawyerCaseDetailsScreen extends StatefulWidget {
  const LawyerCaseDetailsScreen({super.key});

  @override
  State<LawyerCaseDetailsScreen> createState() =>
      _LawyerCaseDetailsScreenState();
}

class _LawyerCaseDetailsScreenState extends State<LawyerCaseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
            if (args != null && args['id'] != null) {
              context.read<LawyerCasesCubit>().getCaseDetails(
                args['id'] as int,
              );
            }
          } else if (state is LawyerCasesError) {
            AppSnackbar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LawyerCasesCubit>();
          final detailsData = state is LawyerCaseDetailsLoaded
              ? state.caseDetails
              : cubit.currentCaseDetails;

          if (state is LawyerCaseDetailsLoading ||
              state is LawyerCasesInitial) {
            return Scaffold(
              backgroundColor: context.pageBg,
              body: const LawyerShimmerLoading(),
            );
          }

          if (detailsData == null) {
            return Scaffold(
              backgroundColor: context.pageBg,
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: Center(
                child: state is LawyerCasesError
                    ? Text(state.message.tr(context))
                    : const CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: MainAppbar(title: detailsData.title),
            body: RefreshIndicator(
              color: AppColors.golden,
              onRefresh: () async {
                if (args?['id'] != null) {
                  await cubit.getCaseDetails(args!['id'] as int);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Gradient Header Card ──────────────────────────────────
                    _buildGradientHeader(context, detailsData),
                    SizedBox(height: 20.h),

                    // ── Action button if accepted ─────────────────────────────
                    if (detailsData.statusKey == 'accepted' &&
                        detailsData.hasChatRoom) ...[
                      _buildActionButton(context, detailsData, state),
                      SizedBox(height: 20.h),
                    ],

                    // ── Client Card ───────────────────────────────────────────
                    _buildClientCard(context, detailsData),
                    SizedBox(height: 20.h),

                    // ── Sessions ──────────────────────────────────────────────
                    _buildSessionsSection(context, detailsData),
                    SizedBox(height: 20.h),

                    // ── Documents ─────────────────────────────────────────────
                    _buildDocumentsSection(context, detailsData, state),
                    SizedBox(height: 20.h),

                    // ── Add Session Button ────────────────────────────────────
                    CustomButton(
                      text: AppStrings.addCaseUpdate.tr(context),
                      isLoading: state is LawyerCaseActionLoading,
                      onPressed: () =>
                          _showAddSessionSheet(context, cubit, detailsData.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Gradient Header (same style as OrderDetailsHeader) ──────────────────────
  Widget _buildGradientHeader(BuildContext context, LawyerCaseDetails details) {
    final serviceColor = _serviceColor(details.serviceType);
    final serviceLabel = details.serviceTypeText.isNotEmpty
        ? details.serviceTypeText
        : details.serviceType;
    final showServiceType = _shouldShowServiceType(
      details.serviceType,
      details.serviceTypeText,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.82),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Case number badge + service type
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  details.caseNumber.isNotEmpty
                      ? details.caseNumber
                      : '#${details.id}',
                  style: context.text.labelSmall?.copyWith(
                    color: AppColors.golden,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.referenceNumber.tr(context),
                style: context.text.labelSmall?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.6),
                  fontSize: 11.sp,
                ),
              ),
              const Spacer(),
              // Status badge
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              //   decoration: BoxDecoration(
              //     color: _statusColor(details.statusKey).withValues(alpha: 0.2),
              //     borderRadius: BorderRadius.circular(10.r),
              //     border: Border.all(
              //         color: _statusColor(details.statusKey).withValues(alpha: 0.5)),
              //   ),
              //   child: Text(
              //     details.statusText,
              //     style: context.text.labelSmall?.copyWith(
              //       color: _statusColor(details.statusKey),
              //       fontWeight: FontWeight.bold,
              //       fontSize: 11.sp,
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 14.h),
          // Title
          Text(
            details.title,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
          if (showServiceType) ...[
            SizedBox(height: 10.h),
            // Service type chip
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: serviceColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: serviceColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _serviceIcon(details.serviceType),
                        size: 12.sp,
                        color: serviceColor,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        serviceLabel,
                        style: context.text.labelSmall?.copyWith(
                          color: serviceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Action Button ────────────────────────────────────────────────────────────
  Widget _buildActionButton(
    BuildContext context,
    LawyerCaseDetails details,
    LawyerCasesState state,
  ) {
    final serviceType = details.serviceType;
    final serviceColor = _serviceColor(serviceType);
    final isCallType = _isCallType(serviceType);

    final icon = _isVideoType(serviceType)
        ? Icons.videocam_rounded
        : (isCallType
              ? Icons.phone_in_talk_rounded
              : Icons.chat_bubble_outline_rounded);
    final label = _isVideoType(serviceType)
        ? AppStrings.videoCall.tr(context)
        : (isCallType
              ? AppStrings.voiceCall.tr(context)
              : AppStrings.enterChat.tr(context));

    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: OutlinedButton.icon(
        onPressed: () => _openService(context, details),
        icon: Icon(icon, color: serviceColor, size: 18.sp),
        label: Text(
          label,
          style: context.text.labelLarge?.copyWith(
            color: serviceColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.5.sp,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: serviceColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  // ── Client Card (same style as OrderSummaryCard) ─────────────────────────────
  Widget _buildClientCard(BuildContext context, LawyerCaseDetails details) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.person_pin_rounded,
                size: 18.sp,
                color: AppColors.golden,
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.clientDetails.tr(context),
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(height: 1, thickness: 0.8, color: context.divColor),
          ),
          // Client info row
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage:
                    details.client.photo != null &&
                        details.client.photo!.isNotEmpty
                    ? CachedNetworkImageProvider(details.client.photo!)
                          as ImageProvider
                    : const AssetImage(AppAssets.userPlaceholder)
                          as ImageProvider,
                child:
                    details.client.photo == null ||
                        details.client.photo!.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 26.sp,
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.client.name.isNotEmpty
                          ? details.client.name
                          : AppStrings.client.tr(context),
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    if (details.client.phone != null &&
                        details.client.phone!.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          // Icon(Icons.phone_outlined,
                          //     size: 11.sp, color: context.textSecondary),
                          // SizedBox(width: 4.w),
                          // Text(4[[[[[[[[[[
                          //   details.client.!,
                          //   style: context.text.bodySmall?.copyWith(
                          //     color: context.textSecondary,
                          //     fontSize: 12.sp,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // if (details.client.phone != null && details.client.phone!.isNotEmpty)
              //   GestureDetector(
              //     onTap: () => launchUrl(
              //       Uri.parse('tel:${details.client.phone}'),
              //       mode: LaunchMode.externalApplication,
              //     ),
              //     child: Container(
              //       padding: EdgeInsets.all(10.w),
              //       decoration: BoxDecoration(
              //         color: const Color(0xFF27AE60).withValues(alpha: 0.1),
              //         shape: BoxShape.circle,
              //       ),
              //       child: Icon(Icons.call_rounded,
              //           color: const Color(0xFF27AE60), size: 20.sp),
              //     ),
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sessions Section ─────────────────────────────────────────────────────────
  Widget _buildSessionsSection(
    BuildContext context,
    LawyerCaseDetails details,
  ) {
    final upcoming = details.sessions.upcoming;
    final previous = details.sessions.previous;
    final hasAny = upcoming.isNotEmpty || previous.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 18.sp,
                color: AppColors.golden,
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.sessionsHistory.tr(context),
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(height: 1, thickness: 0.8, color: context.divColor),
          ),
          if (!hasAny)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 40.sp,
                      color: context.textSecondary.withValues(alpha: 0.35),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.noDataFound.tr(context),
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcoming.isNotEmpty) ...[
                  _buildSessionGroupLabel(
                    context,
                    AppStrings.upcomingSessions.tr(context),
                    AppColors.golden,
                  ),
                  SizedBox(height: 12.h),
                  ...upcoming.asMap().entries.map(
                    (e) => _buildSessionItem(
                      context,
                      e.value,
                      e.key == upcoming.length - 1,
                    ),
                  ),
                  if (previous.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Divider(color: context.divColor),
                    SizedBox(height: 8.h),
                  ],
                ],
                if (previous.isNotEmpty) ...[
                  _buildSessionGroupLabel(
                    context,
                    AppStrings.previousSessions.tr(context),
                    context.textSecondary,
                  ),
                  SizedBox(height: 12.h),
                  ...previous.asMap().entries.map(
                    (e) => _buildSessionItem(
                      context,
                      e.value,
                      e.key == previous.length - 1,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSessionGroupLabel(
    BuildContext context,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    LawyerCaseSession session,
    bool isLast,
  ) {
    final isUpcoming = session.isUpcoming;
    final dotColor = isUpcoming ? AppColors.golden : context.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: context.divColor,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUpcoming
                          ? AppColors.golden
                          : context.textPrimary,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11.sp,
                        color: context.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        session.date,
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  if (session.details.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      session.details,
                      style: context.text.bodySmall?.copyWith(
                        color: context.textPrimary,
                        height: 1.45,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Documents Section ────────────────────────────────────────────────────────
  Widget _buildDocumentsSection(
    BuildContext context,
    LawyerCaseDetails details,
    LawyerCasesState state,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 18.sp,
                color: AppColors.golden,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.attachedDocuments.tr(context),
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              // Upload button
              GestureDetector(
                onTap: state is LawyerCaseActionLoading
                    ? null
                    : () => _showUploadDocumentSheet(
                        context,
                        context.read<LawyerCasesCubit>(),
                        details.id,
                      ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppStrings.addAction.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(height: 1, thickness: 0.8, color: context.divColor),
          ),
          if (details.documents.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 40.sp,
                      color: context.textSecondary.withValues(alpha: 0.35),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.noDataFound.tr(context),
                      style: context.text.labelSmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.documents.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) =>
                  _buildDocumentItem(context, details.documents[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, LawyerCaseDocument doc) {
    final isPdf = doc.type.toLowerCase().contains('pdf');
    final isImage =
        doc.type.toLowerCase().contains('image') ||
        doc.type.toLowerCase().contains('png') ||
        doc.type.toLowerCase().contains('jpg');
    final isAddedByLawyer = doc.addedBy == 'provider';
    final docColor = isAddedByLawyer ? AppColors.primary : AppColors.golden;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.divColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: docColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf_rounded
                  : (isImage
                        ? Icons.image_rounded
                        : Icons.insert_drive_file_rounded),
              color: docColor,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: docColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    isAddedByLawyer
                        ? AppStrings.byLawyer.tr(context)
                        : AppStrings.byClient.tr(context),
                    style: context.text.labelSmall?.copyWith(
                      color: docColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(doc.url),
              mode: LaunchMode.externalApplication,
            ),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.download_for_offline_outlined,
                color: AppColors.golden,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Service Navigation ────────────────────────────────────────────────────────
  void _openService(BuildContext context, LawyerCaseDetails details) {
    final serviceType = details.serviceType;
    if (_isCallType(serviceType)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<LawyerCallCubit>(),
            child: LawyerAgoraCallScreen(
              roomId: details.chatRoomId!,
              clientName: details.client.name,
              isVideo: _isVideoType(serviceType),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    sl<LawyerChatMessagesCubit>(param1: details.chatRoomId!)
                      ..loadMessages(),
              ),
              BlocProvider(create: (_) => sl<LawyerCallCubit>()),
            ],
            child: LawyerChatScreen(
              chatRoomId: details.chatRoomId!,
              clientName: details.client.name,
              caseTitle: details.title,
              isCall: _isCallType(serviceType),
              isVideo: _isVideoType(serviceType),
            ),
          ),
        ),
      );
    }
  }

  void _showAddSessionSheet(
    BuildContext context,
    LawyerCasesCubit cubit,
    int caseId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSessionSheet(
        caseId: caseId,
        onConfirm: (title, date, details) {
          cubit.addCaseSession(
            caseId: caseId,
            title: title,
            date: date,
            details: details,
          );
        },
      ),
    );
  }

  void _showUploadDocumentSheet(
    BuildContext context,
    LawyerCasesCubit cubit,
    int caseId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadDocumentSheet(
        caseId: caseId,
        onConfirm: (title, document) {
          cubit.uploadCaseDocument(
            caseId: caseId,
            title: title,
            document: document,
          );
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  IconData _serviceIcon(String type) {
    final normalized = type.toLowerCase();
    if (_isVideoType(normalized)) {
      return Icons.videocam_outlined;
    }
    if (_isCallType(normalized)) {
      return Icons.phone_outlined;
    }
    if (normalized.contains('chat') || normalized == 'normal') {
      return Icons.chat_outlined;
    }
    return Icons.article_outlined;
  }

  Color _serviceColor(String type) {
    final normalized = type.toLowerCase();
    if (_isVideoType(normalized)) {
      return const Color(0xFF9B59B6);
    }
    if (_isCallType(normalized)) {
      return const Color(0xFF27AE60);
    }
    return AppColors.golden;
  }

  bool _shouldShowServiceType(String type, String typeText) {
    final normalizedType = type.trim().toLowerCase();
    final normalizedText = typeText.trim().toLowerCase();
    final label = normalizedText.isNotEmpty ? normalizedText : normalizedType;
    return label.isNotEmpty && label != 'normal';
  }

  bool _isVideoType(String type) => type.toLowerCase().contains('video');

  bool _isCallType(String type) {
    final normalized = type.toLowerCase();
    return _isVideoType(normalized) ||
        normalized.contains('audio') ||
        normalized.contains('phone') ||
        normalized.contains('call');
  }
}
