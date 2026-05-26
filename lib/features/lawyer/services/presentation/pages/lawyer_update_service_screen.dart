import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/update_service_cubit.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/injection_container.dart';

class LawyerUpdateServiceScreen extends StatefulWidget {
  final LawyerService service;

  const LawyerUpdateServiceScreen({super.key, required this.service});

  @override
  State<LawyerUpdateServiceScreen> createState() => _LawyerUpdateServiceScreenState();
}

class _LawyerUpdateServiceScreenState extends State<LawyerUpdateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.service.price);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UpdateServiceCubit>(),
      child: BlocListener<UpdateServiceCubit, UpdateServiceState>(
        listener: (context, state) {
          if (state is UpdateServiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // Refresh is now reactive
          } else if (state is UpdateServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: context.pageBg,
          appBar: AppBar(
            backgroundColor: context.pageBg,
            elevation: 0,
            shape: Border(bottom: BorderSide(color: context.divColor.withValues(alpha: 0.5), width: 1)),
            title: Text(
              AppStrings.editService.tr(context), 
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary)
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 18.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, AppStrings.serviceType.tr(context)),
                  SizedBox(height: 8.h),
                  _buildInfoBox(context, widget.service.categoriesItemName),
                  
                  SizedBox(height: 16.h),
                  _buildSectionTitle(context, AppStrings.serviceName.tr(context)),
                  SizedBox(height: 8.h),
                  _buildInfoBox(context, widget.service.name),
                  
                  SizedBox(height: 16.h),
                  _buildSectionTitle(context, AppStrings.serviceDescription.tr(context)),
                  SizedBox(height: 8.h),
                  _buildInfoBox(context, widget.service.description, minLines: 3),
                  
                  SizedBox(height: 24.h),
                  _buildSectionTitle(context, AppStrings.price.tr(context)),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    context,
                    controller: _priceController,
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Text(AppStrings.currency.tr(context), style: context.text.labelSmall?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold)),
                    ),
                    validator: (v) => v!.isEmpty ? AppStrings.requiredField.tr(context) : null,
                  ),
                  SizedBox(height: 40.h),
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: context.textSecondary),
    );
  }

  Widget _buildInfoBox(BuildContext context, String text, {int minLines = 1}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minLines * 24.h + 24.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.divColor),
      ),
      child: Text(
        text,
        style: context.text.bodySmall?.copyWith(color: context.textPrimary, height: 1.5),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary.withValues(alpha: 0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.cardBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: context.divColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: context.divColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: context.accentGolden, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<UpdateServiceCubit, UpdateServiceState>(
      builder: (context, state) {
        return CustomButton(
          text: AppStrings.saveChanges.tr(context),
          isLoading: state is UpdateServiceLoading,
          onPressed: () => _submit(context),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<UpdateServiceCubit>().updateService(
        id: widget.service.id,
        name: widget.service.name,
        details: widget.service.description,
        price: double.tryParse(_priceController.text) ?? 0.0,
        categoryId: widget.service.categoriesItemId,
      );
    }
  }
}
