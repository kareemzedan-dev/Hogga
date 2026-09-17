import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/overview/presentation/cubit/lawyer_overview_cubit.dart';

class AvailabilityBoard extends StatelessWidget {
  final LawyerSettings settings;

  const AvailabilityBoard({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return LawyerCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(6.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: settings.isActive
                        ? context.success.withValues(alpha: 0.1)
                        : context.textSecondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: settings.isActive
                        ? context.success
                        : context.textSecondary,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.isActive
                            ? AppStrings.availableOnline.tr(context)
                            : AppStrings.busy.tr(context),
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: settings.isActive
                              ? context.success
                              : context.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        AppStrings.receptionSettings.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: settings.isActive,
                    onChanged: (v) => context
                        .read<LawyerOverviewCubit>()
                        .toggleOnlineStatus(v),
                    activeThumbColor: context.colors.onPrimary,
                    activeTrackColor: context.success,
                    inactiveThumbColor: context.colors.onPrimary,
                    inactiveTrackColor: context.textSecondary.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
