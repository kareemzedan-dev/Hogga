import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class OnboardingFilePickerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? filePath;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool isLoading;

  const OnboardingFilePickerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filePath,
    required this.onTap,
    this.onClear,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final exists = filePath != null;
    final isImage = filePath != null && 
        (filePath!.toLowerCase().endsWith('.jpg') || 
         filePath!.toLowerCase().endsWith('.jpeg') || 
         filePath!.toLowerCase().endsWith('.png') || 
         filePath!.toLowerCase().endsWith('.webp'));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLoading 
                ? AppColors.golden 
                : (exists ? Colors.green : context.divColor),
            width: (exists || isLoading) ? 1.5 : 1,
          ),
          boxShadow: exists ? [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 44,
                height: 44,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.golden),
                ),
              )
            else if (exists && isImage)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(filePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: exists ? Colors.green.withValues(alpha: 0.12) : AppColors.golden.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exists ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                  color: exists ? Colors.green : AppColors.golden,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  if (isLoading)
                    Text(
                      AppStrings.processingAndVerifying.tr(context),
                      style: context.text.bodySmall?.copyWith(color: AppColors.golden, fontWeight: FontWeight.w600),
                    )
                  else if (!exists)
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(color: context.textSecondary),
                    )
                  else
                    Text(
                      AppStrings.fileVerifiedSuccess.tr(context),
                      style: context.text.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            if (exists && onClear != null && !isLoading)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
