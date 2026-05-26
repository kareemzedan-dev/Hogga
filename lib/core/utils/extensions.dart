import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';

extension HoggaMirrorExtension on Widget {
  Widget mirror(BuildContext context) {
    if (Directionality.of(context) == TextDirection.rtl) {
      return Transform.flip(flipX: true, child: this);
    }
    return this;
  }
}

extension StatusLocalization on String {
  String toLocalizedStatus(BuildContext context) {
    final normalized = toLowerCase();
    if (normalized.contains('completed')) return AppStrings.completed.tr(context);
    if (normalized.contains('cancel')) return AppStrings.canceled.tr(context);
    if (normalized.contains('pending')) return AppStrings.pending.tr(context);
    if (normalized.contains('upcoming') || normalized.contains('confirm')) return AppStrings.confirmed.tr(context);
    if (normalized.contains('active')) return AppStrings.active.tr(context);
    if (normalized.contains('paused')) return AppStrings.paused.tr(context);
    if (normalized.contains('accepted')) return AppStrings.accepted.tr(context);
    if (normalized.contains('rejected') || normalized.contains('refused')) return AppStrings.rejected.tr(context);
    if (normalized.contains('in_progress') || normalized.contains('ongoing')) return AppStrings.inProgress.tr(context);
    return this;
  }
}
