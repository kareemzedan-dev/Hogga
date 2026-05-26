import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import '../../../cubit/lawyer_registration_cubit.dart';
import 'onboarding_step_scaffold.dart';
import 'onboarding_file_picker_card.dart';

class MetadataStep extends StatelessWidget {
  final LawyerRegistrationState state;
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> controllers;
  final Map<String, String> files;
  final Map<String, bool> loadingStates;
  final Function(String) onPickFile;
  final Function(String) onClearFile;
  final VoidCallback onContinue;

  const MetadataStep({
    super.key,
    required this.state,
    required this.formKey,
    required this.controllers,
    required this.files,
    required this.loadingStates,
    required this.onPickFile,
    required this.onClearFile,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final providerType = state.selectedProviderType;
    final fields = providerType?.fields ?? [];

    return OnboardingStepScaffold(
      title: AppStrings.additionalDataTitle.tr(context),
      subtitle: '',
      onContinue: onContinue,
      isBusy: state.isCompletingProfile,
      continueLabel: AppStrings.confirm.tr(context),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fields.map((field) {
            if (field.type == 'file') {
              return _buildFileField(context, field);
            }
            return _buildTextField(context, field);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFileField(BuildContext context, dynamic field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingFilePickerCard(
            title: AppStrings.uploadFile.tr(context, namedArgs: {'name': field.name}),
            subtitle: files[field.key]?.split('\\').last ?? AppStrings.chooseFileHint.tr(context),
            filePath: files[field.key],
            isLoading: loadingStates[field.key] ?? false,
            onTap: () => onPickFile(field.key),
            onClear: files[field.key] == null ? null : () => onClearFile(field.key),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, dynamic field) {
    if (!controllers.containsKey(field.key)) {
      controllers[field.key] = TextEditingController();
    }
    final controller = controllers[field.key]!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
            hintText: field.type == 'number'
                ? AppStrings.enterNumberHint.tr(context, namedArgs: {'name': field.name})
                : AppStrings.enterTextHint.tr(context, namedArgs: {'name': field.name}),
            controller: controller,
            keyboardType: field.type == 'number' ? TextInputType.number : TextInputType.text,
            validator: (value) {
              if (!field.isRequired) return null;
              if (value == null || value.trim().isEmpty) return AppStrings.requiredField.tr(context);
              return null;
            },
          ),
    );
  }
}
