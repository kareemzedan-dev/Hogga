import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/features/shared/auth/presentation/lawyer/cubit/lawyer_registration_cubit.dart';
import 'package:hogga/features/shared/auth/data/models/lawyer_registration_models.dart';
import 'onboarding_step_scaffold.dart';

class ProviderTypesStep extends StatelessWidget {
  final LawyerRegistrationState state;
  final VoidCallback onContinue;

  const ProviderTypesStep({
    super.key,
    required this.state,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.chooseAccountType.tr(context),
      subtitle: AppStrings.chooseAccountTypeSubtitle.tr(context),
      onContinue: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...state.providerTypes.map((providerType) {
            final isSelected = state.selectedProviderType?.id == providerType.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => context.read<LawyerRegistrationCubit>().selectProviderType(providerType),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.golden.withValues(alpha: 0.12) : context.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.golden : context.divColor,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.account_balance_outlined,
                        color: isSelected ? AppColors.golden : context.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          providerType.name,
                          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
