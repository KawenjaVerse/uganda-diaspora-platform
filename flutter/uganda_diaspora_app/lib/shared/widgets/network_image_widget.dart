import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'shimmer_loading.dart';
import '../../core/constants/app_colors.dart';

class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final IconData fallbackIcon;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => ShimmerLoading(
          width: width ?? double.infinity,
          height: height ?? 200,
          borderRadius: borderRadius,
        ),
        errorWidget: (_, __, ___) => _buildFallback(context),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.primary.withOpacity(0.1),
        child: Icon(fallbackIcon, color: AppColors.primary.withOpacity(0.5), size: 40),
      ),
    );
  }
}
