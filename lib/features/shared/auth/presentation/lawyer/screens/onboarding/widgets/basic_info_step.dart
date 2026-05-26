import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart' show AppPreferences;
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/features/user/bainah_services/presentation/widgets/city_picker_sheet.dart';
import '../../../cubit/lawyer_registration_cubit.dart';
import 'onboarding_step_scaffold.dart';
import 'onboarding_file_picker_card.dart';

class BasicInfoStep extends StatelessWidget {
  final LawyerRegistrationState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController civilIdController;
  final TextEditingController cityController;
  final TextEditingController experienceController;
  final String? personalImagePath;
  final bool isPersonalImageLoading;
  final String selectedLevel;
  final List<String> levels;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final Function(String) onLevelChanged;
  final Function(String) onPhoneChanged;
  final VoidCallback onContinue;

  const BasicInfoStep({
    super.key,
    required this.state,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.civilIdController,
    required this.cityController,
    required this.experienceController,
    required this.personalImagePath,
    required this.isPersonalImageLoading,
    required this.selectedLevel,
    required this.levels,
    required this.onPickImage,
    required this.onClearImage,
    required this.onLevelChanged,
    required this.onPhoneChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.personalDataTitle.tr(context),
      subtitle: AppStrings.personalDataSubtitle.tr(context),
      onContinue: onContinue,
      isBusy: state.isRegistering,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            OnboardingFilePickerCard(
              title: AppStrings.personalPhoto.tr(context),
              subtitle: personalImagePath == null
                  ? AppStrings.photoUploadDesc.tr(context)
                  : personalImagePath!.split('\\').last,
              filePath: personalImagePath,
              isLoading: isPersonalImageLoading,
              onTap: onPickImage,
              onClear: personalImagePath == null ? null : onClearImage,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: AppStrings.fullName.tr(context),
              controller: nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.nameRequired.tr(context);
                }
                if (value.trim().split(' ').length < 2) {
                  return AppStrings.validNameRequired.tr(context);
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              hintText: AppStrings.phone.tr(context),
              controller: phoneController,
              keyboardType: TextInputType.phone,
              onChanged: onPhoneChanged,
              validator: (value) => AppValidators.validatePhone(context, value),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              hintText: AppStrings.email.tr(context),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => AppValidators.validateEmail(context, value),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              hintText: AppStrings.password.tr(context),
              controller: passwordController,
              obscureText: true,
              validator: (value) => AppValidators.validatePassword(context, value),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              hintText: AppStrings.civilId.tr(context),
              controller: civilIdController,
              keyboardType: TextInputType.number,
              validator: (value) => AppValidators.validateCivilID(context, value),
            ),
            const SizedBox(height: 14),
            _buildCityPicker(context),
            const SizedBox(height: 14),
            _buildLevelDropdown(context),
            const SizedBox(height: 14),
            CustomTextField(
              hintText: AppStrings.yearsExperience.tr(context),
              controller: experienceController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.expRequired.tr(context);
                }
                if (int.tryParse(value.trim()) == null) {
                  return AppStrings.validExpRequired.tr(context);
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildLoginLink(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCityPicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final city = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const CityPickerSheet(),
        );
        if (city != null) {
          cityController.text = city.tr(context);
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          hintText: AppStrings.city.tr(context),
          controller: cityController,
          validator: (value) => AppValidators.validateRequired(context, value),
        ),
      ),
    );
  }

  Widget _buildLevelDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.divColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLevel,
          isExpanded: true,
          items: levels
              .map((level) => DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onLevelChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        onPressed: () {
          AppPreferences().clearDraft('draft_lawyer_registration');
          Navigator.pushNamed(context, AppRoutes.login, arguments: true);
        },
        child: Text(
          AppStrings.alreadyHaveAccountLogin.tr(context),
          style: context.text.labelSmall,
        ),
      ),
    );
  }
}
