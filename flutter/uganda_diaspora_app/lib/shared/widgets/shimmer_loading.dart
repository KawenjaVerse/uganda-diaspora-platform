import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF4A5568) : const Color(0xFFF7FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(width: double.infinity, height: 160, borderRadius: 12),
            const SizedBox(height: 12),
            ShimmerLoading(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            ShimmerLoading(width: 200, height: 12),
            const SizedBox(height: 8),
            ShimmerLoading(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}
