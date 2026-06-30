import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

import '../../../../../../../core/widgets/custom_button.dart';
import '../../../../../../../core/widgets/custom_container.dart';
import '../../../../../../../core/widgets/custom_text_field.dart';
import 'booking_components.dart';

class BookingFlowAdminCore extends StatefulWidget {
  final String categoryTitle;
  final String categoryDesc;
  final List<dynamic> items;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final VoidCallback onNext;
  final bool isValid;
  final int? duration;
  final bool isCallType;

  const BookingFlowAdminCore({
    super.key,
    required this.categoryTitle,
    required this.categoryDesc,
    required this.items,
    required this.titleController,
    required this.detailsController,
    required this.onNext,
    required this.isValid,
    this.duration,
    this.isCallType = false,
  });

  @override
  State<BookingFlowAdminCore> createState() => _BookingFlowAdminCoreState();
}

class _BookingFlowAdminCoreState extends State<BookingFlowAdminCore> {
  int _selectedGender = 0; // 0: All, 1: Male, 2: Female

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.categoryTitle, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSizes.h(4),
                Text(widget.categoryDesc, style: context.text.bodySmall?.copyWith(color: context.textSecondary)),
                if (widget.isCallType && widget.duration != null) ...[
                  AppSizes.h(12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF27AE60)),
                        AppSizes.w(6),
                        Text(
                          '${widget.duration} ${AppStrings.minutesLabel.tr(context)}',
                          style: context.text.labelMedium?.copyWith(
                            color: const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Divider(color: AppColors.golden.withValues(alpha: 0.2), thickness: 1, height: 32),
                if (widget.items.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _buildOrderType(widget.items, index),
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemCount: widget.items.length,
                  ),
                AppSizes.h(20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.all.tr(context),
                        isOutlined: _selectedGender != 0,
                        onPressed: () => setState(() => _selectedGender = 0),
                        isSmall: true,
                      ),
                    ),
                    AppSizes.w(8),
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.maleLawyer.tr(context),
                        isOutlined: _selectedGender != 1,
                        onPressed: () => setState(() => _selectedGender = 1),
                        isSmall: true,
                      ),
                    ),
                    AppSizes.w(8),
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.femaleLawyer.tr(context),
                        isOutlined: _selectedGender != 2,
                        onPressed: () => setState(() => _selectedGender = 2),
                        isSmall: true,
                      ),
                    ),
                  ],
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.requestTitle.tr(context)),
                AppSizes.h(8),
                CustomTextField(
                  controller: widget.titleController,
                  hintText: '* ${AppStrings.requestTitleHint.tr(context)}',
                  onChanged: (_) => setState(() {}),
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.requestDetails.tr(context)),
                AppSizes.h(8),
                CustomTextField(
                  controller: widget.detailsController,
                  hintText: '* ${AppStrings.requestDetailsHint.tr(context)}',
                  maxLines: 6,
                  onChanged: (_) => setState(() {}),
                ),
                AppSizes.h(20),
              ],
            ),
          ),
        ),
        BookingBottomButton(
          label: AppStrings.nextStep.tr(context),
          onPressed: widget.isValid ? widget.onNext : null,
        ),
      ],
    );
  }

  Widget _buildOrderType(List<dynamic> items, int index) {
    return CustomContainer(
      backgroundColor: context.cardBg,
      child: Row(
        children: [
          const Icon(CupertinoIcons.clock),
          SizedBox(width: 6.w),
          Text(items[index].time ?? '', style: context.text.bodyMedium),
          const Spacer(),
          Text(items[index].price?.toString() ?? '', style: context.text.bodyMedium),
          SizedBox(width: 6.w),
          Text(AppStrings.currency.tr(context), style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

class BookingFlowProviderCore extends StatefulWidget {
  final String categoryTitle;
  final String categoryDesc;
  final List<dynamic> items;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final VoidCallback onNext;
  final bool isValid;
  final int? duration;
  final bool isCallType;

  const BookingFlowProviderCore({
    super.key,
    required this.categoryTitle,
    required this.categoryDesc,
    required this.items,
    required this.titleController,
    required this.detailsController,
    required this.onNext,
    required this.isValid,
    this.duration,
    this.isCallType = false,
  });

  @override
  State<BookingFlowProviderCore> createState() => _BookingFlowProviderCoreState();
}

class _BookingFlowProviderCoreState extends State<BookingFlowProviderCore> {
  int _selectedGender = 0; // 0: All, 1: Male, 2: Female
  List<PlatformFile> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.categoryTitle, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSizes.h(4),
                Text(widget.categoryDesc, style: context.text.bodySmall?.copyWith(color: context.textSecondary)),
                if (widget.isCallType && widget.duration != null) ...[
                  AppSizes.h(12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF27AE60)),
                        AppSizes.w(6),
                        Text(
                          '${widget.duration} ${AppStrings.minutesLabel.tr(context)}',
                          style: context.text.labelMedium?.copyWith(
                            color: const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Divider(color: AppColors.golden.withValues(alpha: 0.2), thickness: 1, height: 32),
                if (widget.items.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _buildOrderType(widget.items, index),
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemCount: widget.items.length,
                  ),
                AppSizes.h(20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.all.tr(context),
                        isOutlined: _selectedGender != 0,
                        onPressed: () => setState(() => _selectedGender = 0),
                        isSmall: true,
                      ),
                    ),
                    AppSizes.w(8),
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.maleLawyer.tr(context),
                        isOutlined: _selectedGender != 1,
                        onPressed: () => setState(() => _selectedGender = 1),
                        isSmall: true,
                      ),
                    ),
                    AppSizes.w(8),
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.femaleLawyer.tr(context),
                        isOutlined: _selectedGender != 2,
                        onPressed: () => setState(() => _selectedGender = 2),
                        isSmall: true,
                      ),
                    ),
                  ],
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.requestTitle.tr(context)),
                AppSizes.h(8),
                CustomTextField(
                  controller: widget.titleController,
                  hintText: '* ${AppStrings.requestTitleHint.tr(context)}',
                  onChanged: (_) => setState(() {}),
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.requestDetails.tr(context)),
                AppSizes.h(8),
                CustomTextField(
                  controller: widget.detailsController,
                  hintText: '* ${AppStrings.requestDetailsHint.tr(context)}',
                  maxLines: 6,
                  onChanged: (_) => setState(() {}),
                ),
                AppSizes.h(20),
                BookingFieldLabel(AppStrings.uploadDocuments.tr(context)),
                AppSizes.h(8),
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
                    );
                    if (result != null) {
                      setState(() {
                        _selectedFiles.addAll(result.files);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.divColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.golden),
                        AppSizes.h(8),
                        Text(AppStrings.browseFiles.tr(context), style: context.text.bodyMedium, textAlign: TextAlign.center),
                        AppSizes.h(4),
                        Text(AppStrings.uploadDocumentsDesc.tr(context), style: context.text.bodySmall?.copyWith(color: context.textSecondary), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                if (_selectedFiles.isNotEmpty) ...[
                  AppSizes.h(12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: context.chipBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file, color: AppColors.golden, size: 20),
                            AppSizes.w(8),
                            Expanded(
                              child: Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedFiles.removeAt(index);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                AppSizes.h(20),
              ],
            ),
          ),
        ),
        BookingBottomButton(
          label: AppStrings.nextStep.tr(context),
          onPressed: widget.isValid ? widget.onNext : null,
        ),
      ],
    );
  }

  Widget _buildOrderType(List<dynamic> items, int index) {
    return CustomContainer(
      backgroundColor: context.cardBg,
      child: Row(
        children: [
          const Icon(CupertinoIcons.clock),
          SizedBox(width: 6.w),
          Text(items[index].time ?? '', style: context.text.bodyMedium),
          const Spacer(),
          Text(items[index].price?.toString() ?? '', style: context.text.bodyMedium),
          SizedBox(width: 6.w),
          Text(AppStrings.currency.tr(context), style: context.text.bodyMedium),
        ],
      ),
    );
  }
}
