import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/features/shared/auth/presentation/lawyer/cubit/lawyer_registration_cubit.dart';
import 'package:hogga/features/shared/auth/data/models/lawyer_registration_models.dart';
import 'onboarding_step_scaffold.dart';

class SpecializationsStep extends StatelessWidget {
  final LawyerRegistrationState state;
  final VoidCallback onContinue;

  const SpecializationsStep({
    super.key,
    required this.state,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.chooseSpecialization.tr(context),
      subtitle: AppStrings.chooseSpecsSubtitle.tr(context),
      onContinue: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.selectedSpecializationIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                AppStrings.specsSelectedCount.tr(context, namedArgs: {'count': state.selectedSpecializationIds.length.toString()}),
                style: context.text.bodySmall?.copyWith(color: AppColors.golden),
              ),
            ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: state.specializations.map((item) {
              final isSelected = state.selectedSpecializationIds.contains(item.id);
              return FilterChip(
                label: Text(
                  item.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.golden : context.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => context.read<LawyerRegistrationCubit>().toggleSpecialization(item.id),
                selectedColor: AppColors.golden.withValues(alpha: 0.12),
                checkmarkColor: AppColors.golden,
                side: BorderSide(color: isSelected ? AppColors.golden : context.divColor),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
