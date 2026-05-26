import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';

class AddServiceSheet extends StatefulWidget {
  const AddServiceSheet({super.key});

  @override
  State<AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedServiceType;
  bool _isLoading = false;

  late List<String> _serviceTypes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _serviceTypes = [
      AppStrings.legalConsultation.tr(context),
      AppStrings.legalRepresentation.tr(context),
      AppStrings.contractWriting.tr(context),
      AppStrings.companyFormation.tr(context),
      AppStrings.other.tr(context),
    ];
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedServiceType == null) {
        AppSnackbar.showError(context, message: AppStrings.pleaseSelectServiceType.tr(context));
        return;
      }
      
      setState(() => _isLoading = true);
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          AppSnackbar.showSuccess(context, messageKey: AppStrings.serviceAddedSuccess);
          Navigator.pop(context);
        }
      });
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
                AppStrings.addService.tr(context),
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  hintText: AppStrings.serviceType.tr(context),
                  hintStyle: TextStyle(color: context.textSecondary),
                  filled: true,
                  fillColor: context.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: context.divColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: context.divColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: AppColors.golden),
                  ),
                ),
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedServiceType = value),
              ),
              
              SizedBox(height: 16.h),
              
              CustomTextField(
                hintText: AppStrings.price.tr(context),
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_rounded),
                validator: (value) => value == null || value.isEmpty ? AppStrings.requiredField.tr(context) : null,
              ),
              
              SizedBox(height: 16.h),
              
              CustomTextField(
                hintText: AppStrings.serviceDescription.tr(context),
                controller: _descController,
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? AppStrings.requiredField.tr(context) : null,
              ),
              
              SizedBox(height: 32.h),
              
              CustomButton(
                text: AppStrings.add,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
