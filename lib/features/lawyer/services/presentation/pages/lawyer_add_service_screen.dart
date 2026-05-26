import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_category_item.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/add_service_cubit.dart';
import 'package:hogga/features/lawyer/services/presentation/cubit/lawyer_category_items_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/injection_container.dart';

class CategoryForm {
  final LawyerCategoryItem category;
  final TextEditingController nameController;
  final TextEditingController detailsController;
  final TextEditingController priceController;
  bool isSelected = false;
  bool isExpanded = false;

  CategoryForm(this.category)
      : nameController = TextEditingController(text: category.name),
        detailsController = TextEditingController(text: category.description),
        priceController = TextEditingController(text: category.suggestedPrice?.toString() ?? '');

  void dispose() {
    nameController.dispose();
    detailsController.dispose();
    priceController.dispose();
  }
}

class LawyerAddServiceScreen extends StatefulWidget {
  const LawyerAddServiceScreen({super.key});

  @override
  State<LawyerAddServiceScreen> createState() => _LawyerAddServiceScreenState();
}

class _LawyerAddServiceScreenState extends State<LawyerAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  List<CategoryForm> _forms = [];

  @override
  void dispose() {
    for (var form in _forms) {
      form.dispose();
    }
    super.dispose();
  }

  void _initForms(List<LawyerCategoryItem> items) {
    if (_forms.isEmpty) {
      _forms = items.map((item) => CategoryForm(item)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AddServiceCubit>()),
        BlocProvider(create: (context) => sl<LawyerCategoryItemsCubit>()..fetchCategoryItems()),
      ],
      child: BlocListener<AddServiceCubit, AddServiceState>(
        listener: (context, state) {
          if (state is AddServiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is AddServiceError) {
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
            title: Text(AppStrings.addService.tr(context), style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<LawyerCategoryItemsCubit, LawyerCategoryItemsState>(
            builder: (context, state) {
              if (state is LawyerCategoryItemsLoading) {
                return const LawyerShimmerLoading();
              } else if (state is LawyerCategoryItemsError) {
                return CustomErrorState(
                  message: state.message,
                  onRetry: () => context.read<LawyerCategoryItemsCubit>().fetchCategoryItems(),
                );
              } else if (state is LawyerCategoryItemsLoaded) {
                if (state.items.isEmpty) {
                  return CustomEmptyState(
                    title: AppStrings.noDataFound.tr(context),
                    subtitle: '',
                    icon: Icons.design_services_outlined,
                  );
                }

                _initForms(state.items);

                return Form(
                  key: _formKey,
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.w).copyWith(bottom: 100.h),
                    itemCount: _forms.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(context, _forms[index]);
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: _buildBottomBar(context),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryForm form) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: form.priceController,
      builder: (context, priceValue, child) {
        final bool hasPrice = priceValue.text.trim().isNotEmpty;
        final bool isCompleted = form.isSelected && hasPrice;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: isCompleted ? context.success.withValues(alpha: 0.05) : context.cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isCompleted
                  ? context.success
                  : (form.isSelected ? context.accentGolden : context.divColor),
              width: form.isSelected ? 2 : 1,
            ),
            boxShadow: form.isSelected
                ? [BoxShadow(color: isCompleted ? context.success.withValues(alpha: 0.1) : context.accentGolden.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (form.isSelected) {
                      form.isExpanded = !form.isExpanded;
                    } else {
                      form.isSelected = true;
                      form.isExpanded = true;
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: Checkbox(
                              value: form.isSelected,
                              activeColor: context.accentGolden,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                              onChanged: (value) {
                                setState(() {
                                  form.isSelected = value ?? false;
                                  form.isExpanded = form.isSelected;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  form.category.name,
                                  style: context.text.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: form.isSelected ? context.accentGolden : context.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  form.category.description,
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                if (!form.isExpanded && isCompleted) ...[
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: context.success, size: 16.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${priceValue.text} ${AppStrings.currency.tr(context)}',
                                        style: context.text.labelMedium?.copyWith(color: context.success, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ] else if (form.category.suggestedPrice != null) ...[
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: context.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '${AppStrings.price.tr(context)} الموصى به: ${form.category.suggestedPrice} ${AppStrings.currency.tr(context)}',
                                      style: context.text.labelSmall?.copyWith(color: context.success, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: form.isExpanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16.h),
                                  Divider(color: context.divColor),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.price.tr(context),
                                        style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: context.textSecondary),
                                      ),
                                      if (hasPrice)
                                        GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            setState(() => form.isExpanded = false);
                                          },
                                          child: Text(
                                            AppStrings.confirm.tr(context),
                                            style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: context.success),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildTextField(
                                    context,
                                    controller: form.priceController,
                                    hint: '0.00',
                                    keyboardType: TextInputType.number,
                                    suffixIcon: Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Text(AppStrings.currency.tr(context), style: context.text.labelMedium?.copyWith(color: context.accentGolden, fontWeight: FontWeight.bold)),
                                    ),
                                    validator: (v) => form.isSelected && v!.isEmpty ? AppStrings.requiredField.tr(context) : null,
                                  ),
                                ],
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: context.textSecondary),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      style: context.text.bodyMedium?.copyWith(
        color: readOnly ? context.textSecondary : context.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.text.bodyMedium?.copyWith(color: context.textSecondary.withValues(alpha: 0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.pageBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: context.divColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: context.divColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: context.accentGolden, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<LawyerCategoryItemsCubit, LawyerCategoryItemsState>(
      builder: (context, state) {
        if (state is LawyerCategoryItemsLoaded && state.items.isNotEmpty) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: context.cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BlocBuilder<AddServiceCubit, AddServiceState>(
              builder: (context, addState) {
                final selectedCount = _forms.where((f) => f.isSelected).length;
                return CustomButton(
                  text: selectedCount > 0 
                      ? '${AppStrings.addService.tr(context)} ($selectedCount)' 
                      : AppStrings.addService.tr(context),
                  isLoading: addState is AddServiceLoading,
                  onPressed: () {
                    final selectedForms = _forms.where((f) => f.isSelected).toList();
                    if (selectedForms.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.chooseServiceType.tr(context))),
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      final services = selectedForms.map((f) => {
                            'name': f.nameController.text,
                            'details': f.detailsController.text,
                            'price': double.tryParse(f.priceController.text) ?? 0.0,
                            'categories_item_id': f.category.id,
                          }).toList();

                      context.read<AddServiceCubit>().addMultipleServices(services);
                    }
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
