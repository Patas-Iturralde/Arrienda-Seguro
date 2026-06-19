import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract_generation_args.dart';
import '../../data/models/rental_request.dart';
import '../../providers/app_providers.dart';
import '../../providers/property_provider.dart';
import '../../routing/app_routes.dart';

class LandlordRentalRequestsScreen extends StatefulWidget {
  const LandlordRentalRequestsScreen({super.key});

  @override
  State<LandlordRentalRequestsScreen> createState() =>
      _LandlordRentalRequestsScreenState();
}

class _LandlordRentalRequestsScreenState
    extends State<LandlordRentalRequestsScreen> {
  List<RentalRequest> _requests = [];
  bool _loading = true;
  String? _updatingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    final requests = await ServiceLocator.instance.rentalRequestRepository
        .getByLandlord(user.id);
    if (mounted) {
      setState(() {
        _requests = requests;
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(
    RentalRequest request,
    RentalRequestStatus status,
  ) async {
    setState(() => _updatingId = request.id);
    try {
      await ServiceLocator.instance.rentalRequestRepository.updateStatus(
        request.id,
        status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == RentalRequestStatus.aceptada
                ? 'Solicitud aceptada'
                : 'Solicitud rechazada',
          ),
        ),
      );
      await _load();
      if (status == RentalRequestStatus.aceptada && mounted) {
        await _promptGenerateContract(request);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  Future<void> _confirmAction(
    RentalRequest request,
    RentalRequestStatus status,
  ) async {
    final isAccept = status == RentalRequestStatus.aceptada;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAccept ? 'Aceptar solicitud' : 'Rechazar solicitud'),
        content: Text(
          isAccept
              ? '¿Aceptas la solicitud de ${request.arrendatarioName} '
                  'para ${request.propertyName}?'
              : '¿Rechazas la solicitud de ${request.arrendatarioName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isAccept
                ? null
                : ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(isAccept ? 'Aceptar' : 'Rechazar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _updateStatus(request, status);
    }
  }

  Future<void> _promptGenerateContract(RentalRequest request) async {
    final generate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Siguiente paso'),
        content: Text(
          'La solicitud de ${request.arrendatarioName} fue aceptada. '
          '¿Deseas generar el contrato de arriendo ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generar contrato'),
          ),
        ],
      ),
    );
    if (generate == true && mounted) {
      await _openGenerateContract(request);
    }
  }

  Future<ContractGenerationArgs?> _buildContractArgs(
    RentalRequest request,
  ) async {
    final landlord = context.read<AuthProvider>().currentUser;
    if (landlord == null) return null;

    final propertyProvider = context.read<PropertyProvider>();
    final property = await propertyProvider.getById(request.propertyId);
    final tenant = await ServiceLocator.instance.authRepository
        .getUserById(request.arrendatarioId);

    final tenantParts = _splitFullName(
      tenant?.nombreCompleto ?? request.arrendatarioName,
    );

    return ContractGenerationArgs(
      rentalRequestId: request.id,
      propertyId: request.propertyId,
      propertyName: request.propertyName,
      propertyTipo: property?.tipo ?? 'Departamento',
      direccion: property?.direccion ?? '',
      ciudad: property?.ciudad ?? '',
      canonMensual: property?.valor ?? 0,
      arrendadorId: landlord.id,
      arrendadorNombre: landlord.nombre,
      arrendadorApellido: landlord.apellido,
      arrendadorCedula: landlord.cedula,
      arrendadorEmail: landlord.email,
      arrendatarioId: request.arrendatarioId,
      arrendatarioNombre: tenant?.nombre ?? tenantParts.$1,
      arrendatarioApellido: tenant?.apellido ?? tenantParts.$2,
      arrendatarioCedula: tenant?.cedula ?? '',
      arrendatarioEmail: tenant?.email ?? '',
    );
  }

  (String, String) _splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  Future<void> _openGenerateContract(RentalRequest request) async {
    final args = await _buildContractArgs(request);
    if (!mounted || args == null) return;

    await Navigator.pushNamed(
      context,
      AppRoutes.generateContract,
      arguments: args,
    );
    if (mounted) await _load();
  }

  Future<void> _openChat(RentalRequest request) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final room = await ServiceLocator.instance.chatRepository.getOrCreateRoom(
      propertyId: request.propertyId,
      propertyName: request.propertyName,
      arrendadorId: request.arrendadorId,
      arrendadorName: user.nombreCompleto,
      arrendatarioId: request.arrendatarioId,
      arrendatarioName: request.arrendatarioName,
    );
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.chat, arguments: room.id);
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _requests
        .where((r) => r.status == RentalRequestStatus.pendiente)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de arriendo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _requests.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No tienes solicitudes de arriendo',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (pendingCount > 0)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notifications_active_outlined,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '$pendingCount solicitud'
                                    '${pendingCount == 1 ? '' : 'es'} '
                                    'pendiente${pendingCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ..._requests.map(_buildRequestCard),
                      ],
                    ),
            ),
    );
  }

  Widget _buildRequestCard(RentalRequest request) {
    final isUpdating = _updatingId == request.id;
    final isPending = request.status == RentalRequestStatus.pendiente;
    final isAccepted = request.status == RentalRequestStatus.aceptada;
    final hasContract =
        request.status == RentalRequestStatus.contratoGenerado;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.propertyName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  request.arrendatarioName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            if (request.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Recibida el ${Formatters.date(request.createdAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (request.mensaje != null && request.mensaje!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.mensaje!,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: isUpdating ? null : () => _openChat(request),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                ),
                const Spacer(),
                if (isPending) ...[
                  OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _confirmAction(
                              request,
                              RentalRequestStatus.rechazada,
                            ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _confirmAction(
                              request,
                              RentalRequestStatus.aceptada,
                            ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Aceptar'),
                  ),
                ],
                if (isAccepted && !hasContract)
                  ElevatedButton.icon(
                    onPressed: isUpdating
                        ? null
                        : () => _openGenerateContract(request),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Generar contrato'),
                  ),
                if (hasContract)
                  const Chip(
                    label: Text('Contrato generado'),
                    backgroundColor: AppColors.successLight,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RentalRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      RentalRequestStatus.pendiente => (AppColors.warningLight, AppColors.warning),
      RentalRequestStatus.aceptada => (AppColors.successLight, AppColors.success),
      RentalRequestStatus.contratoGenerado =>
        (AppColors.successLight, AppColors.success),
      RentalRequestStatus.rechazada => (const Color(0xFFFFEBEE), AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
