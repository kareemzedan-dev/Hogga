import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/core/theme/app_theme.dart';
import '../utils/app_colors.dart';

class CircleImageWithBorder extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl;
  final bool isBorder;
  final double borderWidth;
  final Color? borderColor;

  const CircleImageWithBorder({
    super.key,
    this.width = 63,
    this.height = 60,
    this.imageUrl,
    this.isBorder = true,
    this.borderWidth = 2,
    this.borderColor,
  });

  static const String defaultImage =
      "https://i.pravatar.cc/150?img=3";

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.isNotEmpty == true ? imageUrl! : "";

    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isBorder ? (borderColor ?? context.accentGolden) : Colors.transparent,
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.mc.chipBg,
        ),
        child: ClipOval(
          child: image.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: context.mc.shimmerBase),
                  errorWidget: (context, url, error) => Image.asset(
                    AppAssets.userPlaceholder,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  AppAssets.userPlaceholder,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
