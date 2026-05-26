import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/bookings/presentation/cubit/lawyer_bookings_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_empty_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_status_badge.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_booking.dart';
import 'package:hogga/injection_container.dart';
import 'package:intl/intl.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/utils/extensions.dart';
import 'package:hogga/core/widgets/custom_text.dart';

class LawyerBookingsScreen extends StatefulWidget {
  const LawyerBookingsScreen({super.key});

  @override
  State<LawyerBookingsScreen> createState() => _LawyerBookingsScreenState();
}

class _LawyerBookingsScreenState extends State<LawyerBookingsScreen> {
  String? _selectedFilter;
  late List<String> _filtersLabels;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filtersLabels = [
      AppStrings.all.tr(context),
      AppStrings.upcoming.tr(context),
      AppStrings.completed.tr(context),
      AppStrings.canceled.tr(context),
    ];
    _selectedFilter ??= _filtersLabels.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LawyerBookingsCubit>()..fetchBookings(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.bookings.tr(context),
            style: context.theme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<LawyerBookingsCubit, LawyerBookingsState>(
          listener: (context, state) {
            if (state is LawyerBookingsLoaded &&
                state.actionError != null &&
                state.actionError!.isNotEmpty) {
              AppSnackbar.showError(context, message: state.actionError);
            }
          },
          builder: (context, state) {
            if (state is LawyerBookingsLoading) {
              return const LawyerShimmerLoading();
            }
            if (state is LawyerBookingsError) {
              return Center(
                child: Text(
                  state.message.tr(context),
                  style: context.text.bodyMedium?.copyWith(color: context.colors.error),
                ),
              );
            }
            if (state is! LawyerBookingsLoaded) {
              return const SizedBox.shrink();
            }

            return RefreshIndicator(
              onRefresh: () => context.read<LawyerBookingsCubit>().fetchBookings(),
              color: context.accentGolden,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvailabilityToggle(context, state),
                    SizedBox(height: 24.h),
                    _buildFilterBar(context),
                    SizedBox(height: 24.h),
                    LawyerSectionHeader(
                      title: AppStrings.scheduleTable.tr(context),
                      actionLabel: AppStrings.manageSchedule.tr(context),
                      onActionPressed: () => _showComingSoon(context),
                    ),
                    SizedBox(height: 12.h),
                    state.bookings.isEmpty
                        ? LawyerEmptyState(
                            title: AppStrings.noBookings.tr(context),
                            subtitle: AppStrings.noBookingsSubtitle.tr(context),
                            icon: Icons.calendar_today_outlined,
                          )
                        : _buildBookingsList(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filtersLabels.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedFilter = filter),
              selectedColor: context.accentGolden,
              labelStyle: context.text.labelSmall?.copyWith(
                color: isSelected ? context.colors.onPrimary : context.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isSelected ? context.accentGolden : context.divColor,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailabilityToggle(BuildContext context, LawyerBookingsLoaded state) {
    final isActive = state.homeData.settings.isActive;
    return HoggaCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isActive ? Colors.green : context.colors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.check_circle_outline : Icons.do_not_disturb_on_outlined,
              color: isActive ? Colors.green : context.colors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive
                      ? AppStrings.availableForConsultations.tr(context)
                      : AppStrings.currentlyPaused.tr(context),
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  isActive
                      ? AppStrings.profileVisibleNotice.tr(context)
                      : AppStrings.profileHiddenNotice.tr(context),
                  style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) => context.read<LawyerBookingsCubit>().toggleOnlineStatus(value),
            activeColor: context.accentGolden,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, LawyerBookingsLoaded state) {
    final filteredBookings = _selectedFilter == AppStrings.all.tr(context)
        ? state.bookings
        : state.bookings.where((booking) => _matchesFilter(context, booking)).toList();

    if (filteredBookings.isEmpty) {
      return LawyerEmptyState(
        title: AppStrings.noResults.tr(context),
        subtitle: AppStrings.noResultsSubtitle.tr(context),
        icon: Icons.search_off_rounded,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredBookings.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.divColor),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      color: context.pageBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _bookingDay(booking),
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                        Text(
                          _bookingMonth(context, booking),
                          style: context.text.labelSmall?.copyWith(fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName,
                          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${booking.time} - ${booking.clientName}',
                          style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                        ),
                        if (booking.price.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            booking.price,
                            style: context.text.labelSmall?.copyWith(
                              color: context.accentGolden,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  LawyerStatusBadge(text: booking.status.toLocalizedStatus(context)),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: AppStrings.startSession.tr(context),
                      isSmall: true,
                      isOutlined: true,
                      onPressed: () => _showComingSoon(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      text: AppStrings.cancelBooking.tr(context),
                      isSmall: true,
                      backgroundColor: context.colors.error,
                      onPressed: () => _showComingSoon(context),
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

  bool _matchesFilter(BuildContext context, LawyerBooking booking) {
    final filter = _selectedFilter;
    if (filter == null || filter == AppStrings.all.tr(context)) {
      return true;
    }

    final status = booking.status.toLowerCase();
    if (filter == AppStrings.upcoming.tr(context)) {
      return status.contains('upcoming') ||
          status.contains('pending') ||
          status.contains('confirmed');
    }
    if (filter == AppStrings.completed.tr(context)) {
      return status.contains('completed');
    }
    if (filter == AppStrings.canceled.tr(context)) {
      return status.contains('cancel');
    }
    return false;
  }


  String _bookingDay(LawyerBooking booking) {
    final parsed = DateTime.tryParse(booking.date);
    return parsed != null ? parsed.day.toString() : '--';
  }

  String _bookingMonth(BuildContext context, LawyerBooking booking) {
    final parsed = DateTime.tryParse(booking.date);
    if (parsed == null) {
      return '';
    }
    return DateFormat(
      'MMM',
      Localizations.localeOf(context).languageCode,
    ).format(parsed);
  }

  void _showComingSoon(BuildContext context) {
    AppSnackbar.showSuccess(
      context,
      messageKey: AppStrings.comingSoon,
    );
  }
}
