import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/features/shared/auth/presentation/shared/widgets/auth_text_field.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/validators.dart';
import 'package:hogga/core/widgets/custom_back_button.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String phone;
  const CreatePasswordScreen({super.key, required this.phone});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CustomBackButton(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppStrings.passwordStepTitle.tr(context),
                style: context.text.headlineSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Password Fields
              AuthTextField(
                controller: _passwordController,
                hint: AppStrings.password.tr(context),
                prefixIcon: Icon(Icons.lock_outline, color: context.colors.primary, size: 20),
                obscureText: !_isPasswordVisible,
                validator: (v) => AppValidators.validatePassword(context, v),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: context.colors.primary, size: 20),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmController,
                hint: AppStrings.confirmPassword.tr(context),
                prefixIcon: Icon(Icons.lock_outline, color: context.colors.primary, size: 20),
                obscureText: !_isConfirmVisible,
                validator: (v) => AppValidators.validateConfirmPassword(context, v, _passwordController.text),
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmVisible ? Icons.visibility : Icons.visibility_off, color: context.colors.primary, size: 20),
                  onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: RichText(
                        text:  TextSpan(
                          children: [
                            TextSpan(
                              text: AppStrings.areYouLawyer.tr(context),
                              style: context.text.bodyMedium?.copyWith(color: context.textSecondary),
                            ),
                            TextSpan(
                              text: AppStrings.registerAsLawyer.tr(context),
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushNamed(
                              context, 
                              AppRoutes.registerDetails,
                              arguments: {
                                'phone': widget.phone,
                                'password': _passwordController.text,
                              },
                            );
                          }
                        },
                        child:  Text(AppStrings.next.tr(context)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
}
