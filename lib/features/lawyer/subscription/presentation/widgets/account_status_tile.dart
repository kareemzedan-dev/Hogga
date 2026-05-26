import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/utils/extensions.dart';

class AccountStatusTile extends StatelessWidget {
  const AccountStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerSubscription),
      leading: Icon(
        Icons.workspace_premium_rounded,
        color: context.accentGolden,
        size: 24.sp,
      ),
      title: Text(
        AppStrings.mySubscription.tr(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16.sp,
        color: context.textSecondary,
      ).mirror(context),
    );
  }
}
