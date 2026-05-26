import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_strings.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import 'package:file_picker/file_picker.dart';

class UploadDocumentSheet extends StatefulWidget {
  final int caseId;
  final Function(String title, File document) onConfirm;

  const UploadDocumentSheet({super.key, required this.caseId, required this.onConfirm});

  @override
  State<UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<UploadDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.pleaseSelectFile.tr(context))),
        );
        return;
      }
      widget.onConfirm(_titleController.text, _selectedFile!);
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
                AppStrings.attachedDocuments.tr(context),
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                hintText: AppStrings.documentTitleHint.tr(context),
                controller: _titleController,
                validator: (value) => value == null || value.isEmpty ? AppStrings.requiredField.tr(context) : null,
              ),
              SizedBox(height: 16.h),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: context.divColor, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40.sp, color: context.accentGolden),
                      SizedBox(height: 12.h),
                      Text(
                        _selectedFile == null ? AppStrings.clickToSelectFile.tr(context) : _selectedFile!.path.split('/').last,
                        style: context.text.bodyMedium?.copyWith(
                          color: _selectedFile == null ? context.textSecondary : context.colors.primary,
                          fontWeight: _selectedFile == null ? FontWeight.normal : FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
