import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Utilidades para codificar/decodificar imágenes en base64 para Firestore.
class ImageBase64Utils {
  ImageBase64Utils._();

  static const maxPropertyPhotos = 8;
  static const maxPropertyWidth = 900;
  static const maxProfileWidth = 400;
  static const propertyQuality = 75;
  static const profileQuality = 80;

  /// Comprime bytes de imagen y devuelve base64 sin prefijo data-uri.
  static String encodeBytes(
    Uint8List bytes, {
    int maxWidth = maxPropertyWidth,
    int quality = propertyQuality,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw FormatException('No se pudo leer la imagen seleccionada.');
    }

    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;

    final jpeg = img.encodeJpg(resized, quality: quality);
    return base64Encode(jpeg);
  }

  static Uint8List decode(String base64String) {
    final raw = _stripDataUriPrefix(base64String.trim());
    return base64Decode(raw);
  }

  static bool isBase64Image(String? value) {
    if (value == null || value.isEmpty) return false;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return false;
    }
    final raw = _stripDataUriPrefix(value);
    if (raw.length < 32) return false;
    try {
      base64Decode(raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _stripDataUriPrefix(String value) {
    final comma = value.indexOf(',');
    if (value.startsWith('data:') && comma != -1) {
      return value.substring(comma + 1);
    }
    return value;
  }
}
