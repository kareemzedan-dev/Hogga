import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

class PhoneStep extends StatelessWidget {
  final TextEditingController phoneController;

  const PhoneStep({
    super.key,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          hint: AppStrings.phoneStepTitle.tr(context),
          controller: phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Container(
            width: 85,
            margin: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.05),
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(14),
                bottomStart: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇴🇲', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '968+',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          validator: (v) => AppValidators.validatePhone(context, v),
        ),
      ],
    );
  }
}
