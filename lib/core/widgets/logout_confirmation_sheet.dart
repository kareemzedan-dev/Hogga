import 'package:flutter/material.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';

Future<void> showLogoutConfirmationSheet(
  BuildContext context, {
  String destinationRoute = AppRoutes.welcome,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => CustomConfirmationSheet(
      iconPath: AppAssets.logoutLogo,
      title: AppStrings.logoutTitle.tr(sheetContext),
      subtitle: AppStrings.logoutSubtitle.tr(sheetContext),
      actionText: AppStrings.logout.tr(sheetContext),
      onAction: () async {
        await AppPreferences().logout();
        if (sheetContext.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            sheetContext,
            destinationRoute,
            (route) => false,
          );
        }
      },
    ),
  );
}
