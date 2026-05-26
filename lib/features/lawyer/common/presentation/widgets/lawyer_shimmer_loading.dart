import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

class LawyerShimmerLoading extends StatelessWidget {
  const LawyerShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = Theme.of(context).extension<hoggaColors>()!;
    final baseColor = mc.shimmerBase;
    final highlightColor = mc.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(context, height: 100, width: double.infinity, borderRadius: 20),
              const SizedBox(height: 24),
              _buildShimmerBox(context, height: 120, width: double.infinity, borderRadius: 20),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildShimmerBox(context, height: 80, borderRadius: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildShimmerBox(context, height: 80, borderRadius: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildShimmerBox(context, height: 80, borderRadius: 16)),
                ],
              ),
              const SizedBox(height: 24),
              _buildShimmerBox(context, height: 150, width: double.infinity, borderRadius: 20),
              const SizedBox(height: 24),
              _buildShimmerBox(context, height: 150, width: double.infinity, borderRadius: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox(BuildContext context, {required double height, double? width, double borderRadius = 8}) {
    final mc = Theme.of(context).extension<hoggaColors>()!;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: mc.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
