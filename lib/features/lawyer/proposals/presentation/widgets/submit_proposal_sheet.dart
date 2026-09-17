import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';

class SubmitProposalSheet extends StatefulWidget {
  final int caseId;
  final String caseTitle;
  final int? proposalId;
  final String? initialDescription;
  final String? initialPrice;

  const SubmitProposalSheet({
    super.key,
    required this.caseId,
    required this.caseTitle,
    this.proposalId,
    this.initialDescription,
    this.initialPrice,
  });

  @override
  State<SubmitProposalSheet> createState() => _SubmitProposalSheetState();
}

class _SubmitProposalSheetState extends State<SubmitProposalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  final List<File> _selectedFiles = [];

  String get _draftKey => 'draft_proposal_${widget.caseId}';

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.initialDescription);
    _priceController = TextEditingController(text: widget.initialPrice);

    if (widget.proposalId == null) {
      _loadDraft();
      _descController.addListener(_saveDraft);
      _priceController.addListener(_saveDraft);
    }
  }

  void _loadDraft() {
    final draftJson = AppPreferences().getDraft(_draftKey);
    if (draftJson != null) {
      try {
        final data = jsonDecode(draftJson) as Map<String, dynamic>;
        if (widget.initialDescription == null) {
          _descController.text = data['description'] ?? '';
        }
        if (widget.initialPrice == null) {
          _priceController.text = data['price']?.toString() ?? '';
        }
      } catch (_) {}
    }
  }

  void _saveDraft() {
    if (widget.proposalId != null) return; // Don't save drafts for edits
    final data = {
      'description': _descController.text,
      'price': _priceController.text,
    };
    AppPreferences().saveDraft(_draftKey, jsonEncode(data));
  }

  @override
  void dispose() {
    if (widget.proposalId == null) {
      _descController.removeListener(_saveDraft);
      _priceController.removeListener(_saveDraft);
    }
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(
          result.paths.whereType<String>().map((path) => File(path)),
        );
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final offerPrice = double.parse(_priceController.text.trim());
      if (widget.proposalId != null) {
        context.read<LawyerProposalsCubit>().updateProposal(
          proposalId: widget.proposalId!,
          offerPrice: offerPrice,
          description: _descController.text,
        );
      } else {
        context.read<LawyerProposalsCubit>().submitProposal(
          serviceId: widget.caseId,
          offerPrice: offerPrice,
          description: _descController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LawyerProposalsCubit, LawyerProposalsState>(
      listener: (context, state) {
        if (state is LawyerProposalActionSuccess) {
          if (widget.proposalId == null) {
            AppPreferences().clearDraft(_draftKey);
          }
          Navigator.pop(context, true);
        } else if (state is LawyerProposalActionError) {
          if (state.message.contains('لم يعد متاحاً') ||
              state.message.contains('ملغي') ||
              state.message.contains('not available')) {
            Navigator.pop(context, false);
          } else {
            AppSnackbar.showError(context, message: state.message);
          }
        } else if (state is LawyerProposalsError) {
          AppSnackbar.showError(context, message: state.message);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: context.pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.proposalId != null
                        ? AppStrings.editProposal.tr(context)
                        : AppStrings.submitProposal.tr(context),
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.caseTitle,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  CustomTextField(
                    hintText: AppStrings.proposalPrice.tr(context),
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.payments_outlined),
                    validator: (value) {
                      final price = double.tryParse(value?.trim() ?? '');
                      if (price == null || price <= 0) {
                        return AppStrings.requiredField.tr(context);
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),
                  CustomTextField(
                    hintText: AppStrings.proposalDescription.tr(context),
                    controller: _descController,
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty
                        ? AppStrings.requiredField.tr(context)
                        : null,
                  ),

                  SizedBox(height: 16.h),

                  _buildFilePicker(),

                  SizedBox(height: 32.h),

                  BlocBuilder<LawyerProposalsCubit, LawyerProposalsState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: AppStrings.confirm.tr(context),
                        isLoading: state is LawyerProposalActionLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.optionalDocuments.tr(context),
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(AppStrings.addFile.tr(context)),
            ),
          ],
        ),
        if (_selectedFiles.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(_selectedFiles.length, (index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _selectedFiles[index].path.split('/').last,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => _removeFile(index),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
