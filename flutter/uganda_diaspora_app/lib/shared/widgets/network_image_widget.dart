import 'dart:convert';
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

  bool get _isBase64 =>
      imageUrl != null && imageUrl!.startsWith('data:');

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    if (_isBase64) {
      return _buildBase64Image();
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
        errorWidget: (_, __, ___) => _buildFallback(),
      ),
    );
  }

  Widget _buildBase64Image() {
    try {
      // Format: data:image/jpeg;base64,<data>
      final commaIndex = imageUrl!.indexOf(',');
      if (commaIndex == -1) return _buildFallback();
      final base64Str = imageUrl!.substring(commaIndex + 1);
      final bytes = base64Decode(base64Str);
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    } catch (_) {
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.primary.withOpacity(0.1),
        child: Icon(
          fallbackIcon,
          color: AppColors.primary.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }
}
