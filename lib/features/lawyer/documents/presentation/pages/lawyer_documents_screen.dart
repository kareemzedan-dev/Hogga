import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/documents/presentation/cubit/lawyer_documents_cubit.dart';
import 'package:hogga/features/lawyer/documents/data/models/lawyer_document_model.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/custom_text.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';

class LawyerDocumentsScreen extends StatefulWidget {
  const LawyerDocumentsScreen({super.key});

  @override
  State<LawyerDocumentsScreen> createState() => _LawyerDocumentsScreenState();
}

class _LawyerDocumentsScreenState extends State<LawyerDocumentsScreen> {
  String? _currentFolder;

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          final nameController = TextEditingController(text: fileName.split('.').first);
          return AlertDialog(
            backgroundColor: context.cardBg,
            title: CustomText(AppStrings.uploadNewDocument.tr(context), fontSize: 16.sp, fontWeight: FontWeight.bold),
            content: TextField(
              controller: nameController,
              style: context.text.bodyMedium?.copyWith(fontSize: 14.sp),
              decoration: InputDecoration(
                labelText: AppStrings.documentName.tr(context),
                labelStyle: context.text.bodyMedium?.copyWith(fontSize: 14.sp, color: context.textSecondary),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), 
                child: CustomText(AppStrings.cancel.tr(context), color: context.textSecondary, fontSize: 14.sp),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: context.accentGolden),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<LawyerDocumentsCubit>().uploadDocument(
                      name: nameController.text,
                      file: file,
                      folder: _currentFolder,
                    );
                    Navigator.pop(dialogContext);
                  }
                },
                child: CustomText(AppStrings.upload.tr(context), color: context.pageBg, fontSize: 14.sp),
              ),
            ],
          );
        },
      );
    } else {
      // Validation: No file selected
      if (!context.mounted) return;
      AppSnackbar.showError(context, messageKey: AppStrings.noFileSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LawyerDocumentsCubit>()..fetchDocuments(folder: _currentFolder),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.pageBg,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: context.divColor.withValues(alpha: 0.5), width: 1)),
          title: Text(AppStrings.documentsAndFiles.tr(context), style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary)),
          centerTitle: true,
          leading: _currentFolder != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios), 
                onPressed: () {
                  setState(() => _currentFolder = null);
                  context.read<LawyerDocumentsCubit>().fetchDocuments();
                },
              ) 
            : null,
        ),
        body: BlocConsumer<LawyerDocumentsCubit, LawyerDocumentsState>(
          listener: (context, state) {
            if (state is LawyerDocumentActionSuccess) {
              AppSnackbar.showSuccess(
                context,
                messageKey: AppStrings.operationSuccess,
              );
            }
          },
          builder: (context, state) {
            if (state is LawyerDocumentsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LawyerDocumentsError) {
              return Center(child: Text(state.message.tr(context)));
            } else if (state is LawyerDocumentsLoaded) {
              final response = state.response;
              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUploadCard(context),
                    if (response.folders.isNotEmpty && _currentFolder == null) ...[
                      SizedBox(height: 24.h),
                      Text(AppStrings.recentFolders.tr(context), style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.h),
                      _buildFolderGrid(context, response.folders),
                    ],
                    SizedBox(height: 24.h),
                    Text(
                      _currentFolder != null ? _currentFolder! : AppStrings.latestFiles.tr(context), 
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 12.h),
                    _buildFileList(context, response.files.data),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return LawyerCard(
      onTap: () => _pickAndUpload(context),
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: context.accentGolden.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.cloud_upload_outlined, color: context.accentGolden),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.uploadNewDocument.tr(context), style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('PDF, DOCX, Images', style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.add_circle_outline_rounded, color: context.accentGolden),
        ],
      ),
    );
  }

  Widget _buildFolderGrid(BuildContext context, List<String> folders) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.5,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return _buildFolderItem(context, folders[index]);
      },
    );
  }

  Widget _buildFolderItem(BuildContext context, String name) {
    return LawyerCard(
      onTap: () {
        setState(() => _currentFolder = name);
        context.read<LawyerDocumentsCubit>().fetchDocuments(folder: name);
      },
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_rounded, color: context.accentGolden, size: 30.sp),
          SizedBox(height: 8.h),
          Text(
            name, 
            style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<LawyerFileModel> files) {
    if (files.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(AppStrings.noDataFound.tr(context), style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final file = files[index];
        return LawyerCard(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              _buildFileIcon(file.fileType),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name, 
                      style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      file.fileType.toUpperCase(), 
                      style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20.sp),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: context.cardBg,
                      title: CustomText(AppStrings.deleteDocument.tr(context), fontSize: 16.sp, fontWeight: FontWeight.bold),
                      content: CustomText(AppStrings.confirmDeleteDocument.tr(context), fontSize: 14.sp),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext), 
                          child: CustomText(AppStrings.cancel.tr(context), color: context.textSecondary, fontSize: 14.sp),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<LawyerDocumentsCubit>().deleteDocument(file.id);
                            Navigator.pop(dialogContext);
                          },
                          child: CustomText(AppStrings.delete.tr(context), color: Colors.red, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description_rounded;
        color = Colors.blue;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image_rounded;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }
}
