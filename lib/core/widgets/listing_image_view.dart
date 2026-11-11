import 'dart:convert';
import 'package:flutter/material.dart';

/// Renders listing photos supporting both Base64 Data URIs (100% free Firestore storage)
/// and standard HTTP/HTTPS URLs.
class ListingImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const ListingImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

    if (url.startsWith('data:image/')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64Str =
            commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(
              Icons.fastfood_outlined,
              size: 32,
              color: Colors.grey,
            ),
          ),
        );
  }
}
