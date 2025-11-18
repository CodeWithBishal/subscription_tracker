import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCardPlaceholder extends StatelessWidget {
  const ShimmerCardPlaceholder({super.key, this.height = 72, this.margin});

  final double height;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({
    super.key,
    this.count = 3,
    this.height = 72,
    this.margin,
  });

  final int count;
  final double height;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => ShimmerCardPlaceholder(height: height, margin: margin),
      ),
    );
  }
}
