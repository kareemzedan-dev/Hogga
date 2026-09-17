import 'package:flutter/material.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_confirmation_sheet.dart';

Future<void> showLogoutConfirmationSheet(
  BuildContext context, {
  String destinationRoute = AppRoutes.login,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => CustomConfirmationSheet(
      iconData: Icons.logout_rounded,
      iconPath: AppAssets.logoutLogo,
      title: AppStrings.logoutTitle.tr(sheetContext),
      subtitle: AppStrings.logoutSubtitle.tr(sheetContext),
      actionText: AppStrings.logout.tr(sheetContext),
      actionColor: const Color(0xFFE65100), // Warm warning amber/orange-red
      iconColor: const Color(0xFFE65100),
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

Future<void> showDeleteAccountConfirmationSheet(
  BuildContext context, {
  String destinationRoute = AppRoutes.login,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => CustomConfirmationSheet(
      iconData: Icons.delete_forever_rounded,
      title: AppStrings.deleteAccountTitle.tr(sheetContext),
      subtitle: AppStrings.deleteAccountSubtitle.tr(sheetContext),
      warningNote: AppLocalizations.of(sheetContext)?.locale.languageCode == 'ar'
          ? 'تنبيه: سيتم مسح حسابك وكافة السجلات والمحادثات نهائياً، ولا يمكن التراجع عن هذا الإجراء.'
          : 'Warning: All your account data and records will be permanently deleted and cannot be undone.',
      actionText: AppStrings.deleteAccountAction.tr(sheetContext),
      actionColor: const Color(0xFFD32F2F), // Deep destructive red
      iconColor: const Color(0xFFD32F2F),
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
