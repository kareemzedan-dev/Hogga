import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';

class OrderShimmerList extends StatelessWidget {
  const OrderShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) => const _OrderShimmerItem(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }
}

class _OrderShimmerItem extends StatelessWidget {
  const _OrderShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark?AppColors.cream:AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Image placeholder
          const CustomShimmer.rectangular(
            height: 70,
            width: 70,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          const SizedBox(width: 16),
          // Content placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomShimmer.rectangular(height: 14, width: 120),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    CustomShimmer.rectangular(height: 10, width: 60),
                    SizedBox(width: 12),
                    CustomShimmer.rectangular(height: 10, width: 60),
                  ],
                ),
                const SizedBox(height: 8),
                const CustomShimmer.rectangular(height: 20, width: 80, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
