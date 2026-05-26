import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/main.dart';
import '../widgets/app_snakbar.dart';

class AppAlerts {
  /// Shows a success snackbar.
  static void success(BuildContext context, {String? message, String? messageKey}) {
    AppSnackbar.showSuccess(context, message: message, messageKey: messageKey);
  }

  /// Shows an error snackbar.
  static void error(BuildContext context, {String? message, String? messageKey}) {
    AppSnackbar.showError(context, message: message, messageKey: messageKey);
  }

  /// Shows a loading dialog that blocks user interaction.
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.golden),
      ),
    );
  }

  /// Hides the current loading dialog or any topmost overlay.
  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Shows a snackbar without context (useful for global background tasks).
  static void showGlobalSnackBar(String message, {bool isError = true}) {
    final state = MyApp.messengerKey.currentState;
    if (state == null) return;

    state.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
