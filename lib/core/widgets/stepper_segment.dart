import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;
  final double spacing;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.height = 4,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 4),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : spacing),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.grey,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
