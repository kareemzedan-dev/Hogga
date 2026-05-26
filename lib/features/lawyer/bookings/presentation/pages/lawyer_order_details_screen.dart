import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_booking.dart';
import 'package:hogga/features/lawyer/bookings/presentation/cubit/lawyer_bookings_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_status_badge.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/core/utils/extensions.dart';

class LawyerOrderDetailsScreen extends StatelessWidget {
  const LawyerOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = ModalRoute.of(context)?.settings.arguments as LawyerBooking?;

    return BlocProvider(
      create: (context) => sl<LawyerBookingsCubit>(),
      child: Builder(builder: (context) {
        return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: Text(AppStrings.orderDetail.tr(context), style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceInfo(context, booking),
              SizedBox(height: 24.h),
              _buildClientInfo(context, booking),
              SizedBox(height: 24.h),
              _buildTimingInfo(context, booking),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (booking != null) {
                      final success = await context.read<LawyerBookingsCubit>().acceptBooking(booking.id);
                      if (!context.mounted) return;
                      if (success) {
                        AppSnackbar.showSuccess(context, messageKey: AppStrings.acceptedSuccess);
                        Navigator.pop(context, true);
                      } else {
                        final state = context.read<LawyerBookingsCubit>().state;
                        if (state is LawyerBookingsLoaded && state.actionError != null && state.actionError!.isNotEmpty) {
                          AppSnackbar.showError(context, message: state.actionError);
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: context.text.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  child: Text(AppStrings.accept.tr(context)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    if (booking != null) {
                      final success = await context.read<LawyerBookingsCubit>().rejectBooking(booking.id);
                      if (!context.mounted) return;
                      if (success) {
                        AppSnackbar.showSuccess(context, messageKey: AppStrings.refusedSuccess);
                        Navigator.pop(context, true);
                      } else {
                        final state = context.read<LawyerBookingsCubit>().state;
                        if (state is LawyerBookingsLoaded && state.actionError != null && state.actionError!.isNotEmpty) {
                          AppSnackbar.showError(context, message: state.actionError);
                        }
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: context.colors.error,
                    side: BorderSide(color: context.colors.error),
                    textStyle: context.text.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  child: Text(AppStrings.refuse.tr(context)),
                ),
              ),
            ],
          ),
        ),
      ),
        );
      }),
    );
  }

  Widget _buildServiceInfo(BuildContext context, LawyerBooking? booking) {
    return LawyerCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.headset_mic_rounded, color: context.colors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking?.serviceName ?? AppStrings.legalConsultation.tr(context),
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                LawyerStatusBadge(text: booking?.status.toLocalizedStatus(context) ?? AppStrings.waitingForApproval.tr(context)),
              ],
            ),
          ),
          Text(
            AppStrings.priceWithCurrency.tr(
              context,
              namedArgs: {'price': booking?.price ?? '0'},
            ),
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(BuildContext context, LawyerBooking? booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LawyerSectionHeader(title: AppStrings.clientData.tr(context)),
        const SizedBox(height: 12),
        LawyerCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: context.accentGolden,
                child: const Icon(Icons.person, color: AppColors.cream),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking?.clientName ?? '-',
                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(AppStrings.newClient.tr(context), style: context.text.bodySmall?.copyWith(color: context.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingInfo(BuildContext context, LawyerBooking? booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LawyerSectionHeader(title: AppStrings.requestedAppointment.tr(context)),
        const SizedBox(height: 6),
        LawyerCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               Icon(Icons.calendar_month, color: context.accentGolden),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking?.date ?? '-',
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    booking?.time ?? '-',
                    style: context.text.bodySmall?.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
