import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/theme/app_theme.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final bool Function(DateTime)? enabledDayPredicate;
  final List<dynamic> Function(DateTime)? eventLoader;
  final DateTime? firstDay;
  final DateTime? lastDay;

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.enabledDayPredicate,
    this.eventLoader,
    this.firstDay,
    this.lastDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'ar',
        firstDay: firstDay ?? DateTime.now(),
        lastDay: lastDay ?? DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        enabledDayPredicate: enabledDayPredicate,
        onDaySelected: onDaySelected,
        eventLoader: eventLoader,
        rowHeight: 40, // Balanced height
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 20),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
          headerPadding: const EdgeInsets.symmetric(vertical: 2),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: textTheme.bodySmall!.copyWith(color: AppColors.black, fontWeight: FontWeight.w400, fontSize: 10),
          weekendStyle: textTheme.bodySmall!.copyWith(color: AppColors.grey, fontWeight: FontWeight.w400, fontSize: 10),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          todayTextStyle: const TextStyle(color: AppColors.primary, fontSize: 13),
          selectedTextStyle: const TextStyle(color: AppColors.cream, fontSize: 13),
          defaultTextStyle: const TextStyle(fontSize: 13),
          weekendTextStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
          outsideDaysVisible: false,
          markerDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
        ),
      ),
    );
  }
}
