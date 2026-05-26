import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/injection_container.dart' as di;
import 'package:hogga/features/user/more/presentation/privacy/manager/privacy_policy_cubit.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/features/user/more/data/models/privacy_policy_model.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PrivacyPolicyCubit>()..getPrivacyPolicy(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.privacyPolicy.tr(context),
          backBtn: true,
        ),
        body: BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
          builder: (context, state) {
            if (state is PrivacyPolicyLoading) {
              return ListView.separated(
                padding: EdgeInsets.all(20.w),
                itemCount: 4,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) => CustomShimmer.rectangular(
                  height: 120.h,
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
              );
            } else if (state is PrivacyPolicyError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<PrivacyPolicyCubit>().getPrivacyPolicy(),
                      child: Text(AppStrings.retry.tr(context)),
                    ),
                  ],
                ),
              );
            } else if (state is PrivacyPolicySuccess) {
              return _buildContent(context, state.privacyData);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<PrivacyData> privacyData) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: (context.isDark ? AppColors.golden : AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security_outlined,
                size: 60.sp,
                color: context.isDark ? AppColors.golden : AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          ...privacyData.map((data) => _buildSection(context, data.title, data.description)).toList(),
          SizedBox(height: 24.h),
          Center(
            child: Text(
              AppStrings.copyright.tr(context),
              style: context.text.bodySmall?.copyWith(
                color: context.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: context.isDark ? AppColors.golden : AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: context.text.titleMedium?.copyWith(
                      color: context.isDark ? AppColors.golden : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
          Text(
            content,
            style: context.text.bodyMedium?.copyWith(
              height: 1.6,
              color: context.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
