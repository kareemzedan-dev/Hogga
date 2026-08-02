import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_phone_country_prefix.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

class PhoneStep extends StatelessWidget {
  final TextEditingController phoneController;

  const PhoneStep({super.key, required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          hint: AppStrings.phoneStepTitle.tr(context),
          controller: phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const AuthPhoneCountryPrefix(),
          validator: (v) => AppValidators.validatePhone(context, v),
        ),
      ],
    );
  }
}
