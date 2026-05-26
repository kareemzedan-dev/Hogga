import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

class LawyerEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const LawyerEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.assignment_late_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.divColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.golden.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.golden, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
