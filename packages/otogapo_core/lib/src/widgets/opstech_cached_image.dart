import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OpstechCachedImage extends StatelessWidget {
  const OpstechCachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(8.r);

    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => Container(
        width: width,
        height: height,
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, _, __) => Container(
        width: width,
        height: height,
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.grey[300],
        child: const Icon(Icons.broken_image),
      ),
    );

    if (borderRadius == null) return image;

    return ClipRRect(
      borderRadius: radius,
      child: image,
    );
  }
}


