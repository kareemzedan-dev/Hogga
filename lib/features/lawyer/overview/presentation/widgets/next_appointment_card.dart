import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_booking.dart';

class NextAppointmentCard extends StatelessWidget {
  final LawyerBooking? next;

  const NextAppointmentCard({super.key, this.next});

  @override
  Widget build(BuildContext context) {
    if (next == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LawyerSectionHeader(
          title: AppStrings.nextAppointment.tr(context),
        ),
        LawyerCard(
          onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerOrderDetails, arguments: next),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: context.accentGolden.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        next!.time.split(':').first,
                        style: context.text.labelSmall?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(next!.serviceName, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text('${next!.clientName} • ${next!.time}', style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: context.colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      AppStrings.videoCall.tr(context),
                      style: context.text.labelSmall?.copyWith(color: context.colors.error, fontWeight: FontWeight.bold, fontSize: 10.sp),
                    ),
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
