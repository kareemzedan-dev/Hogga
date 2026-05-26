import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';

class AppDialog extends StatelessWidget {
  final String titleKey;
  final String descriptionKey;
  final String cancelTextKey;
  final String confirmTextKey;
  final VoidCallback? onConfirm;

  const AppDialog({
    super.key,
    required this.titleKey,
    required this.descriptionKey,
    required this.cancelTextKey,
    required this.confirmTextKey,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Icon(
        Icons.check_circle,
        color: AppColors.primary,
        size: 60,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titleKey,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            descriptionKey,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelTextKey),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (onConfirm != null) onConfirm!();
          },
          child: Text(confirmTextKey),
        ),
      ],
    );
  }

  static void show(
      BuildContext context, {
        required String titleKey,
        required String descriptionKey,
        required String cancelTextKey,
        required String confirmTextKey,
        VoidCallback? onConfirm,
      }) {
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        titleKey: titleKey,
        descriptionKey: descriptionKey,
        cancelTextKey: cancelTextKey,
        confirmTextKey: confirmTextKey,
        onConfirm: onConfirm,
      ),
    );
  }
}
