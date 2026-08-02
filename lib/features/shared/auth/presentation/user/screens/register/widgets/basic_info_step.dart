import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String accountType;
  final bool agreedToTerms;
  final Function(String) onAccountTypeChanged;
  final VoidCallback onTermsToggled;

  const BasicInfoStep({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.accountType,
    required this.agreedToTerms,
    required this.onAccountTypeChanged,
    required this.onTermsToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          hint: AppStrings.fullNameHint.tr(context),
          controller: nameController,
          prefixIcon: Icon(
            Icons.person_outline,
            color: context.textPrimary,
            size: 20,
          ),
          validator: (v) => AppValidators.validateRequired(context, v),
        ),
        const SizedBox(height: 14),
        AuthTextField(
          hint: AppStrings.email.tr(context),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.mail_outline,
            color: context.textPrimary,
            size: 20,
          ),
          validator: (v) => AppValidators.validateEmail(context, v),
        ),
        const SizedBox(height: 20),

        // ── Account type selector ──────────────────────────────
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            AppStrings.accountTier.tr(context),
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [AppStrings.individual, AppStrings.corporate].map((
            typeKey,
          ) {
            final type = typeKey.tr(context);
            final selected = accountType == typeKey;
            return Expanded(
              child: GestureDetector(
                onTap: () => onAccountTypeChanged(typeKey),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? context.textPrimary
                          : context.textSecondary.withValues(alpha: 0.4),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: selected
                          ? context.colors.primary
                          : context.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // ── Terms ────────────────────────────────────────────────
        GestureDetector(
          onTap: onTermsToggled,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: agreedToTerms
                      ? context.colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: agreedToTerms
                        ? context.colors.primary
                        : context.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
                child: agreedToTerms
                    ? Icon(
                        Icons.check,
                        color: context.colors.onPrimary,
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.iAgreeTo.tr(context),
                style: context.text.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Text(
                AppStrings.termsOfUseTitle.tr(context),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
