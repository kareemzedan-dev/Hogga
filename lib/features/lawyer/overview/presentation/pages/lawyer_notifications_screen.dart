import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';

class LawyerNotificationsScreen extends StatelessWidget {
  const LawyerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: Text(AppStrings.notifications.tr(context), style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              AppStrings.clearAll.tr(context),
              style: context.text.labelMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) => _buildNotificationItem(context, index),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    final titles = [
      AppStrings.newLegalRequest.tr(context),
      AppStrings.sessionReminder.tr(context),
      AppStrings.caseUpdate.tr(context),
      AppStrings.newDocumentUploaded.tr(context),
      AppStrings.consultationBooking.tr(context)
    ];
    final contents = [
      AppStrings.notificationNewRequestDesc.tr(context),
      AppStrings.notificationSessionReminderDesc.tr(context),
      AppStrings.notificationCaseUpdateDesc.tr(context),
      AppStrings.notificationNewDocumentDesc.tr(context),
      AppStrings.notificationBookingDesc.tr(context)
    ];
    final icons = [
      Icons.assignment_turned_in_outlined,
      Icons.event_note_outlined,
      Icons.gavel_outlined,
      Icons.description_outlined,
      Icons.calendar_today_outlined
    ];

    return LawyerCard(
      padding: const EdgeInsets.all(16),
      color: index == 0 ? AppColors.golden.withValues(alpha: 0.05) : context.cardBg,
      showBorder: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (index == 0 ? context.accentGolden : context.colors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icons[index], color: index == 0 ? context.accentGolden : context.colors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titles[index],
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${AppStrings.since.tr(context)} ${index + 1} ${AppStrings.minutesLabel.tr(context)}',
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contents[index],
                  style: context.text.bodySmall?.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
