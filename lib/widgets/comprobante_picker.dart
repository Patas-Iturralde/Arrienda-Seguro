import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/image_base64_utils.dart';
import '../core/utils/image_picker_helper.dart';
import 'base64_image.dart';

/// Selector de un comprobante de pago (captura o foto).
class ComprobantePicker extends StatelessWidget {
  const ComprobantePicker({
    super.key,
    required this.comprobanteBase64,
    required this.onChanged,
  });

  final String? comprobanteBase64;
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
          SnackBar(content: Text('No se pudo cargar el comprobante: $e')),
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
              subtitle: const Text('Captura de pantalla o foto guardada'),
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
              subtitle: const Text('Fotografiar el comprobante impreso'),
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
    final hasImage =
        comprobanteBase64 != null && ImageBase64Utils.isBase64Image(comprobanteBase64);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Comprobante de pago',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sube una captura de la transferencia o foto del comprobante',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (hasImage) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Base64Image(
              base64: comprobanteBase64,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => onChanged(null),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: const Text(
              'Quitar comprobante',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showOptions(context),
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(hasImage ? 'Cambiar' : 'Subir comprobante'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
