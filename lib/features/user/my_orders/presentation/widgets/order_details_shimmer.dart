import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';

class OrderDetailsShimmer extends StatelessWidget {
  const OrderDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const CustomShimmer.circular(width: 60, height: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomShimmer.rectangular(height: 16, width: 150),
                      const SizedBox(height: 8),
                      const CustomShimmer.rectangular(height: 12, width: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary Card Shimmer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              children: List.generate(4, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CustomShimmer.rectangular(height: 12, width: 80),
                    CustomShimmer.rectangular(height: 12, width: 120),
                  ],
                ),
              )),
            ),
          ),
          const SizedBox(height: 24),
          
          // Proposals Section Shimmer
          const CustomShimmer.rectangular(height: 20, width: 150),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CustomShimmer.circular(width: 40, height: 40),
                    const SizedBox(width: 12),
                    const CustomShimmer.rectangular(height: 14, width: 120),
                  ],
                ),
                const SizedBox(height: 16),
                const CustomShimmer.rectangular(height: 12, width: double.infinity),
                const SizedBox(height: 8),
                const CustomShimmer.rectangular(height: 12, width: 200),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Receipt Shimmer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              children: List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CustomShimmer.rectangular(height: 12, width: 80),
                    CustomShimmer.rectangular(height: 12, width: 60),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
