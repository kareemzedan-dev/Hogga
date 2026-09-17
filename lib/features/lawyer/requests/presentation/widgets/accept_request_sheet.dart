import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import '../cubit/lawyer_requests_cubit.dart';

class AcceptRequestSheet extends StatefulWidget {
  final int requestId;
  final String requestTitle;

  const AcceptRequestSheet({
    super.key,
    required this.requestId,
    required this.requestTitle,
  });

  @override
  State<AcceptRequestSheet> createState() => _AcceptRequestSheetState();
}

class _AcceptRequestSheetState extends State<AcceptRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  String? _errorMessage;

  static const String _defaultDescription =
      'أهلاً بك، مستعد لدراسة كافة الأوراق والمستندات وتقديم الاستشارة القانونية الدقيقة لك';

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _descController = TextEditingController(text: _defaultDescription);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return;

    setState(() {
      _errorMessage = null;
    });

    context.read<LawyerRequestsCubit>().acceptRequest(
      requestId: widget.requestId,
      price: price,
      description: _descController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LawyerRequestsCubit, LawyerRequestsState>(
      listener: (context, state) {
        if (state is LawyerRequestActionSuccess) {
          Navigator.pop(context, true);
        } else if (state is LawyerRequestActionError) {
          setState(() {
            _errorMessage = state.message;
          });
          if (state.message.contains('لم يعد متاحاً') ||
              state.message.contains('ملغي') ||
              state.message.contains('not available')) {
            Navigator.pop(context, false);
          } else {
            AppSnackbar.showError(context, message: state.message);
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
          decoration: BoxDecoration(
            color: context.pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle indicator bar
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: context.divColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.acceptRequestTitle.tr(context),
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.requestTitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.textSecondary,
                      fontSize: 11.5.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20.h),

                  // Price Input
                  CustomTextField(
                    hintText: AppStrings.proposalPrice.tr(context),
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.w, top: 12.h),
                      child: Text(
                        AppStrings.currencySymbol.tr(context),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.accentGolden,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final price = double.tryParse(value?.trim() ?? '');
                      if (price == null || price <= 0) {
                        return AppStrings.requiredField.tr(context);
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 14.h),

                  // Description Input
                  CustomTextField(
                    hintText: AppStrings.description.tr(context),
                    controller: _descController,
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? AppStrings.requiredField.tr(context)
                        : null,
                  ),

                  SizedBox(height: 20.h),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: context.colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: context.colors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: context.colors.error,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.error,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  BlocBuilder<LawyerRequestsCubit, LawyerRequestsState>(
                    builder: (context, state) {
                      final isLoading = state is LawyerRequestActionLoading;
                      return CustomButton(
                        text: AppStrings.confirmAccept.tr(context),
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
