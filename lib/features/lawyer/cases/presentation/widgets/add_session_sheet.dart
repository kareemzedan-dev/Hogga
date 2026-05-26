import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_strings.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class AddSessionSheet extends StatefulWidget {
  final int caseId;
  final Function(String title, String date, String details) onConfirm;

  const AddSessionSheet({super.key, required this.caseId, required this.onConfirm});

  @override
  State<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<AddSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.pleaseSelectSessionDate.tr(context))),
        );
        return;
      }
      widget.onConfirm(
        _titleController.text,
        DateFormat('yyyy-MM-dd').format(_selectedDate!),
        _detailsController.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.pageBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.addCaseUpdate.tr(context),
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                hintText: AppStrings.sessionTitleHint.tr(context),
                controller: _titleController,
                validator: (value) => value == null || value.isEmpty ? AppStrings.requiredField.tr(context) : null,
              ),
              SizedBox(height: 16.h),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: context.divColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 20.sp, color: context.accentGolden),
                      SizedBox(width: 12.w),
                      Text(
                        _selectedDate == null ? AppStrings.sessionDateLabel.tr(context) : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: context.text.bodyMedium?.copyWith(
                          color: _selectedDate == null ? context.textSecondary : context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: AppStrings.sessionDetailsHint.tr(context),
                controller: _detailsController,
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? AppStrings.requiredField.tr(context) : null,
              ),
              SizedBox(height: 32.h),
              CustomButton(
                text: AppStrings.confirm.tr(context),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
