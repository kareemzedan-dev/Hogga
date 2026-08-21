import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
