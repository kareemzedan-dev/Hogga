import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/injection_container.dart' as di;
import 'package:hogga/features/user/more/presentation/contact_us/manager/contact_us_cubit.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/features/user/more/data/models/contact_us_model.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ContactUsCubit>()..getContactInfo(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.contactUs.tr(context),
          backBtn: true,
        ),
        body: BlocBuilder<ContactUsCubit, ContactUsState>(
          builder: (context, state) {
            if (state is ContactUsLoading) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  children: [
                    CustomShimmer.circular(width: 140.w, height: 140.w),
                    SizedBox(height: 40.h),
                    CustomShimmer.rectangular(height: 80.h, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r))),
                    SizedBox(height: 20.h),
                    CustomShimmer.rectangular(height: 80.h, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r))),
                    SizedBox(height: 20.h),
                    CustomShimmer.rectangular(height: 80.h, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r))),
                  ],
                ),
              );
            } else if (state is ContactUsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<ContactUsCubit>().getContactInfo(),
                      child: Text(AppStrings.retry.tr(context)),
                    ),
                  ],
                ),
              );
            } else if (state is ContactUsSuccess) {
              final data = state.contactData;
              return _buildContent(context, data);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ContactData data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 40.h),
          _buildContactCard(
            context,
            AppStrings.phoneCall.tr(context),
            data.phone,
            Icons.phone_iphone_rounded,
            context.isDark ? AppColors.golden : AppColors.primary,
            () => _launchPhone(data.phone),
          ),
          SizedBox(height: 20.h),
          _buildContactCard(
            context,
            AppStrings.email.tr(context),
            data.email,
            Icons.alternate_email_rounded,
            const Color(0xFFE4405F),
            () => _launchEmail(data.email),
          ),
          SizedBox(height: 20.h),
          _buildContactCard(
            context,
            AppStrings.workingHours.tr(context),
            data.workingHours,
            Icons.watch_later_outlined,
            const Color(0xFF4CAF50),
            null,
          ),
          if (data.socialMedia.isNotEmpty) ...[
            SizedBox(height: 48.h),
            Text(
              AppStrings.followUsOnSocialMedia.tr(context),
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Wrap(
              spacing: 20.w,
              runSpacing: 20.h,
              alignment: WrapAlignment.center,
              children: data.socialMedia.entries.map((entry) {
                return _buildSocialIconFromKey(entry.key, entry.value);
              }).toList(),
            ),
          ],
          SizedBox(height: 60.h),
          Text(
            AppStrings.copyright.tr(context),
            style: context.text.bodySmall?.copyWith(
              color: context.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSocialIconFromKey(String key, String url) {
    IconData icon;
    Color color;

    switch (key.toLowerCase()) {
      case 'facebook':
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'instagram':
        icon = Icons.camera_alt;
        color = const Color(0xFFE4405F);
        break;
      case 'twitter':
      case 'x':
        icon = Icons.close;
        color = Colors.black;
        break;
      case 'tiktok':
        icon = Icons.music_note;
        color = Colors.black;
        break;
      case 'youtube':
        icon = Icons.play_arrow;
        color = const Color(0xFFFF0000);
        break;
      case 'linkedin':
        icon = Icons.business;
        color = const Color(0xFF0077B5);
        break;
      default:
        icon = Icons.language;
        color = AppColors.primary;
    }

    return _buildSocialIcon(icon, color, () => _launchUrl(url));
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (context.isDark ? AppColors.golden : AppColors.primary).withValues(alpha: 0.15),
                    (context.isDark ? AppColors.golden : AppColors.primary).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: context.cardBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.headset_mic_rounded,
                size: 50.sp,
                color: context.isDark ? AppColors.golden : AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Text(
          AppStrings.weAreHereToHelp.tr(context),
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            AppStrings.supportTeamReady.tr(context),
            style: context.text.bodyMedium?.copyWith(
              color: context.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context, 
    String title, 
    String content, 
    IconData icon, 
    Color accentColor,
    VoidCallback? onTap
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: accentColor, size: 24.sp),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        content,
                        style: context.text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded, 
                    size: 14.sp, 
                    color: context.textSecondary.withValues(alpha: 0.5)
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withValues(alpha: 0.1), width: 2),
          ),
          child: Icon(icon, color: color, size: 26.sp),
        ),
      ),
    );
  }
}
