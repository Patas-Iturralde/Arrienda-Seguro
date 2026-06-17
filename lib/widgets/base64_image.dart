import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/image_base64_utils.dart';

/// Muestra una imagen almacenada en base64 dentro de Firestore.
class Base64Image extends StatelessWidget {
  const Base64Image({
    super.key,
    required this.base64,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  final String? base64;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (base64 == null ||
        base64!.isEmpty ||
        !ImageBase64Utils.isBase64Image(base64)) {
      return _wrap(_defaultPlaceholder());
    }

    try {
      final bytes = ImageBase64Utils.decode(base64!);
      return _wrap(
        Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) =>
              errorWidget ?? _defaultPlaceholder(icon: Icons.broken_image),
        ),
      );
    } catch (_) {
      return _wrap(errorWidget ?? _defaultPlaceholder(icon: Icons.broken_image));
    }
  }

  Widget _wrap(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _defaultPlaceholder({IconData icon = Icons.image_outlined}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.divider,
      alignment: Alignment.center,
      child: placeholder ??
          Icon(
            icon,
            size: (width != null && height != null)
                ? (width! < height! ? width! : height!) * 0.35
                : 40,
            color: AppColors.textSecondary,
          ),
    );
  }
}
