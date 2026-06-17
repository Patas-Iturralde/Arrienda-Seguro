import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Selección de imágenes con permisos y API compatible en Android.
class ImagePickerHelper {
  ImagePickerHelper._();

  static final _picker = ImagePicker();

  static Future<XFile?> pick({
    required ImageSource source,
    double? maxWidth,
    int? imageQuality,
  }) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final granted = await _ensurePermissions(source);
      if (!granted) {
        throw Exception(
          'Permiso denegado. Activa cámara o galería en ajustes del dispositivo.',
        );
      }
    }

    // pickImage es más estable que pickMultiImage en Android.
    return _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
      requestFullMetadata: false,
    );
  }

  static Future<bool> _ensurePermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final camera = await Permission.camera.request();
      return camera.isGranted;
    }

    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    final photos = await Permission.photos.request();
    return photos.isGranted || photos.isLimited;
  }
}
