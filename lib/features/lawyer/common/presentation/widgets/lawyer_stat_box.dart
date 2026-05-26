import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'lawyer_card.dart';
import 'package:hogga/core/widgets/custom_text.dart';

class LawyerStatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const LawyerStatBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LawyerCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.sp),
          const SizedBox(height: 6),
          CustomText(
            value,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
          CustomText(
            label,
            textAlign: TextAlign.center,
            isSecondary: true,
            fontSize: 9.sp,
          ),
        ],
      ),
    );
  }
}
