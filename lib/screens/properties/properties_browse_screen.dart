import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/property.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../providers/property_provider.dart';
import '../../routing/app_routes.dart';
import '../../widgets/property_card.dart';

class PropertiesBrowseScreen extends StatefulWidget {
  const PropertiesBrowseScreen({super.key});

  @override
  State<PropertiesBrowseScreen> createState() => _PropertiesBrowseScreenState();
}

class _PropertiesBrowseScreenState extends State<PropertiesBrowseScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PropertyProvider>();
      provider.watchAvailable();
      provider.loadAvailable();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();
    final properties = provider.properties.where((p) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return p.nombre.toLowerCase().contains(q) ||
          p.ciudad.toLowerCase().contains(q) ||
          p.direccion.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Departamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Conversaciones',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o ciudad...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: provider.loading && properties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadAvailable(),
              child: properties.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.apartment_outlined,
                            size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No hay departamentos disponibles',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index];
                        return Column(
                          children: [
                            PropertyCard(
                              property: property,
                              onTap: () => _openDetail(property.id),
                            ),
                            PropertyCardActions(
                              property: property,
                              onViewTap: () => _openDetail(property.id),
                              onChatTap: () => _openChat(property),
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      },
                    ),
            ),
    );
  }

  void _openDetail(String propertyId) {
    Navigator.pushNamed(
      context,
      AppRoutes.propertyDetail,
      arguments: propertyId,
    );
  }

  Future<void> _openChat(Property property) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || user.role != UserRole.arrendatario) return;

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
}
