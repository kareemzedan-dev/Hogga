import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';
import 'package:hogga/injection_container.dart';
import '../../../../../core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_assets.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  dynamic _extractUser(ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileUpdating) return state.user;
    if (state is ProfileUpdateSuccess) return state.user;
    if (state is ProfileAvatarUpdating) return state.user;
    if (state is ProfileAvatarUpdateSuccess) return state.user;
    if (state is ProfilePasswordUpdating) return state.user;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppStrings.profile.tr(context),
            style: context.theme.appBarTheme.titleTextStyle,
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              AppSnackbar.showError(context, message: state.message);
            } else if (state is ProfileUpdateSuccess) {
              AppSnackbar.showSuccess(context, messageKey: AppStrings.profileUpdatedSuccessfully);
            } else if (state is ProfileAvatarUpdateSuccess) {
              AppSnackbar.showSuccess(context, messageKey: AppStrings.profileUpdatedSuccessfully);
            } else if (state is ProfilePasswordUpdateSuccess) {
              AppSnackbar.showSuccess(context, message: state.message);
              Navigator.pop(context); // Close the bottom sheet
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return _buildShimmer(context);
            }

            if (state is ProfileLoaded ||
                state is ProfileAvatarUpdating ||
                state is ProfileUpdating ||
                state is ProfilePasswordUpdating ||
                state is ProfilePasswordUpdateSuccess ||
                state is ProfileUpdateSuccess ||
                state is ProfileAvatarUpdateSuccess) {
              final user = _extractUser(state);
              if (user == null) {
                return const SizedBox();
              }
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  children: [
                    _buildHeader(context, state),
                    SizedBox(height: 32.h),
                    _buildSection(
                      context,
                      title: AppStrings.personalInfo.tr(context),
                      items: [
                        _ProfileItem(
                          icon: Icons.person_outline,
                          label: AppStrings.fullName.tr(context),
                          value: user.name,
                          onEdit: () => _showEditPersonalData(context, user),
                        ),
                        _ProfileItem(
                          icon: Icons.email_outlined,
                          label: AppStrings.email.tr(context),
                          value: user.email,
                          onEdit: () => _showEditPersonalData(context, user),
                        ),
                        _ProfileItem(
                          icon: Icons.wc_outlined,
                          label: AppStrings.genderTitle.tr(context),
                          value: user.gender == 'male' ? AppStrings.male.tr(context) : (user.gender == 'female' ? AppStrings.female.tr(context) : '-'),
                          onEdit: () => _showEditPersonalData(context, user),
                        ),
                        _ProfileItem(
                          icon: Icons.badge_outlined,
                          label: AppStrings.accountTierTitle.tr(context),
                          value: user.accountType == 'Institution' ? AppStrings.institution.tr(context) : (user.accountType == 'Personal' ? AppStrings.individual.tr(context) : (user.accountType ?? '-')),
                          onEdit: () => _showEditPersonalData(context, user),
                        ),
                        _ProfileItem(
                          icon: Icons.phone_android_outlined,
                          label: AppStrings.mobileNumber.tr(context),
                          value: user.phone,
                          isReadOnly: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      context,
                      title: AppStrings.securitySettings.tr(context),
                      items: [
                        _ProfileItem(
                          icon: Icons.lock_outline,
                          label: AppStrings.password.tr(context),
                          value: "********",
                          onEdit: () => _showChangePassword(context),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          const CustomShimmer.circular(width: 110, height: 110),
          SizedBox(height: 16.h),
          CustomShimmer.rectangular(height: 24.h, width: 150.w),
          SizedBox(height: 8.h),
          CustomShimmer.rectangular(height: 16.h, width: 200.w),
          SizedBox(height: 32.h),
          ...List.generate(3, (index) => Column(
            children: [
              CustomShimmer.rectangular(height: 100.h),
              SizedBox(height: 24.h),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileState state) {
    final user = _extractUser(state);
    if (user == null) {
      return const SizedBox();
    }
    final isUpdating = state is ProfileAvatarUpdating;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.1),
            context.colors.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.golden.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.golden, width: 2),
                    image: DecorationImage(
                      image: user.image != null && user.image!.isNotEmpty
                          ? CachedNetworkImageProvider(user.image!) as ImageProvider
                          : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.golden.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: isUpdating
                      ? Container(
                          decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => context.read<ProfileCubit>().updateAvatar(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.golden,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.pageBg, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            user.name,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            user.email,
            style: context.text.bodyMedium?.copyWith(
              color: context.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.w, bottom: 12.h),
          child: Text(
            title,
            style: context.text.titleSmall?.copyWith(color: context.colors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        HoggaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (idx < items.length - 1) Divider(height: 1, indent: 50.w),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showEditPersonalData(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String? selectedGender = user.gender;
    String? selectedAccountType = user.accountType;
    final profileCubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: context.pageBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: context.divColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                Text(
                  AppStrings.editProfile.tr(context),
                  style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                CustomTextField(
                  hintText: AppStrings.fullName.tr(context),
                  controller: nameController,
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  hintText: AppStrings.email.tr(context),
                  controller: emailController,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                _buildDropdownField(
                  context,
                  hint: AppStrings.genderTitle.tr(context),
                  value: ['male', 'female'].contains(selectedGender) ? selectedGender : null,
                  icon: Icons.wc_rounded,
                  items: [
                    DropdownMenuItem(value: 'male', child: Text(AppStrings.male.tr(context))),
                    DropdownMenuItem(value: 'female', child: Text(AppStrings.female.tr(context))),
                  ],
                  onChanged: (val) => setState(() => selectedGender = val),
                ),
                SizedBox(height: 16.h),
                _buildDropdownField(
                  context,
                  hint: AppStrings.accountTierTitle.tr(context),
                  value: ['Personal', 'Institution'].contains(selectedAccountType) ? selectedAccountType : null,
                  icon: Icons.badge_rounded,
                  items: [
                    DropdownMenuItem(value: 'Personal', child: Text(AppStrings.individual.tr(context))),
                    DropdownMenuItem(value: 'Institution', child: Text(AppStrings.institution.tr(context))),
                  ],
                  onChanged: (val) => setState(() => selectedAccountType = val),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: AppStrings.saveChanges.tr(context),
                  onPressed: () {
                    profileCubit.updatePersonalData(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      gender: selectedGender,
                      accountType: selectedAccountType,
                    );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String hint,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.mc.inputFill,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.divColor, width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          dropdownColor: context.cardBg,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: context.textSecondary, size: 20.sp),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down_rounded, color: context.textSecondary),
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final profileCubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: context.pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.changePassword.tr(context),
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                hintText: AppStrings.currentPassword.tr(context),
                controller: currentPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: AppStrings.newPassword.tr(context),
                controller: newPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_reset_outlined),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: AppStrings.confirmNewPassword.tr(context),
                controller: confirmPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.check_circle_outline),
              ),
              SizedBox(height: 32.h),
              BlocBuilder<ProfileCubit, ProfileState>(
                bloc: profileCubit,
                builder: (context, state) {
                  return CustomButton(
                    text: AppStrings.saveChanges.tr(context),
                    isLoading: state is ProfilePasswordUpdating,
                    onPressed: () {
                      profileCubit.updatePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final bool isReadOnly;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isReadOnly ? null : onEdit,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.golden.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.golden, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value.isNotEmpty ? value : "-",
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
