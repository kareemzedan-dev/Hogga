import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/injection_container.dart' as di;
import 'manager/instructions_cubit.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/features/user/more/data/models/instructions_model.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<InstructionsCubit>()..getInstructions(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.instructions.tr(context),
          backBtn: true,
        ),
        body: BlocBuilder<InstructionsCubit, InstructionsState>(
          builder: (context, state) {
            if (state is InstructionsLoading) {
              return ListView.separated(
                padding: EdgeInsets.all(20.w),
                itemCount: 6,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) => CustomShimmer.rectangular(
                  height: 70.h,
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              );
            } else if (state is InstructionsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<InstructionsCubit>().getInstructions(),
                      child: Text(AppStrings.retry.tr(context)),
                    ),
                  ],
                ),
              );
            } else if (state is InstructionsSuccess) {
              return _buildList(context, state.instructions);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<InstructionData> instructions) {
    if (instructions.isEmpty) {
      return Center(child: Text(AppStrings.noRouteFound.tr(context)));
    }
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: instructions.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = instructions[index];
        return Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: (context.isDark ? AppColors.golden : AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: context.isDark ? AppColors.golden : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              title: Text(
                item.title,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              iconColor: context.isDark ? AppColors.golden : AppColors.primary,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: Text(
                    item.description,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
