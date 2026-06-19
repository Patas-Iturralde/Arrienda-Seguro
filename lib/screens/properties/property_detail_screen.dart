import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/property.dart';
import '../../data/models/rental_request.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../providers/property_provider.dart';
import '../../routing/app_routes.dart';
import '../../widgets/base64_image.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  bool _loading = true;
  bool _hasPendingRequest = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final propertyProvider = context.read<PropertyProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    final property = await propertyProvider.getById(widget.propertyId);
    var hasPending = false;
    if (user != null && user.role == UserRole.arrendatario) {
      hasPending = await ServiceLocator.instance.rentalRequestRepository
          .hasPendingRequest(
        propertyId: widget.propertyId,
        arrendatarioId: user.id,
      );
    }
    if (mounted) {
      setState(() {
        _property = property;
        _hasPendingRequest = hasPending;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final property = _property;
    if (property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Departamento no encontrado')),
      );
    }

    final user = context.watch<AuthProvider>().currentUser;
    final isTenant = user?.role == UserRole.arrendatario;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _PhotoGallery(fotos: property.fotos),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          property.tipo,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!property.disponible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'No disponible',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.direccionCompleta,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    Formatters.currency(property.valor),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Valor mensual del arriendo',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.descripcion.isNotEmpty
                        ? property.descripcion
                        : 'Sin descripción disponible.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (property.servicios.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Servicios incluidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...property.servicios.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s, style: const TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (property.arrendadorNombre != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Arrendador',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.arrendadorNombre!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTenant && property.disponible
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _submitting ? null : () => _openChat(property),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitting || _hasPendingRequest
                            ? null
                            : () => _solicitarArriendo(property),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(0, 48),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _hasPendingRequest
                                    ? 'Solicitud enviada'
                                    : 'Solicitar arriendo',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _openChat(Property property) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final room = await ServiceLocator.instance.chatRepository.getOrCreateRoom(
      propertyId: property.id,
      propertyName: property.nombre,
      arrendadorId: property.arrendadorId,
      arrendadorName: property.arrendadorNombre ?? 'Arrendador',
      arrendatarioId: user.id,
      arrendatarioName: user.nombreCompleto,
    );
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.chat, arguments: room.id);
  }

  Future<void> _solicitarArriendo(Property property) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final mensaje = await showDialog<String>(
      context: context,
      builder: (context) => const _SolicitudDialog(),
    );
    if (mensaje == null || !mounted) return;

    setState(() => _submitting = true);
    try {
      await ServiceLocator.instance.rentalRequestRepository.create(
        RentalRequest(
          id: '',
          propertyId: property.id,
          propertyName: property.nombre,
          arrendadorId: property.arrendadorId,
          arrendatarioId: user.id,
          arrendatarioName: user.nombreCompleto,
          mensaje: mensaje.isEmpty ? null : mensaje,
        ),
      );

      if (!mounted) return;
      setState(() {
        _hasPendingRequest = true;
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada. El arrendador revisará tu petición.',
          ),
        ),
      );

      await _openChat(property);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la solicitud: $e')),
      );
    }
  }
}

class _SolicitudDialog extends StatefulWidget {
  const _SolicitudDialog();

  @override
  State<_SolicitudDialog> createState() => _SolicitudDialogState();
}

class _SolicitudDialogState extends State<_SolicitudDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solicitar arriendo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Envía una solicitud al arrendador. Puedes incluir un mensaje '
            'opcional.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mensaje (opcional)',
              hintText: 'Me interesa arrendar este inmueble...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Enviar solicitud'),
        ),
      ],
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.fotos});

  final List<String> fotos;

  @override
  Widget build(BuildContext context) {
    if (fotos.isEmpty) {
      return Container(
        color: AppColors.divider,
        child: const Center(
          child: Icon(Icons.apartment, size: 80, color: AppColors.textSecondary),
        ),
      );
    }

    return PageView.builder(
      itemCount: fotos.length,
      itemBuilder: (context, index) {
        return Base64Image(
          base64: fotos[index],
          fit: BoxFit.cover,
          errorWidget: Container(
            color: AppColors.divider,
            child: const Icon(Icons.broken_image, size: 64),
          ),
        );
      },
    );
  }
}
