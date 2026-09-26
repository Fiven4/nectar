import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.iconSize = 50,
    this.dimmed = false,
  });

  final String url;
  final BoxFit fit;
  final double iconSize;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(Icons.image_not_supported, size: iconSize, color: Colors.grey);
    if (url.isEmpty) {
      return placeholder;
    }

    return Image.network(
      url,
      fit: fit,
      color: dimmed ? Colors.white.withValues(alpha: 0.5) : null,
      colorBlendMode: dimmed ? BlendMode.modulate : null,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
