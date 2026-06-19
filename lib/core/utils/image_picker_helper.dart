import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Selección de imágenes con permisos en móvil y selector de archivos en web.
class ImagePickerHelper {
  ImagePickerHelper._();

  static final _picker = ImagePicker();

  static Future<XFile?> pick({
    required ImageSource source,
    double? maxWidth,
    int? imageQuality,
  }) async {
    if (!kIsWeb) {
      final granted = await _ensureMobilePermissions(source);
      if (!granted) {
        throw Exception(
          'Permiso denegado. Activa cámara o galería en ajustes del dispositivo.',
        );
      }
    } else if (source == ImageSource.camera) {
      // En web/desktop la cámara puede no estar disponible; usar galería/archivo.
      source = ImageSource.gallery;
    }

    return _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
      requestFullMetadata: false,
    );
  }

  static Future<bool> _ensureMobilePermissions(ImageSource source) async {
    if (kIsWeb) return true;

    if (source == ImageSource.camera) {
      final camera = await Permission.camera.request();
      return camera.isGranted;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final photos = await Permission.photos.request();
      return photos.isGranted || photos.isLimited;
    }

    return true;
  }
}
