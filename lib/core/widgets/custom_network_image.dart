import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hogga/core/utils/image_helper.dart';
import 'package:hogga/core/theme/app_theme.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final BorderRadius? customBorderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.fill,
    this.borderRadius = 0.0,
    this.customBorderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedUrl = ImageHelper.sanitizeUrl(imageUrl);
    return ClipRRect(
      borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: sanitizedUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildShimmer(context),
        errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final mc = Theme.of(context).extension<hoggaColors>()!;
    return LayoutBuilder(builder: (context, constraints) {
      return Shimmer.fromColors(
        baseColor: mc.shimmerBase,
        highlightColor: mc.shimmerHighlight,
        child: Container(
          height: height ?? (constraints.hasBoundedHeight ? double.infinity : 100),
          width: width ?? (constraints.hasBoundedWidth ? double.infinity : 100),
          decoration: BoxDecoration(
            color: mc.shimmerBase,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}
