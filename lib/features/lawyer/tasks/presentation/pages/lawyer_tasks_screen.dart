import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/tasks/presentation/cubit/lawyer_tasks_cubit.dart';
import 'package:intl/intl.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_empty_state.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_stat_box.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_section_header.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/features/lawyer/tasks/data/models/lawyer_task_model.dart';
import 'package:hogga/core/widgets/custom_text.dart';
import 'package:hogga/core/utils/app_colors.dart';
class LawyerTasksScreen extends StatelessWidget {
  const LawyerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LawyerTasksCubit>()..fetchTasks(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: AppBar(
              backgroundColor: context.pageBg,
              elevation: 0,
              shape: Border(bottom: BorderSide(color: context.divColor.withValues(alpha: 0.5), width: 1)),
              title: CustomText(AppStrings.myTasks.tr(context), isTitle: true, fontWeight: FontWeight.bold),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: context.accentGolden,
          elevation: 4,
          child: Icon(Icons.add_rounded, color: context.colors.onPrimary, size: 30.sp),
        ),
        body: BlocListener<LawyerTasksCubit, LawyerTasksState>(
          listener: (context, state) {
            if (state is LawyerTaskActionSuccess) {
              AppSnackbar.showSuccess(context, message: AppStrings.operationSuccess.tr(context));
            } else if (state is LawyerTasksError) {
              AppSnackbar.showError(context, message: state.message);
            } else if (state is LawyerTaskActionError) {
              AppSnackbar.showError(context, message: state.message);
            }
          },
          child: BlocBuilder<LawyerTasksCubit, LawyerTasksState>(
            buildWhen: (previous, current) => current is! LawyerTaskActionSuccess && current is! LawyerTaskActionError,
            builder: (context, state) {
            if (state is LawyerTasksLoading) {
              return const LawyerShimmerLoading();
            } else if (state is LawyerTasksError) {
              return Center(child: Text(state.message, style: context.text.bodyMedium?.copyWith(color: context.colors.error)));
            } else if (state is LawyerTasksLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<LawyerTasksCubit>().fetchTasks(),
                color: context.accentGolden,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildStatsRow(context, state.data.stats),
                      SizedBox(height: 24.h),
                      LawyerSectionHeader(title: AppStrings.myTasks.tr(context)),
                      SizedBox(height: 12.h),
                      if (state.data.tasks.isEmpty)
                        LawyerEmptyState(
                          title: AppStrings.noTasks.tr(context),
                          subtitle: AppStrings.noTasksSubtitle.tr(context),
                          icon: Icons.assignment_outlined,
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.data.tasks.length,
                          separatorBuilder: (context, index) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) => _buildTaskCard(context, state.data.tasks[index]),
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
  ),
);
}

  void _showDeleteConfirmation(BuildContext context, int taskId) {
    final cubit = context.read<LawyerTasksCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBg,
        title: CustomText(AppStrings.deleteTask.tr(context), fontSize: 16.sp, fontWeight: FontWeight.bold),
        content: CustomText(AppStrings.confirmDeleteTask.tr(context), fontSize: 14.sp),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: CustomText(AppStrings.cancel.tr(context), color: context.textSecondary, fontSize: 14.sp),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.deleteTask(taskId);
            },
            child: CustomText(AppStrings.delete.tr(context), color: context.colors.error, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final cubit = context.read<LawyerTasksCubit>();
    final titleController = TextEditingController();
    String priority = 'high';
    DateTime selectedDate = DateTime.now();
    bool isNotified = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          decoration: BoxDecoration(
            color: context.pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.divColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              CustomText(
                AppStrings.addTask.tr(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: titleController,
                style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: AppStrings.taskTitle.tr(context),
                  labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 14.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  filled: true,
                  fillColor: context.cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: context.divColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: context.divColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: context.accentGolden)),
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: priority,
                dropdownColor: context.cardBg,
                style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: AppStrings.selectPriority.tr(context),
                  labelStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary, fontSize: 14.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  filled: true,
                  fillColor: context.cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: context.divColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: context.divColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: context.accentGolden)),
                ),
                items: [
                  DropdownMenuItem(value: 'high', child: CustomText(AppStrings.high.tr(context), fontSize: 14.sp)),
                  DropdownMenuItem(value: 'medium', child: CustomText(AppStrings.medium.tr(context), fontSize: 14.sp)),
                  DropdownMenuItem(value: 'low', child: CustomText(AppStrings.low.tr(context), fontSize: 14.sp)),
                ],
                onChanged: (val) => setState(() => priority = val!),
              ),
              SizedBox(height: 16.h),
              InkWell(
                onTap: () async {
                  final dialogBuilder = (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: const TextTheme(),
                      ),
                      child: child!,
                    );
                  };

                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: dialogBuilder,
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                      initialEntryMode: TimePickerEntryMode.input,
                      builder: dialogBuilder,
                    );
                    if (time != null) {
                      setState(() {
                        selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.divColor),
                    borderRadius: BorderRadius.circular(12.r),
                    color: context.cardBg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(DateFormat('yyyy-MM-dd HH:mm').format(selectedDate), fontSize: 14.sp),
                      Icon(Icons.calendar_today, size: 18.sp, color: context.accentGolden),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Checkbox(
                    value: isNotified,
                    activeColor: context.accentGolden,
                    onChanged: (val) => setState(() => isNotified = val!),
                  ),
                  CustomText(AppStrings.notifications.tr(context), fontSize: 14.sp),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accentGolden,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      Navigator.pop(dialogContext);
                      context.read<LawyerTasksCubit>().addTask(
                        title: titleController.text,
                        priority: priority,
                        dueDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate),
                        isNotified: isNotified,
                      );
                    }
                  },
                  child: CustomText(AppStrings.addTask.tr(context), color: context.colors.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatsRow(BuildContext context, LawyerTaskStatsModel stats) {
    return Row(
      children: [
        Expanded(
          child: LawyerStatBox(
            label: AppStrings.total.tr(context),
            value: stats.total.toString(),
            icon: Icons.assignment_outlined,
            color: context.colors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: LawyerStatBox(
            label: AppStrings.completed.tr(context),
            value: stats.completed.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: LawyerStatBox(
            label: AppStrings.pending.tr(context),
            value: stats.pending.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, LawyerTaskModel task) {
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = context.colors.error;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return LawyerCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: task.status == 'completed',
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              onChanged: (val) {
                context.read<LawyerTasksCubit>().updateTaskStatus(
                  task.id,
                  val! ? 'completed' : 'pending',
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        task.priorityAr,
                        style: context.text.labelSmall?.copyWith(color: priorityColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (task.isNotified)
                      Icon(Icons.notifications_active_outlined, size: 18.sp, color: context.accentGolden),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(context, task.id),
                      icon: Icon(Icons.delete_outline, size: 18.sp, color: context.colors.error),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  task.title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
                    color: task.status == 'completed' ? context.textSecondary : context.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14.sp, color: context.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      task.dueDate,
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
