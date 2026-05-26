import 'package:flutter/material.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/overview/presentation/cubit/lawyer_overview_cubit.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_text.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/features/user/notifications/presentation/widgets/notification_badge.dart';
import 'package:hogga/features/user/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_booking.dart';

import '../widgets/availability_board.dart';
import '../widgets/performance_stats_grid.dart';
import '../widgets/next_appointment_card.dart';
import '../widgets/lawyer_toolbox.dart';

import 'package:hogga/features/lawyer/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:hogga/features/lawyer/subscription/presentation/cubit/subscription_state.dart';
import 'package:hogga/features/lawyer/subscription/presentation/widgets/subscription_status_card.dart';
import 'package:hogga/injection_container.dart';

class LawyerOverviewScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const LawyerOverviewScreen({super.key, this.onNavigate});

  @override
  State<LawyerOverviewScreen> createState() => _LawyerOverviewScreenState();
}

class _LawyerOverviewScreenState extends State<LawyerOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerOverviewCubit, LawyerOverviewState>(
      listenWhen: (previous, current) => current is LawyerOverviewLoaded && current.actionError != null,
      listener: (context, state) {
        if (state is LawyerOverviewLoaded && state.actionError != null) {
          AppSnackbar.showError(context, message: state.actionError!);
          context.read<LawyerOverviewCubit>().clearActionError();
        }
      },
      builder: (context, state) {
        if (state is LawyerOverviewLoading) {
          return const LawyerShimmerLoading();
        } else if (state is LawyerOverviewError) {
          return Center(child: Text(state.message.tr(context), style: context.text.bodyMedium?.copyWith(color: context.colors.error, fontSize: 14.sp)));
        } else if (state is LawyerOverviewLoaded) {
          final home = state.homeData;
          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.onNavigate?.call(4),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: context.mc.chipBg,
                      backgroundImage: home.lawyer.photo.isNotEmpty
                          ? CachedNetworkImageProvider(home.lawyer.photo) as ImageProvider
                          : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          AppStrings.welcome.tr(context),
                          isSecondary: true,
                          fontSize: 11,
                        ),
                        CustomText(
                          home.lawyer.name,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                NotificationBadge(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                    context.read<NotificationsCubit>().getNotifications();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(Icons.notifications_none_rounded, color: context.textPrimary, size: 24.sp),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => context.read<LawyerOverviewCubit>().getOverviewData(),
              color: context.accentGolden,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SubscriptionStatusCard(
                      //   summary: home.subscriptionSummary,
                      //   isLoading: false,
                      // ),
                      SizedBox(height: 16.h),
                      AvailabilityBoard(settings: home.settings),
                      SizedBox(height: 16.h),
                      NextAppointmentCard(next: home.upcomingAppointment),
                      SizedBox(height: 16.h),
                      PerformanceStatsGrid(overview: home.overview),
                      SizedBox(height: 16.h),
                      const LawyerToolbox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
