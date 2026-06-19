import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/image_base64_utils.dart';
import '../core/utils/image_picker_helper.dart';
import '../data/models/id_document_type.dart';
import 'base64_image.dart';

/// Selector de foto del documento de identidad (cédula, licencia o pasaporte).
class IdDocumentPicker extends StatelessWidget {
  const IdDocumentPicker({
    super.key,
    required this.tipoDocumento,
    required this.documentoBase64,
    required this.onChanged,
  });

  final IdDocumentType tipoDocumento;
  final String? documentoBase64;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final picked = await ImagePickerHelper.pick(
        source: source,
        maxWidth: ImageBase64Utils.maxPropertyWidth.toDouble(),
        imageQuality: ImageBase64Utils.propertyQuality,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      onChanged(
        ImageBase64Utils.encodeBytes(
          bytes,
          maxWidth: ImageBase64Utils.maxPropertyWidth,
          quality: ImageBase64Utils.propertyQuality,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cargar el documento: $e')),
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
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Foto del documento (${tipoDocumento.label}) *',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (documentoBase64 != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Base64Image(
              base64: documentoBase64!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showOptions(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Cambiar foto'),
              ),
              TextButton(
                onPressed: () => onChanged(null),
                child: const Text(
                  'Quitar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ] else
          OutlinedButton.icon(
            onPressed: () => _showOptions(context),
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Subir foto del documento'),
          ),
      ],
    );
  }
}
