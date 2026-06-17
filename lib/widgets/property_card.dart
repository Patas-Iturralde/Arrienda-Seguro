import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/property.dart';
import 'base64_image.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.onChatTap,
    this.showAvailabilityToggle = false,
    this.onAvailabilityChanged,
    this.onEditTap,
  });

  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onChatTap;
  final bool showAvailabilityToggle;
  final ValueChanged<bool>? onAvailabilityChanged;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PropertyImage(property: property),
              const SizedBox(width: 12),
              Expanded(child: _PropertyInfo(property: property)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 110,
        height: 110,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (property.fotoPrincipal != null)
              Base64Image(
                base64: property.fotoPrincipal,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: AppColors.divider,
                  child: const Icon(Icons.apartment, size: 40),
                ),
              )
            else
              Container(
                color: AppColors.divider,
                child: const Icon(Icons.apartment, size: 40),
              ),
            if (!property.disponible)
              Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: const Text(
                  'No disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PropertyInfo extends StatelessWidget {
  const _PropertyInfo({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.nombre,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          property.tipo,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          property.direccionCompleta,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (property.servicios.isNotEmpty) ...[
          const SizedBox(height: 6),
          ...property.servicios.take(2).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                Formatters.currency(property.valor),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (property.disponible)
              const Text(
                '/ mes',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class PropertyCardActions extends StatelessWidget {
  const PropertyCardActions({
    super.key,
    required this.property,
    required this.onViewTap,
    this.onChatTap,
    this.showAvailabilityToggle = false,
    this.onAvailabilityChanged,
    this.onEditTap,
  });

  final Property property;
  final VoidCallback onViewTap;
  final VoidCallback? onChatTap;
  final bool showAvailabilityToggle;
  final ValueChanged<bool>? onAvailabilityChanged;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        children: [
          if (showAvailabilityToggle) ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Disponible'),
              subtitle: Text(
                property.disponible
                    ? 'Visible para arrendatarios'
                    : 'Oculto del listado público',
                style: const TextStyle(fontSize: 12),
              ),
              value: property.disponible,
              activeTrackColor: AppColors.primaryLight,
              activeThumbColor: AppColors.primary,
              onChanged: onAvailabilityChanged,
            ),
          ],
          Row(
            children: [
              if (onEditTap != null)
                TextButton.icon(
                  onPressed: onEditTap,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
              const Spacer(),
              if (onChatTap != null)
                OutlinedButton.icon(
                  onPressed: onChatTap,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: property.disponible ? onViewTap : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.divider,
                  disabledForegroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Ver detalle >'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
