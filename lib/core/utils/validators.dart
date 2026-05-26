import 'package:flutter/material.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class AppValidators {
  static String? validatePhone(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    final cleanValue = value.trim().replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^[279]\d{7}$');
    if (!phoneRegex.hasMatch(cleanValue)) {
      return AppStrings.invalidPhone.tr(context);
    }
    return null;
  }

  static String? validateEmail(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail.tr(context);
    }
    return null;
  }

  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    if (value.length < 8) {
      return AppStrings.passwordTooShort.tr(context);
    }
    return null;
  }

  static String? validateConfirmPassword(BuildContext context, String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    if (value != password) {
      return AppStrings.passwordMismatch.tr(context);
    }
    return null;
  }

  static String? validateRequired(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    return null;
  }

  static String? validateCivilID(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    final idRegex = RegExp(r'^\d{8}$');
    if (!idRegex.hasMatch(value)) {
      return AppStrings.invalidCivilID.tr(context);
    }
    return null;
  }

  static String? validateLawyerLicense(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr(context);
    }
    final licenseRegex = RegExp(r'^\d{3,10}$');
    if (!licenseRegex.hasMatch(value)) {
      return AppStrings.invalidLawyerLicense.tr(context);
    }
    return null;
  }
}
