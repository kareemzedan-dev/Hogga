import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hogga/core/theme/app_theme.dart';

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const CustomShimmer.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  const CustomShimmer.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.mc.shimmerBase,
      highlightColor: context.mc.shimmerHighlight,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: context.mc.shimmerBase,
          shape: shapeBorder,
        ),
      ),
    );
  }
}
