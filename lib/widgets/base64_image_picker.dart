import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/image_base64_utils.dart';
import '../core/utils/image_picker_helper.dart';
import 'base64_image.dart';

/// Selector de fotografías guardadas como base64 (una por selección).
class Base64ImagePickerField extends StatelessWidget {
  const Base64ImagePickerField({
    super.key,
    required this.images,
    required this.onChanged,
    this.maxImages = ImageBase64Utils.maxPropertyPhotos,
    this.label = 'Fotografías',
    this.maxWidth = ImageBase64Utils.maxPropertyWidth,
    this.quality = ImageBase64Utils.propertyQuality,
  });

  final List<String> images;
  final ValueChanged<List<String>> onChanged;
  final int maxImages;
  final String label;
  final int maxWidth;
  final int quality;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    if (images.length >= maxImages) {
      _showSnack(context, 'Máximo $maxImages fotografías.');
      return;
    }

    try {
      final picked = await ImagePickerHelper.pick(
        source: source,
        maxWidth: maxWidth.toDouble(),
        imageQuality: quality,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      onChanged([
        ...images,
        ImageBase64Utils.encodeBytes(
          bytes,
          maxWidth: maxWidth,
          quality: quality,
        ),
      ]);
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, _friendlyError(e));
      }
    }
  }

  String _friendlyError(Object e) {
    final text = e.toString();
    if (text.contains('channel-error')) {
      return 'Reinicia la app por completo (detén y vuelve a ejecutar flutter run).';
    }
    if (text.contains('Permiso denegado')) {
      return 'Permiso denegado. Activa cámara o galería en ajustes.';
    }
    return 'No se pudo cargar la imagen: $e';
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _remove(int index) {
    final updated = List<String>.from(images)..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Base64 en Firestore · ${images.length}/$maxImages · puedes agregar varias',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        if (images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Base64Image(
                      base64: images[index],
                      width: 100,
                      height: 100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _remove(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (images.isNotEmpty) const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: images.length >= maxImages
                    ? null
                    : () => _pick(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: images.length >= maxImages
                    ? null
                    : () => _pick(context, ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Cámara'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Avatar editable con foto de perfil en base64.
class EditableProfilePhoto extends StatelessWidget {
  const EditableProfilePhoto({
    super.key,
    required this.fotoBase64,
    required this.iniciales,
    required this.onPhotoChanged,
    this.radius = 40,
    this.loading = false,
  });

  final String? fotoBase64;
  final String iniciales;
  final ValueChanged<String> onPhotoChanged;
  final double radius;
  final bool loading;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final picked = await ImagePickerHelper.pick(
        source: source,
        maxWidth: ImageBase64Utils.maxProfileWidth.toDouble(),
        imageQuality: ImageBase64Utils.profileQuality,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      onPhotoChanged(
        ImageBase64Utils.encodeBytes(
          Uint8List.fromList(bytes),
          maxWidth: ImageBase64Utils.maxProfileWidth,
          quality: ImageBase64Utils.profileQuality,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        final text = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              text.contains('channel-error')
                  ? 'Reinicia la app por completo (flutter run).'
                  : 'No se pudo actualizar la foto: $e',
            ),
          ),
        );
      }
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () async {
                Navigator.pop(ctx);
                await Future<void>.delayed(const Duration(milliseconds: 350));
                if (!context.mounted) return;
                await _pick(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () async {
                Navigator.pop(ctx);
                await Future<void>.delayed(const Duration(milliseconds: 350));
                if (!context.mounted) return;
                await _pick(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        fotoBase64 != null && ImageBase64Utils.isBase64Image(fotoBase64);

    return GestureDetector(
      onTap: loading ? null : () => _showOptions(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primaryLight,
            child: hasPhoto
                ? ClipOval(
                    child: Base64Image(
                      base64: fotoBase64,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    iniciales,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: radius * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          if (loading)
            Positioned.fill(
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.black26,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
